-- Test adler32
assert(adler32("Hello, World!") == 530449514)
assert(adler32("20;S~IV\"V`kDvdQAbs@k:{WE<0)re/@YX$swF7M+F\"CZ4%{tBS") == 2331578179)
assert(adler32("/.i_=oJM:-BPB*7FF\"e6ijVThG@69;-J}GGTMaWQ{;`}oBKK)w") == 1845235466)
assert(adler32("Wikipedia") == 300286872)
assert(adler32(10) == nil)
assert(adler32({}) == nil)
assert(adler32(10.2) == nil)

-- TODO: Test template library

-- TODO: Test expansions
