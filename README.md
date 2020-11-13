# doubleplusgood

Lua, with a macro engine, in Lua.

---

# A Taste

	{%
		local value = "Hello, World!"
	%}

	local x = "{{value}}"
	print(x)

As you can see, the macro engine is itself written using Lua, instead of something that doesn't quite feel like that language, or feels like it doesn't belong.

---

## Macro Engine

TODO: Details on the constraints and syntax of the macro engine.

Lua code but turning things "inside out".

Most things get converted to a string.

+ Strings are using `[===[` and `]===]` as the outer symbols. So avoid those.

+ Things inside `{%` and `%}` get treated as a Lua statement.

+ Things inside `{{` and `}}` get placed inside tostring.

---

## Building

### Dependencies

+ Lua 5.3 development files

+ xxd

+ pkg-config

+ C-compiler

+ make

### Build

Run: `make`

### Install

Run: `make install`

---

# License

3-Clause BSD, as of writing. This is not a substitute for the legal text.

See the `LICENSE.md` file for legal text.
