TOPDIR = ..
PROG = lib.o
CXXSRCS = lib/lua.cc
CSRCS = lib/lutf8lib-compat.c lib/lauxlib-compat.c

LDFLAGS = -r -nostdlib

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk
include ${TOPDIR}/user.mk
