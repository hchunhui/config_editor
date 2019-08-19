#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <limits.h>
#include <math.h>
#include <sys/time.h>
#include <unistd.h>
#include <time.h>

#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_IMPLEMENTATION
#define NK_XLIB_IMPLEMENTATION
#define NK_XLIB_USE_XFT
#include "nuklear/nuklear.h"
#include "nuklear/nuklear_xlib.h"
#include "lib/lua_templates.h"

#define WINDOW_WIDTH    800
#define WINDOW_HEIGHT   800

typedef struct XWindow XWindow;
struct XWindow {
    Display *dpy;
    Window root;
    Visual *vis;
    Colormap cmap;
    XWindowAttributes attr;
    XSetWindowAttributes swa;
    Window win;
    int screen;
    XFont *font;
    unsigned int width;
    unsigned int height;
    Atom wm_delete_window;
};

static void
die(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputs("\n", stderr);
    exit(EXIT_FAILURE);
}

#include "nuklear/style.c"
/* ===============================================================
 *
 *                          DEMO
 *
 * ===============================================================*/

extern Lua *lua;
int
xmain(std::shared_ptr<LuaObj> gui)
{
    XWindow xw;
    long dt;
    long started;
    int running = 1;
    struct nk_context *ctx;

    /* X11 */
    memset(&xw, 0, sizeof xw);
    xw.dpy = XOpenDisplay(NULL);
    if (!xw.dpy) die("Could not open a display; perhaps $DISPLAY is not set?");
    xw.root = DefaultRootWindow(xw.dpy);
    xw.screen = XDefaultScreen(xw.dpy);
    xw.vis = XDefaultVisual(xw.dpy, xw.screen);
    xw.cmap = XCreateColormap(xw.dpy,xw.root,xw.vis,AllocNone);

    xw.swa.colormap = xw.cmap;
    xw.swa.event_mask =
        ExposureMask | KeyPressMask | KeyReleaseMask |
        ButtonPress | ButtonReleaseMask| ButtonMotionMask |
        Button1MotionMask | Button3MotionMask | Button4MotionMask | Button5MotionMask|
        PointerMotionMask | KeymapStateMask;
    xw.win = XCreateWindow(xw.dpy, xw.root, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0,
        XDefaultDepth(xw.dpy, xw.screen), InputOutput,
        xw.vis, CWEventMask | CWColormap, &xw.swa);

    XSizeHints *size_hints = XAllocSizeHints();
    if(size_hints) {
      size_hints->flags = PMinSize | PMaxSize;
      size_hints->min_width = WINDOW_WIDTH;
      size_hints->min_height = WINDOW_HEIGHT;
      size_hints->max_width = WINDOW_WIDTH;
      size_hints->max_height = WINDOW_HEIGHT;
      XSetWMNormalHints(xw.dpy, xw.win,size_hints);
      XMapWindow(xw.dpy, xw.win);
    }

    XStoreName(xw.dpy, xw.win, "X11");
    XMapWindow(xw.dpy, xw.win);
    xw.wm_delete_window = XInternAtom(xw.dpy, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(xw.dpy, xw.win, &xw.wm_delete_window, 1);
    XGetWindowAttributes(xw.dpy, xw.win, &xw.attr);
    xw.width = (unsigned int)xw.attr.width;
    xw.height = (unsigned int)xw.attr.height;

    /* GUI */
    xw.font = nk_xfont_create(xw.dpy, "Source Han Sans SC:pixelsize=12");
    ctx = nk_xlib_init(xw.font, xw.dpy, xw.screen, xw.win, xw.vis, xw.cmap, xw.width, xw.height);

    set_style(ctx, THEME_WHITE);
    /*set_style(ctx, THEME_RED);*/
    /*set_style(ctx, THEME_BLUE);*/
    /*set_style(ctx, THEME_DARK);*/

    XEvent evt;
    while (running && !XNextEvent(xw.dpy, &evt))
    {
        /* Input */
        if (evt.type == NoExpose)
            continue;
        if (XFilterEvent(&evt, xw.win))
            continue;
        if (evt.type == ClientMessage) goto cleanup;

        nk_input_begin(ctx);
        nk_xlib_handle_event(xw.dpy, xw.screen, xw.win, &evt);
        nk_input_end(ctx);

        /* GUI */
        auto r = lua->call<bool, std::shared_ptr<LuaObj>, struct nk_context *>
          (gui, ctx);
        if (r.ok()) {
          if (!r.get())
            break;
        } else {
          printf("error: %s\n", r.get_err().e.c_str());
          break;
        }

        /* Draw */
        XClearWindow(xw.dpy, xw.win);
        nk_xlib_render(xw.win, nk_rgb(30,30,30));
        XFlush(xw.dpy);
    }

cleanup:
    nk_xfont_del(xw.dpy, xw.font);
    nk_xlib_shutdown();
    XUnmapWindow(xw.dpy, xw.win);
    XFreeColormap(xw.dpy, xw.cmap);
    XDestroyWindow(xw.dpy, xw.win);
    XCloseDisplay(xw.dpy);
    return 0;
}
