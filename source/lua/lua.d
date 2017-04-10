/*
** Lua - A Scripting Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*/

module lua.lua;

import core.stdc.stdarg;
import core.stdc.stddef;

extern (C) @safe nothrow:

enum LUA_VERSION_MAJOR = "5";
enum LUA_VERSION_MINOR = "3";
enum LUA_VERSION_NUM = 503;
enum LUA_VERSION_RELEASE = "4";

enum LUA_VERSION = "Lua " ~ LUA_VERSION_MAJOR ~ "." ~ LUA_VERSION_MINOR;
enum LUA_RELEASE = LUA_VERSION ~ "." ~ LUA_VERSION_RELEASE;
enum LUA_COPYRIGHT = LUA_RELEASE ~ " Copyright (C) 1994-2017 Lua.org, PUC-Rio";
enum LUA_AUTHORS = "R. Ierusalimschy, L. H. de Figueiredo, W. Celes";

/* mark for precompiled code ('<esc>Lua') */
enum LUA_SIGNATURE = "\x1bLua";

/* option for multiple returns in 'lua_pcall' and 'lua_call' */
enum LUA_MULTRET = -1;

/*
** Pseudo-indices
** (-LUAI_MAXSTACK is the minimum valid index; we keep some free empty
** space after that to help overflow detection)
*/
enum LUAI_MAXSTACK = 1000000;

enum LUA_REGISTRYINDEX = -LUAI_MAXSTACK - 1000;
pragma(inline, true) auto lua_upvalueindex(T)(T i) {
    return LUA_REGISTRYINDEX - i;
}

/* thread status */
enum LUA_OK = 0;
enum LUA_YIELD = 1;
enum LUA_ERRRUN = 2;
enum LUA_ERRSYNTAX = 3;
enum LUA_ERRMEM = 4;
enum LUA_ERRGCMM = 5;
enum LUA_ERRERR = 6;

struct lua_State;

/*
** basic types
*/
enum LUA_TNONE = -1;

enum LUA_TNIL = 0;
enum LUA_TBOOLEAN = 1;
enum LUA_TLIGHTUSERDATA = 2;
enum LUA_TNUMBER = 3;
enum LUA_TSTRING = 4;
enum LUA_TTABLE = 5;
enum LUA_TFUNCTION = 6;
enum LUA_TUSERDATA = 7;
enum LUA_TTHREAD = 8;

enum LUA_NUMTAGS = 9;

/* minimum Lua stack available to a C function */
enum LUA_MINSTACK = 20;

/* predefined values in the registry */
enum LUA_RIDX_MAINTHREAD = 1;
enum LUA_RIDX_GLOBALS = 2;
enum LUA_RIDX_LAST = LUA_RIDX_GLOBALS;

/* type of numbers in Lua */
alias lua_Number = double;

/* type for integer functions */
alias lua_Integer = long;

/* unsigned integer type */
alias lua_Unsigned = ulong;

/* type for continuation-function contexts */
alias lua_KContext = ptrdiff_t;

/*
** Type for C functions registered with Lua
*/
alias lua_CFunction = int function(lua_State* L);

/*
** Type for continuation functions
*/
alias lua_KFunction = int function(lua_State* L, int status, lua_KContext ctx);

/*
** Type for functions that read/write blocks when loading/dumping Lua chunks
*/
alias lua_Reader = const(char)* function(lua_State* L, void* ud, size_t* sz);

alias lua_Writer = int function(lua_State* L, const(void)* p, size_t sz, void* ud);

/*
** Type for memory-allocation functions
*/
alias lua_Alloc = void* function(void* ud, void* ptr, size_t osize, size_t nsize);

/*
** RCS ident string
*/
const(char)* lua_ident;

/*
** state manipulation
*/
lua_State* lua_newstate(lua_Alloc f, void* ud);
void lua_close(lua_State* L);
lua_State* lua_newthread(lua_State* L);

lua_CFunction lua_atpanic(lua_State* L, lua_CFunction panicf);

const(lua_Number)* lua_version(lua_State* L);

