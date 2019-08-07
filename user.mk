CFLAGS = -Os -fPIC ${LUA_CFLAGS} ${XFT_CFLAGS}
XFT_CFLAGS = -I/usr/include/freetype2
XFT_LDFLAGS = -lXft -lX11
#LUA_CFLAGS = -I${TOPDIR}/thirdparty/lua5.3
#LUA_LDFLAGS = -L${TOPDIR} -llua -lm -ldl
LUA_CFLAGS = -I/usr/include/lua5.3
LUA_LDFLAGS = -Wl,-Bstatic -llua5.3 -Wl,-Bdynamic -lm -ldl
