TOPDIR = ..
PROG = _build.o
OBJS = build.o lib.o
LUASRCS != cat luafiles

LDFLAGS = -r -nostdlib

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/lua.mk
include ${TOPDIR}/user.mk