/*
** basic stack manipulation
*/
int lua_absindex(lua_State* L, int idx);
int lua_gettop(lua_State* L);
void lua_settop(lua_State* L, int idx);
void lua_pushvalue(lua_State* L, int idx);
void lua_rotate(lua_State* L, int idx, int n);
void lua_copy(lua_State* L, int fromidx, int toidx);
int lua_checkstack(lua_State* L, int n);

void lua_xmove(lua_State* from, lua_State* to, int n);

/*
** access functions (stack -> C)
*/

int lua_isnumber(lua_State* L, int idx);
int lua_isstring(lua_State* L, int idx);
int lua_iscfunction(lua_State* L, int idx);
int lua_isinteger(lua_State* L, int idx);
int lua_isuserdata(lua_State* L, int idx);
int lua_type(lua_State* L, int idx);
const(char)* lua_typename(lua_State* L, int tp);

lua_Number lua_tonumberx(lua_State* L, int idx, int* isnum);
lua_Integer lua_tointegerx(lua_State* L, int idx, int* isnum);
int lua_toboolean(lua_State* L, int idx);
const(char)* lua_tolstring(lua_State* L, int idx, size_t* len);
size_t lua_rawlen(lua_State* L, int idx);
lua_CFunction lua_tocfunction(lua_State* L, int idx);
void* lua_touserdata(lua_State* L, int idx);
lua_State* lua_tothread(lua_State* L, int idx);
const(void)* lua_topointer(lua_State* L, int idx);

/*
** Comparison and arithmetic functions
*/

enum LUA_OPADD = 0; /* ORDER TM, ORDER OP */
enum LUA_OPSUB = 1;
enum LUA_OPMUL = 2;
enum LUA_OPMOD = 3;
enum LUA_OPPOW = 4;
enum LUA_OPDIV = 5;
enum LUA_OPIDIV = 6;
enum LUA_OPBAND = 7;
enum LUA_OPBOR = 8;
enum LUA_OPBXOR = 9;
enum LUA_OPSHL = 10;
enum LUA_OPSHR = 11;
enum LUA_OPUNM = 12;
enum LUA_OPBNOT = 13;

void lua_arith(lua_State* L, int op);

enum LUA_OPEQ = 0;
enum LUA_OPLT = 1;
enum LUA_OPLE = 2;

int lua_rawequal(lua_State* L, int idx1, int idx2);
int lua_compare(lua_State* L, int idx1, int idx2, int op);

/*
** push functions (C -> stack)
*/
void lua_pushnil(lua_State* L);
void lua_pushnumber(lua_State* L, lua_Number n);
void lua_pushinteger(lua_State* L, lua_Integer n);
const(char)* lua_pushlstring(lua_State* L, const(char)* s, size_t len);
const(char)* lua_pushstring(lua_State* L, const(char)* s);
const(char)* lua_pushvfstring(lua_State* L, const(char)* fmt, va_list argp);
const(char)* lua_pushfstring(lua_State* L, const(char)* fmt, ...);
void lua_pushcclosure(lua_State* L, lua_CFunction fn, int n);
void lua_pushboolean(lua_State* L, int b);
void lua_pushlightuserdata(lua_State* L, void* p);
int lua_pushthread(lua_State* L);

/*
** get functions (Lua -> stack)
*/
int lua_getglobal(lua_State* L, const(char)* name);
int lua_gettable(lua_State* L, int idx);
int lua_getfield(lua_State* L, int idx, const(char)* k);
int lua_geti(lua_State* L, int idx, lua_Integer n);
int lua_rawget(lua_State* L, int idx);
int lua_rawgeti(lua_State* L, int idx, lua_Integer n);
int lua_rawgetp(lua_State* L, int idx, const(void)* p);

void lua_createtable(lua_State* L, int narr, int nrec);
void* lua_newuserdata(lua_State* L, size_t sz);
int lua_getmetatable(lua_State* L, int objindex);
int lua_getuservalue(lua_State* L, int idx);

