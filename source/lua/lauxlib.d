/*
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.d
*/

module lua.lauxlib;

import lua.lua;

import core.stdc.stdio : stdout, stderr, FILE, fwrite, fflush;

extern (C) @safe nothrow:

/* extra error code for 'luaL_load' */
enum LUA_ERRFILE = LUA_ERRERR + 1;

/* key, in the registry, for table of loaded modules */
enum LUA_LOADED_TABLE = "_LOADED";

/* key, in the registry, for table of preloaded loaders */
enum LUA_PRELOAD_TABLE = "_PRELOAD";

struct luaL_Reg {
    const(char)* name;
    lua_CFunction func;
}

enum LUAL_NUMSIZES = lua_Integer.sizeof * 16 + lua_Number.sizeof;

void luaL_checkversion_(lua_State* L, lua_Number ver, size_t sz);
void luaL_checkversion(lua_State* L) {
    luaL_checkversion_(L, LUA_VERSION_NUM, LUAL_NUMSIZES);
}

int luaL_getmetafield(lua_State* L, int obj, const(char)* e);
int luaL_callmeta(lua_State* L, int obj, const(char)* e);
const(char)* luaL_tolstring(lua_State* L, int idx, size_t* len);
int luaL_argerror(lua_State* L, int arg, const(char)* extramsg);
const(char)* luaL_checklstring(lua_State* L, int arg, size_t* l);
const(char)* luaL_optlstring(lua_State* L, int arg, const(char)* def, size_t* l);
lua_Number luaL_checknumber(lua_State* L, int arg);
lua_Number luaL_optnumber(lua_State* L, int arg, lua_Number def);

lua_Integer luaL_checkinteger(lua_State* L, int arg);
lua_Integer luaL_optinteger(lua_State* L, int arg, lua_Integer def);

void luaL_checkstack(lua_State* L, int sz, const(char)* msg);
void luaL_checktype(lua_State* L, int arg, int t);
void luaL_checkany(lua_State* L, int arg);

int luaL_newmetatable(lua_State* L, const(char)* tname);
void luaL_setmetatable(lua_State* L, const(char)* tname);
void* luaL_testudata(lua_State* L, int ud, const(char)* tname);
void* luaL_checkudata(lua_State* L, int ud, const(char)* tname);

void luaL_where(lua_State* L, int lvl);
int luaL_error(lua_State* L, const(char)* fmt, ...);

int luaL_checkoption(lua_State* L, int arg, const(char)* def, const(const(char)*)* lst);

int luaL_fileresult(lua_State* L, int stat, const(char)* fname);
int luaL_execresult(lua_State* L, int stat);

/* predefined references */
enum LUA_NOREF = -2;
enum LUA_REFNIL = -1;

int luaL_ref(lua_State* L, int t);
void luaL_unref(lua_State* L, int t, int ref_);

int luaL_loadfilex(lua_State* L, const(char)* filename, const(char)* mode);

pragma(inline, true) int luaL_loadfile(lua_State* L, const(char)* filename) {
    return luaL_loadfilex(L, filename, null);
}

int luaL_loadbufferx(lua_State* L, const(char)* buff, size_t sz,
    const(char)* name, const(char)* mode);
int luaL_loadstring(lua_State* L, const(char)* s);

lua_State* luaL_newstate();

lua_Integer luaL_len(lua_State* L, int idx);

const(char)* luaL_gsub(lua_State* L, const(char)* s, const(char)* p, const(char)* r);

void luaL_setfuncs(lua_State* L, const(luaL_Reg)* l, int nup);

int luaL_getsubtable(lua_State* L, int idx, const(char)* fname);

void luaL_traceback(lua_State* L, lua_State* L1, const(char)* msg, int level);

void luaL_requiref(lua_State* L, const(char)* modname, lua_CFunction openf, int glb);

/*
** ===============================================================
** some useful macros
** ===============================================================
*/

pragma(inline, true) {

    void luaL_newlibtable(lua_State* L, luaL_Reg[] l) {
        lua_createtable(L, 0, cast(int)(l.length - 1));
    }

    void luaL_newlib(lua_State* L, luaL_Reg[] l) {
        luaL_checkversion(L);
        luaL_newlibtable(L, l);
        luaL_setfuncs(L, &l[0], 0);
    }

    void luaL_argcheck(lua_State* L, bool cond, int arg, const(char)* extramsg) {
        (cond) || luaL_argerror(L, arg, extramsg);
    }

    const(char)* luaL_checkstring(lua_State* L, int arg) {
        return luaL_checklstring(L, arg, null);
    }

    const(char)* luaL_optstring(lua_State* L, int arg, const(char)* def) {
        return luaL_optlstring(L, arg, def, null);
    }

    const(char)* luaL_typename(lua_State* L, int tp) {
        return lua_typename(L, lua_type(L, tp));
    }

    int luaL_dofile(lua_State* L, const(char)* filename) {
        return cast(int)(luaL_loadfile(L, filename) || lua_pcall(L, 0, LUA_MULTRET,
            0));
    }

    int luaL_dostring(lua_State* L, const(char)* s) {
        return cast(int)(luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0));
    }

    int luaL_getmetatable(lua_State* L, const(char)* k) {
        return lua_getfield(L, LUA_REGISTRYINDEX, k);
    }

    auto luaL_opt(F, Default)(lua_State* L, F f, int n, lazy Default d) {
        return lua_isnoneornil(L, n) ? d : f(L, n);
    }

    int luaL_loadbuffer(lua_State* L, const(char)* buff, size_t sz, const(char)* name) {
        return luaL_loadbufferx(L, buff, sz, name, null);
    }

} // pragma(inline, true)

