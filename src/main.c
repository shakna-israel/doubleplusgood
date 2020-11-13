// stdlib
#include <stdint.h>
#include <string.h>

// Vendor
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

// Ours
#include <template.h>

uint32_t adler32(const char* key, size_t length) {
	uint32_t sa = 1;
	uint32_t sb = 0;
	for(size_t i = 0; i < length; i++) {
		sa = (sa + (uint32_t)key[i]) % 65521;
		sb = (sb + sa) % 65521;
	}
	return (sb << 16) | sa;
}

int LuaAdler32(lua_State* L) {
	int t = lua_type(L, 1);
	if(t != LUA_TSTRING) {
		// Wrong type!
		lua_pushnil(L);
		return 1;
	}

	size_t length = 0;
	const char* str = lua_tolstring(L, -1, &length);

	uint32_t ret = adler32(str, length);
	lua_pushnumber(L, ret);
	return 1;
}

int main(int argc, char* argv[]) {
	lua_State* L = luaL_newstate();

	// Open all standard libraries...
	luaL_openlibs(L);

	// Expose our hash function
	lua_register(L, "adler32", LuaAdler32);

	// Load the template library...
	lua_pushlstring(L, src_template_lua, src_template_lua_len);
	lua_setglobal(L, "template");
	luaL_dostring(L, "return load(template)()");
	lua_setglobal(L, "template");

	int expand_mode = 0;
	int argc_offset = 1;
	if(argc > 2) {
		if(strcmp(argv[1], "-E") == 0 ||
			strcmp(argv[1], "--expand") == 0)
		{
			argc_offset = 2;
			expand_mode = 1;
		}
	}

	// Build the arg library...
	lua_createtable(L, 0, 0);
	for(int i = 0; i < argc; i++) {
		lua_pushnumber(L, i - argc_offset);
		lua_pushstring(L, argv[i]);
		lua_settable(L, -3);
	}
	lua_setglobal(L, "arg");

	if(luaL_dostring(L, "return template.renderfile(arg[0])")) {
		// Error
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_close(L);
		return 1;
	}

	size_t length = 0;
	const char* value = lua_tolstring(L, -1, &length);

	// Are we just expanding?
	if(expand_mode) {
		printf("%s\n", value);
		lua_close(L);
		return 0;
	}

	lua_getglobal(L, "load");
	lua_pushlstring(L, value, length);
	if(lua_pcall(L, 1, LUA_MULTRET, 0) != LUA_OK) {
		// Error
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_close(L);
		return 1;
	}

	if(lua_type(L, -1) != LUA_TFUNCTION) {
		// Error
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_close(L);
		return 1;
	}

	if(lua_pcall(L, 0, LUA_MULTRET, 0) != LUA_OK) {
		// Error
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_close(L);
		return 1;
	}

	lua_close(L);
	return 0;
}
