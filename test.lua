-- Test adler32
assert(adler32("Hello, World!") == 530449514)
assert(adler32("20;S~IVV`kDvdQAbs@k:{WE<0)re/@YX$swF7M+FCZ4%{tBS") == 1971195647)
assert(adler32("/.i_=oJM:-BPB*7FFe6ijVThG@69;-J}GGTMaWQ{;`}oBKK)w") == 1695092456)
assert(adler32("Wikipedia") == 300286872)
assert(adler32(10) == nil)
assert(adler32({}) == nil)
assert(adler32(10.2) == nil)

-- Test template library

-- Test template.render without model...
-- Note: We use escaping here, because the macro engine will attempt to expand otherwise...
do
	local program = [[
	\{% for k, v in ipairs(\{1, 2, 3\}) do %\}
		\{\{k\}\} \{\{v\}\}
	\{% end %\}
	]]

	-- Note: This is a little fragile, because we're comparing whitespace...
	local expect = [[ 	 
		1  1 
	 
		2  2 
	 
		3  3 
	 
	]]
	local expect_hash = 1187120022

	assert(template.render(program) == expect)
	assert(adler32(template.render(program)) == expect_hash)
end

-- TODO: Test template.renderfile without model...
-- TODO: Test template.renderfile with model...

-- Test this file expands correctly...

-- String expansion...
{%
	local macro_value = format("%q", "Hello, World!")
%}
assert({{macro_value}} == "Hello, World!")

-- Number expansion...
{%
	local macro_value = format("%q", 10)
%}
assert({{macro_value}} == 10)

-- Test a simple for loop...
{%
	local values = {1, 2, 3}
%}

assert({{#values}} == 3)

{% for i = 1, #values do %}
	assert({{values[i]}} == {{i}})
{% end %}

-- Table expansion
{%
	local values = {1, 2, 3}
%}

local vals = {}
{% for i = 1, #values do %}
	vals[{{i}}] = {{values[i]}}
{% end %}

assert(#vals == 3)
for i = 1, #vals do
	assert(vals[i] == i)
end
