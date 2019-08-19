TOPDIR = ..
PROG = nk.so
OBJS = build.o lib/build.o

LDFLAGS = -shared ${NK_LDFLAGS}

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk
include ${TOPDIR}/user.mk
