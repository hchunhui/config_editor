export PLAT ?= x11
TOPDIR = ..
PROG = _build.o
LUASRCS != cat luafiles

LDFLAGS = -r -nostdlib

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/lua.mk
include ${TOPDIR}/user.mk