/*
** set functions (stack -> Lua)
*/
void lua_setglobal(lua_State* L, const(char)* name);
void lua_settable(lua_State* L, int idx);
void lua_setfield(lua_State* L, int idx, const(char)* k);
void lua_seti(lua_State* L, int idx, lua_Integer n);
void lua_rawset(lua_State* L, int idx);
void lua_rawseti(lua_State* L, int idx, lua_Integer n);
void lua_rawsetp(lua_State* L, int idx, const(void)* p);
int lua_setmetatable(lua_State* L, int objindex);
void lua_setuservalue(lua_State* L, int idx);

/*
** 'load' and 'call' functions (load and run Lua code)
*/
void lua_callk(lua_State* L, int nargs, int nresults, lua_KContext ctx, lua_KFunction k);

pragma(inline, true) void lua_call(lua_State* L, int nargs, int nresults) {
    lua_callk(L, nargs, nresults, 0, null);
}

int lua_pcallk(lua_State* L, int nargs, int nresults, int errfunc, lua_KContext ctx,
    lua_KFunction k);

pragma(inline, true) int lua_pcall(lua_State* L, int nargs, int nresults, int errfunc) {
    return lua_pcallk(L, nargs, nresults, errfunc, 0, null);
}

int lua_load(lua_State* L, lua_Reader reader, void* dt, const(char)* chunkname, const(char)* mode);

int lua_dump(lua_State* L, lua_Writer writer, void* data, int strip);

/*
** coroutine functions
*/
int lua_yieldk(lua_State* L, int nresults, lua_KContext ctx, lua_KFunction k);
int lua_resume(lua_State* L, lua_State* from, int narg);
int lua_status(lua_State* L);
int lua_isyieldable(lua_State* L);

pragma(inline, true) int lua_yield(lua_State* L, int nresults) {
    return lua_yieldk(L, nresults, 0, null);
}

/*
** garbage-collection function and options
*/

enum LUA_GCSTOP = 0;
enum LUA_GCRESTART = 1;
enum LUA_GCCOLLECT = 2;
enum LUA_GCCOUNT = 3;
enum LUA_GCCOUNTB = 4;
enum LUA_GCSTEP = 5;
enum LUA_GCSETPAUSE = 6;
enum LUA_GCSETSTEPMUL = 7;
enum LUA_GCISRUNNING = 9;

int lua_gc(lua_State* L, int what, int data);

/*
** miscellaneous functions
*/

int lua_error(lua_State* L);

int lua_next(lua_State* L, int idx);

void lua_concat(lua_State* L, int n);
void lua_len(lua_State* L, int idx);

size_t lua_stringtonumber(lua_State* L, const(char)* s);

lua_Alloc lua_getallocf(lua_State* L, void** ud);
void lua_setallocf(lua_State* L, lua_Alloc f, void* ud);

/*
** {==============================================================
** some useful macros
** ===============================================================
*/
enum LUA_EXTRASPACE = (void*).sizeof;

pragma(inline, true) {

    @trusted void* lua_getextraspace(lua_State* L) {
        return cast(void*)(cast(char*)(L) - LUA_EXTRASPACE);
    }

    lua_Number lua_tonumber(lua_State* L, int idx) {
        return lua_tonumberx(L, idx, null);
    }

    lua_Integer lua_tointeger(lua_State* L, int idx) {
        return lua_tointegerx(L, idx, null);
    }

    void lua_pop(lua_State* L, int idx) {
        lua_settop(L, -idx - 1);
    }

    void lua_newtable(lua_State* L) {
        lua_createtable(L, 0, 0);
    }

    void lua_register(lua_State* L, const(char)* name, lua_CFunction fn) {
        lua_pushcfunction(L, fn);
        lua_setglobal(L, name);
    }

    void lua_pushcfunction(lua_State* L, lua_CFunction fn) {
        lua_pushcclosure(L, fn, 0);
    }

    bool lua_isfunction(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TFUNCTION;
    }

    bool lua_istable(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TTABLE;
    }

    bool lua_islightuserdata(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TLIGHTUSERDATA;
    }

    bool lua_isnil(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TNIL;
    }

    bool lua_isboolean(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TBOOLEAN;
    }

    bool lua_isthread(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TTHREAD;
    }

    bool lua_isnone(lua_State* L, int idx) {
        return lua_type(L, idx) == LUA_TNONE;
    }

    bool lua_isnoneornil(lua_State* L, int idx) {
        return lua_type(L, idx) <= 0;
    }

    const(char)* lua_pushliteral(lua_State* L, const(char)* s) {
        return lua_pushstring(L, s);
    }

    void lua_pushglobaltable(lua_State* L) {
        lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
    }

    const(char)* lua_tostring(lua_State* L, int idx) {
        return lua_tolstring(L, idx, null);
    }

    void lua_insert(lua_State* L, int idx) {
        lua_rotate(L, idx, 1);
    }

    void lua_remove(lua_State* L, int idx) {
        lua_rotate(L, idx, -1);
        lua_pop(L, 1);
    }

    void lua_replace(lua_State* L, int idx) {
        lua_copy(L, -1, idx);
        lua_pop(L, 1);
    }

} // pragma(inline, true)