/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/
enum LUAL_BUFFERSIZE = cast(int)(0x80 * (void*).sizeof * lua_Integer.sizeof);

struct luaL_Buffer {
    char* b; /* buffer address */
    size_t size; /* buffer size */
    size_t n; /* number of characters in buffer */
    lua_State* L;
    char[LUAL_BUFFERSIZE] initb; /* initial buffer */
}

pragma(inline, true) @trusted void luaL_addchar(luaL_Buffer* B, char c) {
    B.n < B.size || luaL_prepbuffsize(B, 1);
    B.b[B.n++] = c;
}

pragma(inline, true) void luaL_addsize(luaL_Buffer* B, size_t s) {
    B.n += s;
}

void luaL_buffinit(lua_State* L, luaL_Buffer* B);
char* luaL_prepbuffsize(luaL_Buffer* B, size_t sz);
void luaL_addlstring(luaL_Buffer* B, const(char)* s, size_t l);
void luaL_addstring(luaL_Buffer* B, const(char)* s);
void luaL_addvalue(luaL_Buffer* B);
void luaL_pushresult(luaL_Buffer* B);
void luaL_pushresultsize(luaL_Buffer* B, size_t sz);
char* luaL_buffinitsize(lua_State* L, luaL_Buffer* B, size_t sz);

pragma(inline, true) char* luaL_prepbuffer(luaL_Buffer* B) {
    return luaL_prepbuffsize(B, LUAL_BUFFERSIZE);
}

/* }====================================================== */

/*
** {======================================================
** File handles for IO library
** =======================================================
*/

/*
** A file handle is a userdata with metatable 'LUA_FILEHANDLE' and
** initial structure 'luaL_Stream' (it may contain other fields
** after that initial structure).
*/

enum LUA_FILEHANDLE = "FILE*";

struct luaL_Stream {
    FILE* f; /* stream (NULL for incompletely created streams) */
    lua_CFunction closef; /* to close stream (NULL for closed streams) */
}

/* }====================================================== */

/* compatibility with old module system */
deprecated {

    void luaL_pushmodule(lua_State* L, const(char)* modname, int sizehint);
    void luaL_openlib(lua_State* L, const(char)* libname, const(luaL_Reg)* l, int nup);

    pragma(inline, true) void luaL_openlib(lua_State* L, const(char)* libname, const(luaL_Reg)* l) {
        luaL_openlib(L, libname, l, 0);
    }

}

/*
** {==================================================================
** "Abstraction Layer" for basic report of messages and errors
** ===================================================================
*/

/* print a string */
@trusted ulong lua_writestring(const(char)* s, size_t l) {
    return fwrite(s, char.sizeof, l, stdout);
}

pragma(inline, true) {

    /* print a newline and flush the output */
    void lua_writeline() {
        lua_writestring("\n", 1);
        stdout.fflush;
    }

    /* print an error message */
    void lua_writestringerror(Args...)(const(char)* s, auto ref Args args) {
        fprintf(stderr, s, args);
        stderr.fflush;
    }

} // pragma(inline, true)

/* }================================================================== */

/*
** {============================================================
** Compatibility with deprecated conversions
** =============================================================
*/
deprecated pragma(inline, true) {

    lua_Unsigned luaL_checkunsigned(lua_State* L, int arg) {
        return cast(lua_Unsigned) luaL_checkinteger(L, arg);
    }

    lua_Unsigned luaL_optunsigned(lua_State* L, int arg, lua_Integer def) {
        return cast(lua_Unsigned) luaL_optinteger(L, arg, def);
    }

    int luaL_checkint(lua_State* L, int arg) {
        return cast(int) luaL_checkinteger(L, arg);
    }

    int luaL_optint(lua_State* L, int arg, lua_Integer def) {
        return cast(int) luaL_optinteger(L, arg, def);
    }

    long luaL_checklong(lua_State* L, int arg) {
        return cast(long) luaL_checkinteger(L, arg);
    }

    long luaL_optlong(lua_State* L, int arg, lua_Integer def) {
        return cast(long) luaL_optinteger(L, arg, def);
    }

}
/* }============================================================ */
