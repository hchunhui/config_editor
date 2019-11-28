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
