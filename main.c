/*
** $Id: lua.c,v 1.230.1.1 2017/04/19 17:29:57 roberto Exp $
** Lua stand-alone interpreter
** See Copyright Notice in lua.h
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

static int report (lua_State *L, int status) {
  if (status != LUA_OK) {
    const char *msg = lua_tostring(L, -1);
    fprintf(stderr, "error: %s\n", msg);
    lua_pop(L, 1);  /* remove message */
  }
  return status;
}

struct mem_file {
  const char *name;
  const char *start;
  const char *end;
};

struct mem_cfile {
  const char *name;
  lua_CFunction func;
};

#include "_helper.inc"
#include "_chelper.inc"

static int my_loader(lua_State *L)
{
  const char *name = luaL_checkstring(L, 1);
  struct mem_file *p = _myfiles;
  struct mem_cfile *q = _mycfiles;

  for(; p->name; p++) {
    if (strcmp(name, p->name) == 0) {
      int status = luaL_loadbuffer(L, p->start, p->end - p->start, p->name);
      report(L, status);
      return 1;
    }
  }

  for(; q->name; q++) {
    if (strcmp(name, q->name) == 0) {
      lua_pushcfunction(L, q->func);
      return 1;
    }
  }

  return 0;
}

static int msghandler (lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  if (msg == NULL) {  /* is error object not a string? */
    if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
        lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
      return 1;  /* that is the message */
    else
      msg = lua_pushfstring(L, "(error object is a %s value)",
                               luaL_typename(L, 1));
  }
  luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
  return 1;  /* return the traceback */
}

/*
** Interface to 'lua_pcall', which sets appropriate message function
** and C-signal handler. Used to run all chunks.
*/
static int docall (lua_State *L, int narg, int nres) {
  int status;
  int base = lua_gettop(L) - narg;  /* function index */
  lua_pushcfunction(L, msghandler);  /* push message handler */
  lua_insert(L, base);  /* put it under function and args */
  status = lua_pcall(L, narg, nres, base);
  lua_remove(L, base);  /* remove message handler from the stack */
  return status;
}

static const char *stub =
  "table.insert(package.searchers, 1, my_loader)\n"
  "my_loader = nil\n";

static int pmain (lua_State *L) {
  int argc = (int)lua_tointeger(L, 1);
  char **argv = (char **)lua_touserdata(L, 2);
  luaL_checkversion(L);  /* check that interpreter has correct version */

  luaL_openlibs(L);  /* open standard libraries */

  lua_createtable(L, argc - 1, 1);
  for (int i = 0; i < argc; i++) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");

  lua_pushcfunction(L, my_loader);
  lua_setglobal(L, "my_loader");

  int status = luaL_dostring(L, stub);
  if (status == LUA_OK) {
    lua_pushcfunction(L, my_loader);
    lua_pushstring(L, "main");
    status = docall(L, 1, 1);
    if (status == LUA_OK) {
      status = docall(L, 0, 1);
    }
  }

  report(L, status);
  return status == LUA_OK;
}

int main (int argc, char **argv) {
  int status, result;
  lua_State *L = luaL_newstate();

  if (L == NULL)
    return EXIT_FAILURE;

  lua_pushcfunction(L, &pmain);
  lua_pushinteger(L, argc);
  lua_pushlightuserdata(L, argv);
  status = lua_pcall(L, 2, 1, 0);
  result = lua_toboolean(L, -1);
  report(L, status);
  lua_close(L);
  return (result && status == LUA_OK) ? EXIT_SUCCESS : EXIT_FAILURE;
}
