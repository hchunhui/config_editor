SUBDIRS = lua-nk scripts

export PLAT ?= x11
TOPDIR = .
PROG = main.exe
CSRCS = main.c
OBJS += ${SUBDIRS:=/_build.o}

LDFLAGS = ${LUA_LDFLAGS} ${NK_LDFLAGS} -Wl,--strip-all -Wl,-gc-sections

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk
include ${TOPDIR}/user.mk

.PHONY: clean_helper

_helper.inc: ${SUBDIRS:=/luafiles}
	${Q}./mkhelper $^$> > $@

_chelper.inc: ${SUBDIRS:=/modules}
	${Q}./mkchelper $^$> > $@

main.c: _helper.inc _chelper.inc

clean_helper:
	${Q}rm -f _helper.inc _chelper.inc

clean: clean_helper