/* }============================================================== */

/*
** {==============================================================
** compatibility macros for unsigned conversions
** ===============================================================
*/

pragma(inline, true) {

    void lua_pushunsigned(lua_State* L, lua_Integer n) {
        lua_pushinteger(L, n);
    }

    // lua_Integer     lua_tointegerx (lua_State *L, int idx, int *isnum);
    lua_Unsigned lua_tounsignedx(lua_State* L, int idx, int* isnum) {
        return cast(lua_Unsigned) lua_tointegerx(L, idx, isnum);
    }

    lua_Unsigned lua_tounsigned(lua_State* L, int idx) {
        return lua_tounsignedx(L, idx, null);
    }

} // pragma(inline, true)

/* }============================================================== */

/*
** {======================================================================
** Debug API
** =======================================================================
*/

/*
** Event codes
*/
enum LUA_HOOKCALL = 0;
enum LUA_HOOKRET = 1;
enum LUA_HOOKLINE = 2;
enum LUA_HOOKCOUNT = 3;
enum LUA_HOOKTAILCALL = 4;

/*
** Event masks
*/
enum LUA_MASKCALL = 1 << LUA_HOOKCALL;
enum LUA_MASKRET = 1 << LUA_HOOKRET;
enum LUA_MASKLINE = 1 << LUA_HOOKLINE;
enum LUA_MASKCOUNT = 1 << LUA_HOOKCOUNT;

/* Functions to be called by the debugger in specific events */
alias lua_Hook = void function(lua_State* L, lua_Debug* ar);

int lua_getstack(lua_State* L, int level, lua_Debug* ar);
int lua_getinfo(lua_State* L, const(char)* what, lua_Debug* ar);
const(char)* lua_getlocal(lua_State* L, const(lua_Debug)* ar, int n);
const(char)* lua_setlocal(lua_State* L, const(lua_Debug)* ar, int n);
const(char)* lua_getupvalue(lua_State* L, int funcindex, int n);
const(char)* lua_setupvalue(lua_State* L, int funcindex, int n);

void* lua_upvalueid(lua_State* L, int fidx, int n);
void lua_upvaluejoin(lua_State* L, int fidx1, int n1, int fidx2, int n2);

void lua_sethook(lua_State* L, lua_Hook func, int mask, int count);
lua_Hook lua_gethook(lua_State* L);
int lua_gethookmask(lua_State* L);
int lua_gethookcount(lua_State* L);

struct CallInfo;

enum LUA_IDSIZE = 60;

struct lua_Debug {
    int event;
    const(char)* name; /* (n) */
    const(char)* namewhat; /* (n) 'global', 'local', 'field', 'method' */
    const(char)* what; /* (S) 'Lua', 'C', 'main', 'tail' */
    const(char)* source; /* (S) */
    int currentline; /* (l) */
    int linedefined; /* (S) */
    int lastlinedefined; /* (S) */
    ubyte nups; /* (u) number of upvalues */
    ubyte nparams; /* (u) number of parameters */
    char isvararg; /* (u) */
    char istailcall; /* (t) */
    char[LUA_IDSIZE] short_src; /* (S) */
    /* private part */
    CallInfo* i_ci; /* active function */
}

/* }====================================================================== */

/******************************************************************************
* Copyright (C) 1994-2017 Lua.org, PUC-Rio.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/
