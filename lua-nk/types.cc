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

#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_STANDARD_VARARGS
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_IMPLEMENTATION
#define NK_XLIB_IMPLEMENTATION
#define NK_XLIB_USE_XFT
#include "nuklear/nuklear.h"
#include "nuklear/nuklear_xlib.h"
#include "lib/lua_templates.h"

Lua *lua;
#if 0
template<typename T>
struct LuaType<optional<T>> {
  static void pushdata(lua_State *L, optional<T> o) {
    if (o)
      LuaType<T>::pushdata(L, *o);
    else
      lua_pushnil(L);
  }

  static optional<T> todata(lua_State *L, int i) {
    if (lua_type(L, i) == LUA_TNIL)
      return {};
    else
      return LuaType<T>::todata(L, i);
  }
};
#endif

template<>
struct LuaType<const char *> {
  static const char *todata(lua_State *L, int i) {
    return luaL_checkstring(L, i);
  }
};

std::string my_edit(struct nk_context *ctx, const char *str)
{
    char buf[256];
    strncpy(buf, str, 256);
    buf[255] = 0;
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, buf, 256, nk_filter_default);
    return std::string(buf);
}

//--- wrappers for Segment
namespace NkContextReg {
  typedef struct nk_context T;

  static const luaL_Reg funcs[] = {
    { NULL, NULL },
  };

