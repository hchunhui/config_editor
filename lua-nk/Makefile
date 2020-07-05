export PLAT ?= x11
TOPDIR = ..
SUBMAKES = lib.mk build.mk shared-${PLAT}.mk static.mk

include ${TOPDIR}/make/comm.mk

shared-${PLAT}.mk.all: build.mk.all lib.mk.all
static.mk.all: build.mk.all lib.mk.all
