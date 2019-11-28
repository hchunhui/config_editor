TOPDIR = .
SELF ?= thirdparty-win32.mk
LIB = liblua-win32.a
CSRCS = \
 thirdparty/lua5.3/lapi.c \
 thirdparty/lua5.3/lauxlib.c \
 thirdparty/lua5.3/lbaselib.c \
 thirdparty/lua5.3/lbitlib.c \
 thirdparty/lua5.3/lcode.c \
 thirdparty/lua5.3/lcorolib.c \
 thirdparty/lua5.3/lctype.c \
 thirdparty/lua5.3/ldblib.c \
 thirdparty/lua5.3/ldebug.c \
 thirdparty/lua5.3/ldo.c \
 thirdparty/lua5.3/ldump.c \
 thirdparty/lua5.3/lfunc.c \
 thirdparty/lua5.3/lgc.c \
 thirdparty/lua5.3/linit.c \
 thirdparty/lua5.3/liolib.c \
 thirdparty/lua5.3/llex.c \
 thirdparty/lua5.3/lmathlib.c \
 thirdparty/lua5.3/lmem.c \
 thirdparty/lua5.3/loadlib.c \
 thirdparty/lua5.3/lobject.c \
 thirdparty/lua5.3/lopcodes.c \
 thirdparty/lua5.3/loslib.c \
 thirdparty/lua5.3/lparser.c \
 thirdparty/lua5.3/lstate.c \
 thirdparty/lua5.3/lstring.c \
 thirdparty/lua5.3/lstrlib.c \
 thirdparty/lua5.3/ltable.c \
 thirdparty/lua5.3/ltablib.c \
 thirdparty/lua5.3/ltm.c \
 thirdparty/lua5.3/lundump.c \
 thirdparty/lua5.3/lutf8lib.c \
 thirdparty/lua5.3/lvm.c \
 thirdparty/lua5.3/lzio.c



include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk

CC = i686-w64-mingw32-gcc
AR = i686-w64-mingw32-ar
CFLAGS = -Os -fPIC -DLUA_COMPAT_5_2
