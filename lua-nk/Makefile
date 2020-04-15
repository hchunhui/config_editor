export PLAT ?= x11
TOPDIR = ..
SUBDIRS = lib
SUBMAKES = build.mk shared-${PLAT}.mk static.mk

include ${TOPDIR}/make/comm.mk

shared-${PLAT}.mk.all: build.mk.all lib.all
static.mk.all: build.mk.all lib.all
