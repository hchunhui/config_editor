TOPDIR = .
SUBDIRS = lua-nk scripts driver

include ${TOPDIR}/make/comm.mk

driver.all: lua-nk.all scripts.all