  static const luaL_Reg methods[] = {
    { "_begin", WRAPB(nk_begin) },
    { "_end", WRAP(nk_end) },
    // input
    { "input_begin", WRAP(nk_input_begin) },
    { "input_motion", WRAP(nk_input_motion) },
    { "input_key", WRAP(nk_input_key) },
    { "input_button", WRAP(nk_input_button) },
    { "input_scroll", WRAP(nk_input_scroll) },
    { "input_char", WRAP(nk_input_char) },
    { "input_glyph", WRAP(nk_input_glyph) },
    { "input_unicode", WRAP(nk_input_unicode) },
    { "input_end", WRAP(nk_input_end) },
    // window
    // nk_rect, nk_vec2, nk_panel, nk_comman_buffer
    { "window_find", WRAP(nk_window_find) },
    { "window_get_bounds", WRAP(nk_window_get_bounds) },
    { "window_get_position", WRAP(nk_window_get_position) },
    { "window_get_size", WRAP(nk_window_get_size) },
    { "window_get_width", WRAP(nk_window_get_width) },
    { "window_get_height", WRAP(nk_window_get_height) },
    { "window_get_panel", WRAP(nk_window_get_panel) },
    { "window_get_content_region", WRAP(nk_window_get_content_region) },
    { "window_get_content_region_min", WRAP(nk_window_get_content_region_min) },
    { "window_get_content_region_max", WRAP(nk_window_get_content_region_max) },
    { "window_get_content_region_size", WRAP(nk_window_get_content_region_size) },
    { "window_get_canvas", WRAP(nk_window_get_canvas) },
    { "window_get_scroll", WRAP(nk_window_get_scroll) },
    { "window_has_focus", WRAPB(nk_window_has_focus) },
    { "window_is_hovered", WRAPB(nk_window_is_hovered) },
    { "window_is_collapsed", WRAPB(nk_window_is_collapsed) },
    { "window_is_closed", WRAPB(nk_window_is_closed) },
    { "window_is_hidden", WRAPB(nk_window_is_hidden) },
    { "window_is_active", WRAPB(nk_window_is_active) },
    { "window_is_any_hovered", WRAPB(nk_window_is_any_hovered) },
    { "item_is_any_active", WRAPB(nk_item_is_any_active) },
    { "window_set_bounds", WRAP(nk_window_set_bounds) },
    { "window_set_position", WRAP(nk_window_set_position) },
    { "window_set_size", WRAP(nk_window_set_size) },
    { "window_set_focus", WRAP(nk_window_set_focus) },
    { "window_set_scroll", WRAP(nk_window_set_scroll) },
    { "window_close", WRAP(nk_window_close) },
    { "window_collapse", WRAP(nk_window_collapse) },
    { "window_collapse_if", WRAP(nk_window_collapse_if) },
    { "window_show", WRAP(nk_window_show) },
    { "window_show_if", WRAP(nk_window_show_if) },
    // layout
    { "layout_set_min_row_height", WRAP(nk_layout_set_min_row_height) },
    { "layout_reset_min_row_height", WRAP(nk_layout_reset_min_row_height) },
    { "layout_widget_bounds", WRAP(nk_layout_widget_bounds) },
    { "layout_ratio_from_pixel", WRAP(nk_layout_ratio_from_pixel) },
    { "layout_row_dynamic", WRAP(nk_layout_row_dynamic) },
    { "layout_row_static", WRAP(nk_layout_row_static) },
    { "layout_row_begin", WRAP(nk_layout_row_begin) },
    { "layout_row_push", WRAP(nk_layout_row_push) },
    { "layout_row_end", WRAP(nk_layout_row_end) },
    { "layout_row", WRAP(nk_layout_row) },
    { "layout_row_template_begin", WRAP(nk_layout_row_template_begin) },
    { "layout_row_template_push_dynamic", WRAP(nk_layout_row_template_push_dynamic) },
    { "layout_row_template_push_variable", WRAP(nk_layout_row_template_push_variable) },
    { "layout_row_template_push_static", WRAP(nk_layout_row_template_push_static) },
    { "layout_row_template_end", WRAP(nk_layout_row_template_end) },
    { "layout_space_begin", WRAP(nk_layout_space_begin) },
    { "layout_space_push", WRAP(nk_layout_space_push) },
    { "layout_space_end", WRAP(nk_layout_space_end) },
    { "layout_space_bounds", WRAP(nk_layout_space_bounds) },
    { "layout_space_to_screen", WRAP(nk_layout_space_to_screen) },
    { "layout_space_to_local", WRAP(nk_layout_space_to_local) },
    { "layout_space_rect_to_screen", WRAP(nk_layout_space_rect_to_screen) },
    { "layout_space_rect_to_local", WRAP(nk_layout_space_rect_to_local) },
    // group
    { "group_begin", WRAPB(nk_group_begin) },
    { "group_begin_titled", WRAPB(nk_group_begin_titled) },
    { "group_end", WRAP(nk_group_end) },
    { "group_scrolled_offset_begin", WRAPB(nk_group_scrolled_offset_begin) },
    { "group_scrolled_begin", WRAPB(nk_group_scrolled_begin) },
    { "group_scrolled_end", WRAP(nk_group_scrolled_end) },
    { "group_get_scroll", WRAP(nk_group_get_scroll) },
    { "group_set_scroll", WRAP(nk_group_set_scroll) },
    // tree
    { "tree_push_hashed", WRAPB(nk_tree_push_hashed) },
    { "tree_image_push_hashed", WRAPB(nk_tree_image_push_hashed) },
    { "tree_pop", WRAP(nk_tree_pop) },
    { "tree_state_push", WRAPB(nk_tree_state_push) },
    { "tree_state_image_push", WRAPB(nk_tree_state_image_push) },
    { "tree_state_pop", WRAP(nk_tree_state_pop) },
    // list view
    { "list_view_begin", WRAPB(nk_list_view_begin) },
    { "list_view_end", WRAP(nk_list_view_end) },
    // widget
    { "widget_layout_states nk_widget", WRAP(nk_widget) },
    { "widget_layout_states nk_widget_fitting", WRAP(nk_widget_fitting) },
    { "widget_bounds", WRAP(nk_widget_bounds) },
    { "widget_position", WRAP(nk_widget_position) },
    { "widget_size", WRAP(nk_widget_size) },
    { "widget_width", WRAP(nk_widget_width) },
    { "widget_height", WRAP(nk_widget_height) },
    { "widget_is_hovered", WRAPB(nk_widget_is_hovered) },
    { "widget_is_mouse_clicked", WRAPB(nk_widget_is_mouse_clicked) },
    { "widget_has_mouse_click_down", WRAPB(nk_widget_has_mouse_click_down) },
    // spacing
    { "spacing", WRAP(nk_spacing) },
    // text
    { "text", WRAP(nk_text) },
    { "text_colored", WRAP(nk_text_colored) },
    { "text_wrap", WRAP(nk_text_wrap) },
    { "text_wrap_colored", WRAP(nk_text_wrap_colored) },
    // label
    { "label", WRAP(nk_label) },
    { "label_colored", WRAP(nk_label_colored) },
    { "label_wrap", WRAP(nk_label_wrap) },
    { "label_colored_wrap", WRAP(nk_label_colored_wrap) },
    // image
    { "image", WRAP(nk_image) },
    { "image_color", WRAP(nk_image_color) },
    // labelf ?
    // value
    { "value_bool", WRAP(nk_value_bool) },
    { "value_int", WRAP(nk_value_int) },
    { "value_uint", WRAP(nk_value_uint) },
    { "value_float", WRAP(nk_value_float) },
    { "value_color_byte", WRAP(nk_value_color_byte) },
    { "value_color_float", WRAP(nk_value_color_float) },
    { "value_color_hex", WRAP(nk_value_color_hex) },
    // button
    { "button_text", WRAPB(nk_button_text) },
    { "button_label", WRAPB(nk_button_label) },
    { "button_color", WRAPB(nk_button_color) },
    { "button_symbol", WRAPB(nk_button_symbol) },
    { "button_image", WRAPB(nk_button_image) },
    { "button_symbol_label", WRAPB(nk_button_symbol_label) },
    { "button_symbol_text", WRAPB(nk_button_symbol_text) },
    { "button_image_label", WRAPB(nk_button_image_label) },
    { "button_image_text", WRAPB(nk_button_image_text) },
    { "button_text_styled", WRAPB(nk_button_text_styled) },
    { "button_label_styled", WRAPB(nk_button_label_styled) },
    { "button_symbol_styled", WRAPB(nk_button_symbol_styled) },
    { "button_image_styled", WRAPB(nk_button_image_styled) },
    { "button_symbol_text_styled", WRAPB(nk_button_symbol_text_styled) },
    { "button_symbol_label_styled", WRAPB(nk_button_symbol_label_styled) },
    { "button_image_label_styled", WRAPB(nk_button_image_label_styled) },
    { "button_image_text_styled", WRAPB(nk_button_image_text_styled) },
    { "button_set_behavior", WRAP(nk_button_set_behavior) },
    { "button_push_behavior", WRAPB(nk_button_push_behavior) },
    { "button_pop_behavior", WRAPB(nk_button_pop_behavior) },
    // check
    { "check_label", WRAPB(nk_check_label) },
    { "check_text", WRAPB(nk_check_text) },
    { "check_flags_label", WRAPB(nk_check_flags_label) },
    { "check_flags_text", WRAPB(nk_check_flags_text) },
    { "checkbox_label", WRAPB(nk_checkbox_label) },
    { "checkbox_text", WRAPB(nk_checkbox_text) },
    { "checkbox_flags_label", WRAPB(nk_checkbox_flags_label) },
    { "checkbox_flags_text", WRAPB(nk_checkbox_flags_text) },
    // radio
    { "radio_label", WRAPB(nk_radio_label) },
    { "radio_text", WRAPB(nk_radio_text) },
    // option
    { "option_label", WRAPB(nk_option_label) },
    { "option_text", WRAPB(nk_option_text) },
    // select?
    { "select_label", WRAPB(nk_select_label) },
    { "select_text", WRAPB(nk_select_text) },
    { "select_image_label", WRAPB(nk_select_image_label) },
    { "select_image_text", WRAPB(nk_select_image_text) },
    { "select_symbol_label", WRAPB(nk_select_symbol_label) },
    { "select_symbol_text", WRAPB(nk_select_symbol_text) },
    // slide
    { "slide_float", WRAP(nk_slide_float) },
    { "slide_int", WRAP(nk_slide_int) },
    // progress
    { "prog", WRAP(nk_prog) },
    // color picker
    { "color_picker", WRAP(nk_color_picker) },
    { "color_pick", WRAPB(nk_color_pick) },
    // property
    { "propertyi", WRAP(nk_propertyi) },
    { "propertyf", WRAP(nk_propertyf) },
    { "propertyd", WRAP(nk_propertyd) },
    // edit
    { "edit", WRAP(my_edit) },
    { "edit_focus", WRAP(nk_edit_focus) },
    { "edit_unfocus", WRAP(nk_edit_unfocus) },
    // chart
    { "chart_begin", WRAPB(nk_chart_begin) },
    { "chart_begin_colored", WRAPB(nk_chart_begin_colored) },
    { "chart_add_slot", WRAP(nk_chart_add_slot) },
    { "chart_add_slot_colored", WRAP(nk_chart_add_slot_colored) },
    { "chart_push", WRAP(nk_chart_push) },
    { "chart_push_slot", WRAP(nk_chart_push_slot) },
    { "chart_end", WRAP(nk_chart_end) },
    // plot
    { "plot", WRAP(nk_plot) },
    { "plot_function", WRAP(nk_plot_function) },
    // popup
    { "popup_begin", WRAPB(nk_popup_begin) },
    { "popup_close", WRAP(nk_popup_close) },
    { "popup_end", WRAP(nk_popup_end) },
    { "popup_get_scroll", WRAP(nk_popup_get_scroll) },
    { "popup_set_scroll", WRAP(nk_popup_set_scroll) },
    // combo
    { "combo", WRAP(nk_combo) },
    { "combo_separator", WRAP(nk_combo_separator) },
    { "combo_string", WRAPB(nk_combo_string) },
    { "combo_callback", WRAP(nk_combo_callback) },
    { "combobox", WRAP(nk_combobox) },
    { "combobox_string", WRAP(nk_combobox_string) },
    { "combobox_separator", WRAP(nk_combobox_separator) },
    { "combobox_callback", WRAP(nk_combobox_callback) },
    { "combo_begin_text", WRAPB(nk_combo_begin_text) },
    { "combo_begin_label", WRAPB(nk_combo_begin_label) },
    { "combo_begin_color", WRAPB(nk_combo_begin_color) },
    { "combo_begin_symbol", WRAPB(nk_combo_begin_symbol) },
    { "combo_begin_symbol_label", WRAPB(nk_combo_begin_symbol_label) },
    { "combo_begin_symbol_text", WRAPB(nk_combo_begin_symbol_text) },
    { "combo_begin_image", WRAPB(nk_combo_begin_image) },
    { "combo_begin_image_label", WRAPB(nk_combo_begin_image_label) },
    { "combo_begin_image_text", WRAPB(nk_combo_begin_image_text) },
    { "combo_item_label", WRAPB(nk_combo_item_label) },
    { "combo_item_text", WRAPB(nk_combo_item_text) },
    { "combo_item_image_label", WRAPB(nk_combo_item_image_label) },
    { "combo_item_image_text", WRAPB(nk_combo_item_image_text) },
    { "combo_item_symbol_label", WRAPB(nk_combo_item_symbol_label) },
    { "combo_item_symbol_text", WRAPB(nk_combo_item_symbol_text) },
    { "combo_close", WRAP(nk_combo_close) },
    { "combo_end", WRAP(nk_combo_end) },
    // contextual
    { "contextual_begin", WRAPB(nk_contextual_begin) },
    { "contextual_item_text", WRAPB(nk_contextual_item_text) },
    { "contextual_item_label", WRAPB(nk_contextual_item_label) },
    { "contextual_item_image_label", WRAPB(nk_contextual_item_image_label) },
    { "contextual_item_image_text", WRAPB(nk_contextual_item_image_text) },
    { "contextual_item_symbol_label", WRAPB(nk_contextual_item_symbol_label) },
    { "contextual_item_symbol_text", WRAPB(nk_contextual_item_symbol_text) },
    { "contextual_close", WRAP(nk_contextual_close) },
    { "contextual_end", WRAP(nk_contextual_end) },
    // tooltip
    { "tooltip", WRAP(nk_tooltip) },
    { "tooltip_begin", WRAPB(nk_tooltip_begin) },
    { "tooltip_end", WRAP(nk_tooltip_end) },
    // menu
    { "menubar_begin", WRAP(nk_menubar_begin) },
    { "menubar_end", WRAP(nk_menubar_end) },
    { "menu_begin_text", WRAPB(nk_menu_begin_text) },
    { "menu_begin_label", WRAPB(nk_menu_begin_label) },
    { "menu_begin_image", WRAPB(nk_menu_begin_image) },
    { "menu_begin_image_text", WRAPB(nk_menu_begin_image_text) },
    { "menu_begin_image_label", WRAPB(nk_menu_begin_image_label) },
    { "menu_begin_symbol", WRAPB(nk_menu_begin_symbol) },
    { "menu_begin_symbol_text", WRAPB(nk_menu_begin_symbol_text) },
    { "menu_begin_symbol_label", WRAPB(nk_menu_begin_symbol_label) },
    { "menu_item_text", WRAPB(nk_menu_item_text) },
    { "menu_item_label", WRAPB(nk_menu_item_label) },
    { "menu_item_image_label", WRAPB(nk_menu_item_image_label) },
    { "menu_item_image_text", WRAPB(nk_menu_item_image_text) },
    { "menu_item_symbol_text", WRAPB(nk_menu_item_symbol_text) },
    { "menu_item_symbol_label", WRAPB(nk_menu_item_symbol_label) },
    { "menu_close", WRAP(nk_menu_close) },
    { "menu_end", WRAP(nk_menu_end) },
    // style
    { "style_default", WRAP(nk_style_default) },
    { "style_from_table", WRAP(nk_style_from_table) },
    { "style_load_cursor", WRAP(nk_style_load_cursor) },
    { "style_load_all_cursors", WRAP(nk_style_load_all_cursors) },
//    { "style_get_color_by_name", WRAP(nk_style_get_color_by_name) },
    { "style_set_font", WRAP(nk_style_set_font) },
    { "style_set_cursor", WRAPB(nk_style_set_cursor) },
    { "style_show_cursor", WRAP(nk_style_show_cursor) },
    { "style_hide_cursor", WRAP(nk_style_hide_cursor) },
    { "style_push_font", WRAPB(nk_style_push_font) },
    { "style_push_float", WRAPB(nk_style_push_float) },
    { "style_push_vec2", WRAPB(nk_style_push_vec2) },
    { "style_push_style_item", WRAPB(nk_style_push_style_item) },
    { "style_push_flags", WRAPB(nk_style_push_flags) },
    { "style_push_color", WRAPB(nk_style_push_color) },
    { "style_pop_font", WRAPB(nk_style_pop_font) },
    { "style_pop_float", WRAPB(nk_style_pop_float) },
    { "style_pop_vec2", WRAPB(nk_style_pop_vec2) },
    { "style_pop_style_item", WRAPB(nk_style_pop_style_item) },
    { "style_pop_flags", WRAPB(nk_style_pop_flags) },
    { "style_pop_color", WRAPB(nk_style_pop_color) },
    { NULL, NULL },
  };

