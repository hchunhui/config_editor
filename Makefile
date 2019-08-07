TOPDIR = .
SUBDIRS = lua-nk driver scripts

include ${TOPDIR}/make/comm.mk

driver.all: lua-nk.all
scripts.all: driver.all lua-nk.all
