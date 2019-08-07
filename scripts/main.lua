if not nk then
    nk = require('nk')
end
yaml = require("parser.yaml")

--enum nk_heading
NK_UP = 0
NK_RIGHT = 1
NK_DOWN = 2
NK_LEFT = 3

--enum nk_button_behavior
NK_BUTTON_DEFAULT = 0
NK_BUTTON_REPEATER = 1

--enum nk_modify
NK_FIXED = 0
NK_MODIFIABLE = 1

--enum nk_orientation
NK_VERTICAL = 0
NK_HORIZONTAL = 1

--enum nk_collapse_states
NK_MINIMIZED = 0
NK_MAXIMIZED = 1

--enum nk_show_states
NK_HIDDEN = 0
NK_SHOWN = 1

--enum nk_chart_type
NK_CHART_LINES = 0
NK_CHART_COLUMN = 1
NK_CHART_MAX = 2

--enum nk_chart_event
NK_CHART_HOVERING = 0x01
NK_CHART_CLICKED = 0x02

--enum nk_color_format
NK_RGB = 0
NK_RGBA = 1

--enum nk_popup_type
NK_POPUP_STATIC = 0
NK_POPUP_DYNAMIC = 1

--enum nk_layout_format
NK_DYNAMIC = 0
NK_STATIC = 1

--enum nk_tree_type
NK_TREE_NODE = 0
NK_TREE_TAB = 1

--enum nk_symbol_type
NK_SYMBOL_NONE = 0
NK_SYMBOL_X = 1
NK_SYMBOL_UNDERSCORE = 2
NK_SYMBOL_CIRCLE_SOLID = 3
NK_SYMBOL_CIRCLE_OUTLINE = 4
NK_SYMBOL_RECT_SOLID = 5
NK_SYMBOL_RECT_OUTLINE = 6
NK_SYMBOL_TRIANGLE_UP = 7
NK_SYMBOL_TRIANGLE_DOWN = 8
NK_SYMBOL_TRIANGLE_LEFT = 9
NK_SYMBOL_TRIANGLE_RIGHT = 10
NK_SYMBOL_PLUS = 11
NK_SYMBOL_MINUS = 12
NK_SYMBOL_MAX = 13

--enum nk_text_align
NK_TEXT_ALIGN_LEFT        = 0x01
NK_TEXT_ALIGN_CENTERED    = 0x02
NK_TEXT_ALIGN_RIGHT       = 0x04
NK_TEXT_ALIGN_TOP         = 0x08
NK_TEXT_ALIGN_MIDDLE      = 0x10
NK_TEXT_ALIGN_BOTTOM      = 0x20

--enum nk_text_alignment
NK_TEXT_LEFT        = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_LEFT
NK_TEXT_CENTERED    = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_CENTERED
NK_TEXT_RIGHT       = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_RIGHT

local keyname = "default"

