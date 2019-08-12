TOPDIR = ..
PROG = _build.o
CSRCS = _helper.c
LUASRCS = yaml.lua yaml/parser.lua yaml/printer.lua yaml/prim.lua nk.lua tree.lua main.lua

LDFLAGS = -r -nostdlib

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk

.PHONY: clean_helper

_helper.c: ${LUASRCS} Makefile
	${Q}./mkhelper ${LUASRCS} > $@

clean_helper:
	${Q}rm -f _helper.c

clean: clean_helper


.PHONY: clean_lua
.SUFFIXES: .lua

LUAOBJS = ${LUASRCS:.lua=.o}
OBJS += ${LUAOBJS}

${LIB}: ${LUAOBJS}
${PROG}: ${LUAOBJS}

.lua.o:
	@${TOPDIR}/make/scripts/out.sh LUAC "$<" "$@"
	${Q}${LD} -r -nostdlib -b binary $< -o $@

clean_lua:
	${Q}rm -f ${LUAOBJS}

clean: clean_lua
