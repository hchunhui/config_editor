TOPDIR = ..
PROG = build.o
CXXSRCS = types.cc xmain.cc

LDFLAGS = -r -nostdlib

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk
include ${TOPDIR}/user.mk

