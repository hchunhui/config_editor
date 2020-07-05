TOPDIR = .
SELF ?= thirdparty.mk
LIB = liblua.a
CSRCS = \
 thirdparty/lua5.4/lapi.c \
 thirdparty/lua5.4/lauxlib.c \
 thirdparty/lua5.4/lbaselib.c \
 thirdparty/lua5.4/lcode.c \
 thirdparty/lua5.4/lcorolib.c \
 thirdparty/lua5.4/lctype.c \
 thirdparty/lua5.4/ldblib.c \
 thirdparty/lua5.4/ldebug.c \
 thirdparty/lua5.4/ldo.c \
 thirdparty/lua5.4/ldump.c \
 thirdparty/lua5.4/lfunc.c \
 thirdparty/lua5.4/lgc.c \
 thirdparty/lua5.4/linit.c \
 thirdparty/lua5.4/liolib.c \
 thirdparty/lua5.4/llex.c \
 thirdparty/lua5.4/lmathlib.c \
 thirdparty/lua5.4/lmem.c \
 thirdparty/lua5.4/loadlib.c \
 thirdparty/lua5.4/lobject.c \
 thirdparty/lua5.4/lopcodes.c \
 thirdparty/lua5.4/loslib.c \
 thirdparty/lua5.4/lparser.c \
 thirdparty/lua5.4/lstate.c \
 thirdparty/lua5.4/lstring.c \
 thirdparty/lua5.4/lstrlib.c \
 thirdparty/lua5.4/ltable.c \
 thirdparty/lua5.4/ltablib.c \
 thirdparty/lua5.4/ltm.c \
 thirdparty/lua5.4/lundump.c \
 thirdparty/lua5.4/lutf8lib.c \
 thirdparty/lua5.4/lvm.c \
 thirdparty/lua5.4/lzio.c

MULTIARCH != ${CC} -print-multiarch

CFLAGS = -Os -fPIC -DLUA_COMPAT_5_3 -DLUA_USE_POSIX -DLUA_USE_DLOPEN -DLUA_MULTIARCH='"${MULTIARCH}"'

include ${TOPDIR}/make/comm.mk
include ${TOPDIR}/make/c.mk
include ${TOPDIR}/make/cxx.mk