local function path_append(old, p)
   local new = {}
   for i, x in ipairs(old) do
      new[i] = x
   end
   new[#new + 1] = p
   return new
end

local function path_show(path)
   return table.concat(path, "/")
end

local function tree_assoc(tree, key)
   local j
   if key:sub(1, 1) == "@" then
      j = tonumber(key:sub(2, -1)) + 1
   else
      for k, v in ipairs(tree) do
	 if v.key == key then
	    j = k
	    break
	 end
      end
   end
   return j
end

local function cmds_exec(cmds, tree)
   for _, c in ipairs(cmds) do
      if c.type == "delete" then
	 for i = 1, #c.path - 1 do
	    local j = tree_assoc(tree, c.path[i])
	    tree = tree[j].val
	 end
	 if #c.path > 0 then
	    local j = tree_assoc(tree, c.path[#c.path])
	    table.remove(tree, j)
	 end
      elseif c.type == "append" then
	 for i = 1, #c.path do
	    local j = tree_assoc(tree, c.path[i])
	    tree = tree[j].val
	 end
	 if tree.type == "map" then
	    table.insert(tree, {key = keyname, val = c.val})
	 elseif tree.type == "arr" then
	    table.insert(tree, {val = c.val})
	 end
      elseif c.type == "prepend" then
	 for i = 1, #c.path do
	    local j = tree_assoc(tree, c.path[i])
	    tree = tree[j].val
	 end
	 if tree.type == "map" then
	    table.insert(tree, 1, {key = keyname, val = c.val})
	 elseif tree.type == "arr" then
	    table.insert(tree, 1, {val = c.val})
	 end
      end
   end
end

local function show_popup_str(ctx, cmds, path)
   local bounds = ctx:widget_bounds()
   if ctx:contextual_begin(0, nk.vec2(100, 300), bounds) then
      ctx:layout_row_dynamic(25, 1);
      ctx:label(path_show(path), NK_TEXT_LEFT)
      if ctx:button_label("delete") then
	 table.insert(cmds, {type = "delete", path = path})
	 ctx:contextual_close()
      end
      if ctx:button_label("cancel") then
	 ctx:contextual_close()
      end
      ctx:contextual_end()
   end
end

local function show_popup_map(ctx, cmds, path)
   local bounds = ctx:widget_bounds()
   if ctx:contextual_begin(0, nk.vec2(100, 300), bounds) then
      ctx:layout_row_dynamic(25, 1);
      ctx:label(path_show(path), NK_TEXT_LEFT)
      if #path > 0 then
	 if ctx:button_label("delete") then
	    table.insert(cmds, {type = "delete", path = path})
	    ctx:contextual_close()
	 end
      end

      keyname = ctx:edit(keyname)
      if ctx:button_label("paste") then
	 local f = io.popen("xsel -b", "r")
	 if f then
	    keyname = f:read("*a")
	    f:close()
	 end
      end
      if ctx:button_label("prepend") then
	 table.insert(cmds, {type = "prepend", path = path, val = {type = "str", val = ""}})
	 ctx:contextual_close()
      end
      if ctx:button_label("prepend_array") then
	 table.insert(cmds, {type = "prepend", path = path, val = {type = "arr"}})
	 ctx:contextual_close()
      end
      if ctx:button_label("prepend_map") then
	 table.insert(cmds, {type = "prepend", path = path, val = {type = "map"}})
	 ctx:contextual_close()
      end
      if ctx:button_label("append") then
	 table.insert(cmds, {type = "append", path = path, val = {type = "str", val = ""}})
	 ctx:contextual_close()
      end
      if ctx:button_label("cancel") then
	 ctx:contextual_close()
      end
      ctx:contextual_end()
   end
end

local function show_popup_val(ctx, v)
   local bounds = ctx:widget_bounds()
   if ctx:contextual_begin(0, nk.vec2(100, 300), bounds) then
      ctx:layout_row_dynamic(25, 1);
      ctx:label(v.val, NK_TEXT_LEFT)

      if ctx:button_label("copy") then
	 local f = io.popen("xsel -b", "w")
	 if f then
	    f:write(v.val)
	    f:close()
	 end
	 ctx:contextual_close()
      end

      if ctx:button_label("paste") then
	 local f = io.popen("xsel -b", "r")
	 if f then
	    v.val = f:read("*a")
	    f:close()
	 end
	 ctx:contextual_close()
      end
      ctx:contextual_end()
   end
end

local function show_tree(ctx, hide, cmds, path, k0, v0)
   if v0.type == "str" then
      ctx:layout_row_template_begin(25)
      ctx:layout_row_template_push_static(25 * (#path + 1))
      ctx:layout_row_template_push_static(275 - 25 * #path)
      ctx:layout_row_template_push_dynamic()
      ctx:layout_row_template_end()

      ctx:label("", NK_TEXT_LEFT)

      show_popup_str(ctx, cmds, path)
      ctx:label(k0, NK_TEXT_LEFT)

      if v0.cmt then
	 if ctx:widget_is_hovered() then
	    ctx:tooltip(v0.cmt)
	 end
      end

      show_popup_val(ctx, v0)
      v0.val = ctx:edit(v0.val)
   else
      ctx:layout_row_template_begin(25)
      ctx:layout_row_template_push_static(25 * #path)
      ctx:layout_row_template_push_static(25)
      ctx:layout_row_template_push_dynamic()
      ctx:layout_row_template_end()

      ctx:label("", NK_TEXT_LEFT)

      local pstr = path_show(path)
      local symbol = NK_SYMBOL_TRIANGLE_DOWN
      if hide[pstr] then
	 symbol = NK_SYMBOL_TRIANGLE_RIGHT
      end
      if ctx:button_symbol(symbol) then
	 hide[pstr] = not hide[pstr]
      end

      show_popup_map(ctx, cmds, path)
      ctx:label(k0, NK_TEXT_LEFT)
      if not hide[pstr] then
	 if v0.type == "map" then
	    for i, v in ipairs(v0) do
	       if v.cmt then
		  if ctx:widget_is_hovered() then
		     ctx:tooltip(v.cmt)
		  end
	       end
	       show_tree(ctx, hide, cmds, path_append(path, v.key), v.key, v.val)
	    end
	 else
	    for i, v in ipairs(v0) do
	       local k = "@" .. tostring(i - 1)
	       local action = show_tree(ctx, hide, cmds, path_append(path, k), k, v.val)
	    end
	 end
      end
   end
end

function mkgui()
   inp = io.read("*all")
   tree = yaml(inp)
   hide = {}

   function gui(ctx)
      if ctx:_begin("Demo", nk.rect(0, 0, 800, 800), 0) then

	 ctx:layout_row_dynamic(25, 1)
	 ctx:label("Config Editor", NK_TEXT_LEFT)

	 local cmds = {}
	 show_tree(ctx, hide, cmds, {}, "/", tree)

	 cmds_exec(cmds, tree)
      end
      ctx:_end()

      if ctx:window_is_hidden("Demo") then
	 return false
      else
	 return true
      end
   end
   return gui
end

return nk.main(mkgui()) == 0
