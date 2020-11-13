-- Test adler32
assert(adler32("Hello, World!") == 530449514)
assert(adler32("20;S~IV\"V`kDvdQAbs@k:{WE<0)re/@YX$swF7M+F\"CZ4%{tBS") == 2331578179)
assert(adler32("/.i_=oJM:-BPB*7FF\"e6ijVThG@69;-J}GGTMaWQ{;`}oBKK)w") == 1845235466)
assert(adler32("Wikipedia") == 300286872)
assert(adler32(10) == nil)
assert(adler32({}) == nil)
assert(adler32(10.2) == nil)

-- Test template library

-- BLOCKING: We need to be able to escape before we test this correctly...
-- TODO: Test template.render without model...
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
