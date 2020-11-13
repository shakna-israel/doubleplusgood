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

## Running

	doubleplusgood luafile args...

The basic way to run against a file. The `arg` table will be constructed, where `arg[0]` is the Lua file being expanded.

However, as we're dealing with macros, you may sometimes wish to see the expanded file. To do that, the _first_ argument should be `-E` or `--expand`:

	doubleplusgood --expand luafile args...

---

## Macro Engine

### Preprocessor Type: Text

There are generally two types of macro preprocessors.

The first kind is a simple text-replacement engine. (ala C-preprocessor).

The second operates against tokens that are syntactically valid. (ala Lisp).

This is the former. (C-like).

---

### Syntax Overview

The basic syntax of the preprocessor is extremely simple.

+ WARNING: String interning uses `[===[` and `]===]` as the outer symbols. So using these may break the template engine. (This is intended to be fixed in the future, but is low priority).

+ WARNING: The engine uses a few functions beginning with `__`, so those are banned. (This is intended to be fixed in the futre, but is low priority).

+ Things inside `{%` and `%}` get treated as a raw Lua statement.

+ Things inside `{{` and `}}` get replaced via a call to tostring.

+ Like Lua, the engine is whitespace agnostic.

---

### Capabilities

Unlike the C-preprocessor, we can do a hell of a lot more than simple text & replace.

For example, you might want to do something with some repetition:

	{%
		local values = {
			a = 21,
			b = 7,
			c = 2,
			d = 41 }
	%}

	{% for k, v in pairs(values) do %}
	local {{k}} = {{v}}
	{% end %}

	-- TODO: Other code here...

	{% for k, v in pairs(values) do %}
	print({{k}})
	{% end %}

This code creates a new local for each key in `values`, and then later prints it. The code expands to:

	local b  = 7 
	 
	local c  = 2 
	 
	local d  = 41 
	 
	local a  = 21 
	 

	 
	print(b )
	 
	print(c )
	 
	print(d )
	 
	print(a )

The usual caveats about ordering and `pairs` apply, because we are just running some Lua code to produce our macro expansion.

However, the engine does _not_ come with the full power of Lua. Though it could, this artificial limitation is done on purpose to contrain the engine and not tempt the programmer to make a hash of things.

#### Limited Environment

The environment that the preprocessor uses is absolutely Lua. You can use infinite while loops and so on, if you're insane.

However, it intentionally limits what functions you have available to a bare handful, so that you aren't tempted to construct overly difficult-to-understand code:

+ ipairs

+ pairs

+ next

+ type

+ format (from the `string` library)

+ include

	+ include(filename, [model]) -> string

	+ This function allows you to inject the results of another file, after macro preprocessing.

	+ If the model is not supplied, runs within the environment of the current file being preprocessed.

	+ If the model is supplied (a table), then the limited environment is copied into the model, and then the file is preprocessed and returned.

Within the limited environment, `_G` will always point to the `model`.

This, of course, does _not_ prevent you from creating your own data structures, functions, and so on, to use within the macro preprocessor, and we don't want to discourage that - If making a function makes things clearer or simpler, do so.

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
