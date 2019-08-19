TOPDIR = ..
PROG = driver
CSRCS = main.c
OBJS += ${TOPDIR}/lua-nk/nk.a
OBJS += ${TOPDIR}/scripts/_build.o

LDFLAGS = ${LUA_LDFLAGS} ${NK_LDFLAGS} -Wl,--strip-all -Wl,-gc-sections

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk
include ${TOPDIR}/user.mk
