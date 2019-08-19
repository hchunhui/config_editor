CC = ${CC-${PLAT}}
CXX = ${CXX-${PLAT}}
AR = ${AR-${PLAT}}
CFLAGS = -Os -fPIC ${LUA_CFLAGS} ${NK_CFLAGS} -ffunction-sections

NK_CFLAGS = ${NK_CFLAGS-${PLAT}}
NK_LDFLAGS = ${NK_LDFLAGS-${PLAT}}
LUA_CFLAGS = ${LUA_CFLAGS-${PLAT}}
LUA_LDFLAGS = ${LUA_LDFLAGS-${PLAT}}

CC-x11 = gcc
CXX-x11 = g++
AR-x11 = ar
NK_CFLAGS-x11 = -I/usr/include/freetype2
NK_LDFLAGS-x11 = -lXft -lX11
LUA_CFLAGS-x11 = -I${TOPDIR}/thirdparty/lua5.3
LUA_LDFLAGS-x11 = -L${TOPDIR} -llua -lm -ldl
#LUA_CFLAGS-x11 = -I/usr/include/lua5.3
#LUA_LDFLAGS-x11 = -Wl,-Bstatic -llua5.3 -Wl,-Bdynamic -lm -ldl

CC-win32 = i686-w64-mingw32-gcc
CXX-win32 = i686-w64-mingw32-g++
AR-win32 = i686-w64-mingw32-ar
NK_LDFLAGS-win32 = -lgdi32 -lmsimg32 -static-libstdc++ -static-libgcc
LUA_CFLAGS-win32 = -I${TOPDIR}/thirdparty/lua5.3
LUA_LDFLAGS-win32 = -L${TOPDIR} -llua-win32
