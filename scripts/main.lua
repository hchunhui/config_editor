nk = require("nk")
yaml = require("yaml")
tree = require("tree")

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

local function tree_assoc(t, key)
   local j
   if key:sub(1, 1) == "@" then
      j = tonumber(key:sub(2, -1)) + 1
   else
      for k, v in ipairs(t.val) do
	 if v.key == key then
	    j = k
	    break
	 end
      end
   end
   return j
end

local function cmds_exec(cmds, t)
   for _, c in ipairs(cmds) do
      if c.type == "delete" then
	 for i = 1, #c.path - 1 do
	    local j = tree_assoc(t, c.path[i])
	    t = t.val[j].val
	 end
	 if #c.path > 0 then
	    local j = tree_assoc(t, c.path[#c.path])
	    table.remove(t.val, j)
	 end
      elseif c.type == "append" then
	 for i = 1, #c.path do
	    local j = tree_assoc(t, c.path[i])
	    t = t.val[j].val
	 end
	 if t.type == tree.MAP then
	    table.insert(t.val, {key = keyname, val = c.val})
	 elseif t.type == tree.ARRAY then
	    table.insert(t.val, {val = c.val})
	 end
      elseif c.type == "prepend" then
	 for i = 1, #c.path do
	    local j = tree_assoc(t, c.path[i])
	    t = t.val[j].val
	 end
	 if t.type == tree.MAP then
	    table.insert(t.val, 1, {key = keyname, val = c.val})
	 elseif t.type == tree.ARRAY then
	    table.insert(t.val, 1, {val = c.val})
	 end
      end
   end
end

local function show_popup_str(ctx, cmds, path)
   local bounds = ctx:widget_bounds()
   if ctx:contextual_begin(0, nk.vec2(100, 300), bounds) then
      ctx:layout_row_dynamic(30, 1);
      ctx:label(path_show(path), nk.TEXT_LEFT)
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
      ctx:layout_row_dynamic(30, 1);
      ctx:label(path_show(path), nk.TEXT_LEFT)
      if #path > 0 then
	 if ctx:button_label("delete") then
	    table.insert(cmds, {type = "delete", path = path})
	    ctx:contextual_close()
	 end
      end

      keyname = ctx:edit(nk.EDIT_FIELD, keyname)
      if ctx:button_label("paste") then
	 local f = io.popen("xsel -b", "r")
	 if f then
	    keyname = f:read("*a")
	    f:close()
	 end
      end
      if ctx:button_label("prepend") then
	 table.insert(cmds, {type = "prepend", path = path, val = tree.new(tree.PRIM, "")})
	 ctx:contextual_close()
      end
      if ctx:button_label("prepend_array") then
	 table.insert(cmds, {type = "prepend", path = path, val = tree.new(tree.ARRAY)})
	 ctx:contextual_close()
      end
      if ctx:button_label("prepend_map") then
	 table.insert(cmds, {type = "prepend", path = path, val = tree.new(tree.MAP)})
	 ctx:contextual_close()
      end
      if ctx:button_label("append") then
	 table.insert(cmds, {type = "append", path = path, val = tree.new(tree.PRIM, "")})
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
      ctx:layout_row_dynamic(30, 1);
      ctx:label(v.val, nk.TEXT_LEFT)

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

local function show_pcmt(ctx, n, pcmt)
   if pcmt then
      ctx:layout_row_template_begin(30)
      ctx:layout_row_template_push_static(30 * n)
      ctx:layout_row_template_push_dynamic()
      ctx:layout_row_template_end()
      for l in string.gmatch(pcmt, "[ ]*([^\n]*)") do
	 ctx:label("", nk.TEXT_LEFT)
	 ctx:label(l, nk.TEXT_LEFT)
      end
   end
end

local function show_cmt(ctx, cmt)
   if cmt then
      if ctx:widget_is_hovered() then
	 ctx:tooltip(cmt)
      end
   end
end

local function show_tree(ctx, hide, cmds, path, k0, v0, cmt)
   if v0.type == tree.PRIM then
      show_pcmt(ctx, #path + 1, v0.pcmt)
      ctx:layout_row_template_begin(30)
      ctx:layout_row_template_push_static(30 * (#path + 1))
      ctx:layout_row_template_push_static(275 - 30 * #path)
      ctx:layout_row_template_push_dynamic()
      ctx:layout_row_template_end()

      ctx:label("", nk.TEXT_LEFT)

      show_popup_str(ctx, cmds, path)
      show_cmt(ctx, cmt)
      ctx:label(k0, nk.TEXT_LEFT)

      show_popup_val(ctx, v0)
      show_cmt(ctx, v0.cmt)
      v0.val = ctx:edit(nk.EDIT_FIELD, v0.val)
   else
      ctx:layout_row_template_begin(30)
      ctx:layout_row_template_push_static(30 * #path)
      ctx:layout_row_template_push_static(30)
      ctx:layout_row_template_push_dynamic()
      ctx:layout_row_template_end()

      ctx:label("", nk.TEXT_LEFT)

      local pstr = path_show(path)
      local symbol = nk.SYMBOL_TRIANGLE_DOWN
      if hide[pstr] then
	 symbol = nk.SYMBOL_TRIANGLE_RIGHT
      end
      if ctx:button_symbol(symbol) then
	 hide[pstr] = not hide[pstr]
      end

      show_popup_map(ctx, cmds, path)
      show_cmt(ctx, cmt)
      ctx:label(k0, nk.TEXT_LEFT)

      if not hide[pstr] then
	 show_pcmt(ctx, #path + 2, v0.pcmt)
	 if v0.type == tree.MAP then
	    for k, v in v0:iter() do
	       show_pcmt(ctx, #path + 2, v.pcmt)
	       show_tree(ctx, hide, cmds, path_append(path, k), k, v.val, v.cmt)
	    end
	 else
	    for i, v in v0:iter() do
	       show_pcmt(ctx, #path + 2, v.pcmt)
	       local k = "@" .. tostring(i - 1)
	       show_tree(ctx, hide, cmds, path_append(path, k), k, v.val, v.cmt)
	    end
	 end
      end
   end
end

function mkgui()
   inp = io.read("*all")
   t = yaml.parser(inp)
   hide = {}

   function gui(ctx)
      if ctx:_begin("Demo", nk.rect(0, 0, 800, 800), 0) then

	 ctx:layout_row_dynamic(30, 1)
	 ctx:label("Config Editor", nk.TEXT_LEFT)

	 local cmds = {}
	 show_tree(ctx, hide, cmds, {}, "/", t, nil)

	 cmds_exec(cmds, t)
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
