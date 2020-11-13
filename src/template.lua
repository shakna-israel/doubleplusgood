--
-- Template
--
-- A braindead template engine.

local expose = {}

local lex = function(str)

  -- Converts the given string to equivalent
  -- Lua code but turning things "inside out".
  -- Most things get converted to a string.
  --    Strings are using [===[ and ]===] as the outer symbols.
  --    So avoid those.
  -- Things inside {% and %} get treated as a Lua statement.
  -- Things inside {{ and }} get placed inside tostring. (Called 'value')

  local inside = 'string'
  local r = {}
  for i = 1, # str do
    local c = str:sub(i, i)
    if #r == 0 then
      r[1] = 's = {}; s[#s + 1] = [===[ '
      r[#r + 1] = c
    elseif inside == 'string' then
      if c == '%' and r[#r] == '{' then
        r[#r] = ']===];'
        inside = 'statement'
      elseif c == '{' and r[#r] == '{' then
        r[#r] = ']===] .. __tostring('
        inside = 'value'
      else
        r[#r + 1] = c
      end
    elseif inside == 'statement' then
      if c == '}' and r[#r] == '%' then
        r[#r] = '\n'
        inside = 'string'
        r[#r + 1] = 's[#s + 1] = [===[ '
      else
        r[#r + 1] = c
      end
    elseif inside == 'value' then
      if c == '}' and r[#r] == '}' then
        r[#r] = ');'
        inside = 'string'
        r[#r + 1] = 's[#s + 1] = [===[ '
      else
        r[#r + 1] = c
      end
    end
  end
  if inside == 'string' then
    r[#r + 1] = ']===];'
  end
  r[#r + 1] = 'return __concat(s, "")'

  return table.concat(r, '')
end

local cache = {}
expose['cache_maxsize'] = 100

local table_size = function(tbl)
  local i = 0
  for k, v in pairs(tbl) do
    i = i + 1
  end
  return i
end

expose['clearcache'] = function()
  -- Allows a user to decimate the template cache.
  cache = {}
  garbagecollect()
end

local inner_render = function(rawdata, model)
  -- Set up model minimal requirements.
  if not model then model = {} end

  -- TODO: We should be able to generate a unique name,
  -- to pass to lex. Because we have the model.
  model['__tostring'] = tostring

  -- TODO: We should be able to generate a unique name,
  -- to pass to lex. Because we have the model.
  model['__concat'] = table.concat


  model['pairs'] = pairs
  model['ipairs'] = ipairs
  model['next'] = next
  model['type'] = type
  model['format'] = string.format
  model['include'] = function(filename, m)
    return expose['renderfile'](filename, m or model)
  end
  
  -- This is a "good enough" hash, exposed by our C interface.
  local hash = adler32(rawdata)

  if cache[hash] then
    -- Still compiling at runtime, but Lua tends to be "fast enough"
    return load(cache[hash], nil, nil, model)()()
  else
    if table_size(cache) < expose.cache_maxsize then
      cache[hash] = 'return function()' .. lex(rawdata) .. 'end'
    else
      -- We've exceeded our maximum size,
      -- throw away half the cache.
      local max = math.floor(table_size(cache) / 2)
      local new_cache = {}
      local i = 0
      for k, v in pairs(cache) do
        new_cache[k] = v
        i = i + 1
        if i > max then
          break
        end
      end
      -- Repeatedly calling garbagecollect is not recommended...
      -- However, we really don't want an oversized cache
      -- hanging around at all.
      -- If the user keeps cache busting, then they have a problem.
      cache = nil
      garbagecollect()
      cache = new_cache

      cache[hash] = 'return function()' .. lex(rawdata) .. 'end'
    end
  end

  -- Still compiling at runtime, but Lua tends to be "fast enough"
  return load(cache[hash], nil, nil, model)()()
end

expose['render'] = function(rawdata, model)

  -- TODO: Convert escapes here...

  local status, ret = pcall(inner_render, rawdata, model)
  if status then

    -- TODO: Unescape here...

    return ret
  else
    assert(io.stderr:write("Error occured processing template:", "\n"))
    assert(io.stderr:write(debug.traceback(), "\n"))
    assert(io.stderr:write(ret, "\n"))
    return false
  end
end

expose['renderfile'] = function(filename, model)

  -- TODO: Check both path and include directory / path...

  local f = io.open(filename, 'rb')
  if f ~= nil then
    local rawdata = f:read("*all")
    return expose['render'](rawdata, model)
  else
    return false
  end
end

return expose