  static const luaL_Reg vars_get[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_set[] = {
    { NULL, NULL },
  };
}

namespace NkRectReg {
  typedef struct nk_rect T;

  static const luaL_Reg funcs[] = {
    { "rect", WRAP(nk_rect) },
    { NULL, NULL },
  };

  static const luaL_Reg methods[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_get[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_set[] = {
    { NULL, NULL },
  };
}

namespace NkVec2Reg {
  typedef struct nk_vec2 T;

  static const luaL_Reg funcs[] = {
    { "vec2", WRAP(nk_vec2) },
    { NULL, NULL },
  };

  static const luaL_Reg methods[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_get[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_set[] = {
    { NULL, NULL },
  };
}

namespace NkColorReg {
  typedef struct nk_color T;

  static const luaL_Reg funcs[] = {
    { "rgb", WRAP(nk_rgb) },
    { "rgb_iv", WRAP(nk_rgb_iv) },
    { "rgb_bv", WRAP(nk_rgb_bv) },
    { "rgb_f", WRAP(nk_rgb_f) },
    { "rgb_fv", WRAP(nk_rgb_fv) },
    { "rgb_cf", WRAP(nk_rgb_cf) },
    { "rgb_hex", WRAP(nk_rgb_hex) },
    { "rgba", WRAP(nk_rgba) },
    { "rgba_u32", WRAP(nk_rgba_u32) },
    { "rgba_iv", WRAP(nk_rgba_iv) },
    { "rgba_bv", WRAP(nk_rgba_bv) },
    { "rgba_f", WRAP(nk_rgba_f) },
    { "rgba_fv", WRAP(nk_rgba_fv) },
    { "rgba_cf", WRAP(nk_rgba_cf) },
    { "rgba_hex", WRAP(nk_rgba_hex) },
    { "hsv", WRAP(nk_hsv) },
    { "hsv_iv", WRAP(nk_hsv_iv) },
    { "hsv_bv", WRAP(nk_hsv_bv) },
    { "hsv_f", WRAP(nk_hsv_f) },
    { "hsv_fv", WRAP(nk_hsv_fv) },
    { "hsva", WRAP(nk_hsva) },
    { "hsva_iv", WRAP(nk_hsva_iv) },
    { "hsva_bv", WRAP(nk_hsva_bv) },
    { "hsva_f", WRAP(nk_hsva_f) },
    { "hsva_fv", WRAP(nk_hsva_fv) },

#if 0
NK_API struct nk_colorf nk_hsva_colorf(float h, float s, float v, float a);
NK_API struct nk_colorf nk_hsva_colorfv(float *c);
NK_API void nk_colorf_hsva_f(float *out_h, float *out_s, float *out_v, float *out_a, struct nk_colorf in);
NK_API void nk_colorf_hsva_fv(float *hsva, struct nk_colorf in);
#endif
    { NULL, NULL },
  };

  static const luaL_Reg methods[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_get[] = {
    { NULL, NULL },
  };

  static const luaL_Reg vars_set[] = {
    { NULL, NULL },
  };
}

//--- Lua
#define EXPORT(ns, L) \
  do { \
  export_type(L, LuaType<ns::T>::name(), LuaType<ns::T>::gc,       \
              ns::funcs, ns::methods, ns::vars_get, ns::vars_set); \
  export_type(L, LuaType<const ns::T>::name(), LuaType<ns::T>::gc, \
              ns::funcs, ns::methods, ns::vars_get, ns::vars_set); \
  export_type(L, LuaType<ns::T *>::name(), NULL,                   \
              ns::funcs, ns::methods, ns::vars_get, ns::vars_set); \
  export_type(L, LuaType<const ns::T *>::name(), NULL,             \
              ns::funcs, ns::methods, ns::vars_get, ns::vars_set); \
  } while (0)

#define export_enum(name)                             \
template<>                                            \
struct LuaType<enum name> {                           \
    static void pushdata(lua_State *L, enum name e) { \
        lua_pushinteger(L, (int) e);                  \
    }                                                 \
    static enum name todata(lua_State *L, int i) {    \
        return (enum name) luaL_checkinteger(L, i);   \
    }                                                 \
};

export_enum(nk_heading)
export_enum(nk_button_behavior)
export_enum(nk_modify)
export_enum(nk_orientation)
export_enum(nk_collapse_states)
export_enum(nk_show_states)
export_enum(nk_chart_type)
export_enum(nk_chart_event)
export_enum(nk_color_format)
export_enum(nk_popup_type)
export_enum(nk_layout_format)
export_enum(nk_tree_type)
export_enum(nk_symbol_type)
export_enum(nk_text_align)
export_enum(nk_text_alignment)

void export_type(lua_State *L,
                 const char *name, lua_CFunction gc,
                 const luaL_Reg *funcs, const luaL_Reg *methods,
                 const luaL_Reg *vars_get, const luaL_Reg *vars_set);

void types_init(lua_State *L) {
  EXPORT(NkContextReg, L);
  EXPORT(NkColorReg, L);
  EXPORT(NkRectReg, L);
  EXPORT(NkVec2Reg, L);
}

#define DTIME           20
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

static long
timestamp(void)
{
    struct timeval tv;
    if (gettimeofday(&tv, NULL) < 0) return 0;
    return (long)((long)tv.tv_sec * 1000 + (long)tv.tv_usec/1000);
}

static void
sleep_for(long t)
{
    struct timespec req;
    const time_t sec = (int)(t/1000);
    const long ms = t - (sec * 1000);
    req.tv_sec = sec;
    req.tv_nsec = ms * 1000000L;
    while(-1 == nanosleep(&req, &req));
}

#include "nuklear/style.c"
/* ===============================================================
 *
 *                          DEMO
 *
 * ===============================================================*/

int
xmain(void)
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

    while (running)
    {
        /* Input */
        XEvent evt;
        started = timestamp();
        nk_input_begin(ctx);
        while (XPending(xw.dpy)) {
            XNextEvent(xw.dpy, &evt);
            if (evt.type == ClientMessage) goto cleanup;
            if (XFilterEvent(&evt, xw.win)) continue;
            nk_xlib_handle_event(xw.dpy, xw.screen, xw.win, &evt);
        }
        nk_input_end(ctx);

        /* GUI */
        auto r = lua->call<bool, std::shared_ptr<LuaObj>, struct nk_context *>
          (lua->getglobal("gui"), ctx);
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

        /* Timing */
        dt = timestamp() - started;
        if (dt < DTIME)
            sleep_for(DTIME - dt);
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

static const luaL_Reg funcs[] = {
	{ "main", WRAP(xmain) },
	{ NULL, NULL }
};

extern "C" int luaopen_nk (lua_State *L) {
	lua = new Lua(L);
	luaL_newlib(L, funcs);
        types_init(L);
	return 1;
}
