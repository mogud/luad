/*
** Lua standard libraries
** See Copyright Notice in lua.d
*/

module lua.lualib;

import lua.lua;

extern (C) @safe nothrow:

/* version suffix for environment variable names */
enum LUA_VERSUFFIX = "_" ~ LUA_VERSION_MAJOR ~ "_" ~ LUA_VERSION_MINOR;

int luaopen_base (lua_State *L);

enum LUA_COLIBNAME = "coroutine";
int luaopen_coroutine (lua_State *L);

enum LUA_TABLIBNAME = "table";
int luaopen_table (lua_State *L);

enum LUA_IOLIBNAME = "io";
int luaopen_io (lua_State *L);

enum LUA_OSLIBNAME = "os";
int luaopen_os (lua_State *L);

enum LUA_STRLIBNAME = "string";
int luaopen_string (lua_State *L);

enum LUA_UTF8LIBNAME = "utf8";
int luaopen_utf8 (lua_State *L);

enum LUA_BITLIBNAME = "bit32";
int luaopen_bit32 (lua_State *L);

enum LUA_MATHLIBNAME = "math";
int luaopen_math (lua_State *L);

enum LUA_DBLIBNAME = "debug";
int luaopen_debug (lua_State *L);

enum LUA_LOADLIBNAME = "package";
int luaopen_package (lua_State *L);


/* open all previous libraries */
void luaL_openlibs (lua_State *L);

pragma(inline, true)
void lua_assert(T)(T) {}
