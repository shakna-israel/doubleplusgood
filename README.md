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

### Running Order

When a file is called by doubleplusgood, it:

+ Assembles the argument table, `arg`.

+ Creates the `template` library and the `adler32` function.

+ Checks if you're just trying to expand the given file.

+ Renders the file using the template engine, including any `include`s.

	+ If an error happens at any point in this process, it bails out.

+ Loads the resulting source code.

	+ If an error happens at any point in this process, it bails out.

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

+ WARNING: The engine uses a few functions beginning with `__`, so those are banned. (This is intended to be fixed in the future, but is low priority).

+ Things inside `{%` and `%}` get treated as a raw Lua statement.

+ Things inside `{{` and `}}` get replaced via a call to tostring.

+ Escaping: Like in Lua, the macro engine will escape on `\`. However, it does this at macro expansion. Which means if you want it during the Lua evaluation time, you'll probably need to double escape.

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

## Template Library

Once all macros are expanded, we enter the evaluation phase of the expanded Lua file.

An extra library is made available to this Lua environment, called `template` that allows you to use the macro expander.

### template.renderfile

	template.renderfile(filename, [model])

This either `false` or the result of calling `template.render` against the contents of `filename`.

### template.render

	template.render(string, [model])

This takes a given string, and expands it with either the given model, or the default model (see `Limited Environment`).

If an error occurs, prints a message to stderr, and returns `false`.

Otherwise, returns a `string`.

This function also takes advantage of aggressive cacheing, using an Adler32 hash of `string` as the key to store a function that can be passed a model to get a result. This means cached values shouldn't generally result in stale values, but you may notice mild performance increases when making heavy use of `include`.

### template.cache_maxsize

This is an integer value used by the template engine's cache. It is set to a reasonable default, but you can increase/decrease it if you truly believe you're hitting issues.

### template.clearcache

	template.clearcache()

Clears the template engine's cache, and calls Lua's garbage collector.

### template.version

A string representing the version of `doubleplusgood` in use.

## Adler Hash

Once all macros are expanded, we enter the evaluation phase of the expanded Lua file.

An extra global function is made available to this Lua environment, used by the `template` library, called `adler32`.

	adler32(string) -> integer

This converts a given string to an integer using the 32-bit Adler checksum hash. This is a _non-cryptographic_ hash, but useful enough for some purposes.

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

### Testing

[![builds.sr.ht status](https://builds.sr.ht/~shakna/doublegoodplus.svg)](https://builds.sr.ht/~shakna/doublegoodplus?)

Run: `make test`

---

# License

3-Clause BSD, as of writing. This is not a substitute for the legal text.

See the `LICENSE.md` file for legal text.
