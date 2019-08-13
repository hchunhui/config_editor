local tree = require("tree")

local function lexer(s, match_string)
   local pend = {}
   local function emit(t, v)
      table.insert(pend, {type = t, val = v})
   end

   local i = 1
   local col = 0
   local function update(t)
      local l = string.len(t)
      i = i + l
      local p = string.find(string.reverse(t), "\n")
      if p then
	 col = p - 1
      else
	 col = col + l
      end
   end

   local level = {{-1}}
   local flevel = {}
   local function fix_pos(pos)
      for _, v in ipairs(level) do
	 if pos >= v[1] and v[2] == tree.ARRAY then
	    pos = pos + 1
	 end
      end
      return pos
   end
   local function emit_brackets(pos, tp)
      if #flevel > 0 then
	 return
      end

      pos = fix_pos(pos)
      if tp == tree.ARRAY then
	 pos = pos + 1
      end

      if pos > level[#level][1] then
	 table.insert(level, {pos, tp})
	 emit("{", tp)
      else
	 while pos < level[#level][1] do
	    table.remove(level)
	    emit("}", false)
	 end

	 if pos ~= level[#level][1] then
	    error("emit_brackets")
	 end
      end
   end
   local function check_indent(pos)
      if #flevel > 0 then
	 return
      end

      if fix_pos(pos) <= level[#level][1] then
	 error("check indent")
      end
   end

   local function match(c)
      return function (s, i)
	 return string.match(s, "^" .. c, i)
      end
   end

   local matchers = {
      { m = match("(%-)[ \n]"),
	a = function (t, pos)
	   emit_brackets(pos, tree.ARRAY)
	   emit("-", t)
      end },

      { m = match("{"),
	a = function (t)
	   if flevel[#flevel] == "[" then
	      emit("-", "")
	   end
	   table.insert(flevel, "{")
	   emit("{", tree.MAP)
      end },

      { m = match("}"),
	a = function (t)
	   if #flevel == 0 or
	   table.remove(flevel) ~= "{" then
	      error("match }")
	   end
	   emit("}", true)
      end },

      { m = match("%["),
	a = function (t)
	   if flevel[#flevel] == "[" then
	      emit("-", "")
	   end
	   table.insert(flevel, "[")
	   emit("{", tree.ARRAY)
      end },

      { m = match("%]"),
	a = function (t)
	   if #flevel == 0 or
	   table.remove(flevel) ~= "[" then
	      error("match ]")
	   end
	   emit("}", true)
      end },

      { m = match(","),
	a = function () end },

      { m = match_string,
	a = function (t, pos)
	   local x = match("([ ]*:)[ \n]")(s, i)
	   if x then
	      update(x)
	      emit_brackets(pos, tree.MAP)
	      emit("k", t)
	   else
	      check_indent(pos)
	      if flevel[#flevel] == "[" then
		 emit("-", "")
	      end
	      emit("v", t)
	   end
      end },

      { m = match("[ ]*#[^\n]*"),
	a = function (t)
	   emit("#", t)
      end },

      { m = match("[ ]+"),
	a = function () end },

      { m = match("\n[ ]*#[^\n]*"),
	a = function (t)
	   emit("##", string.sub(t, 2, -1))
      end },

      { m = match("\n"),
	a = function () end },
   }

   return function ()
      while true do
	 if #pend > 0 then
	    return table.remove(pend, 1)
	 end

	 local flag = true
	 for _, f in ipairs(matchers) do
	    local t = f.m(s, i, flevel)
	    if t then
	       local pos = col
	       update(t)
	       f.a(t, pos)
	       flag = false
	       break
	    end
	 end

	 if flag then
	    if #level > 1 then
	       emit_brackets(-1, "")
	    else
	       return nil
	    end
	 end
      end
   end
end

local function parser(get)
   local t = get()

   local pend_cmts = {}
   local function push_comment()
      while t and (t.type == "#" or t.type == "##") do
	 table.insert(pend_cmts, t.val)
	 t = get()
      end
   end
   local function pop_comment()
      if #pend_cmts == 0 then
	 return nil
      end

      local r = table.concat(pend_cmts, "\n")
      pend_cmts = {}
      return r
   end

   local function parse_comment()
      local cmt
      if t and t.type == "#" then
	 cmt = t.val
	 t = get()
      end
      return cmt
   end

   local function parse_key()
      push_comment()
      if t and t.type == "k" then
	 local key = t.val
	 t = get()
	 return key, parse_comment()
      end
      return nil
   end

   local function parse_dash()
      push_comment()
      if t and t.type == "-" then
	 t = get()
	 return true, parse_comment()
      end
      return nil
   end

   local function parse()
      local s

      push_comment()
      local pcmt = pop_comment()

      if t and t.type == "v" then
	 local v = t.val
	 t = get()
	 if string.find(v, "^[^\"'|>]") then
	    while t and t.type == "v" and
	    string.find(t.val, "^[^\"'|>]") do
	       v = v .. " " .. t.val
	       t = get()
	    end
	 end
	 s = tree.new(tree.PRIM, v)
      elseif t and t.type == "{" then
	 local ty = t.val
	 s = tree.new(ty)
	 t = get()
	 if ty == tree.MAP then
	    local key, cmt = parse_key()
	    while key do
	       local pcmt = pop_comment()
	       local val = parse()
	       s:set(key, val, cmt, pcmt)
	       key, cmt = parse_key()
	    end
	 elseif ty == tree.ARRAY then
	    local i = 1
	    local dash, cmt = parse_dash()
	    while dash do
	       local pcmt = pop_comment()
	       local val = parse()
	       s:set(i, val, cmt, pcmt)
	       i = i + 1
	       dash, cmt = parse_dash()
	    end
	 end

	 if t and t.type ~= "}" then error("bad }") end
	 s.inline = t.val
	 t = get()
      else
	 s = tree.new(tree.PRIM, "")
      end

      s.pcmt = pcmt
      s.cmt = parse_comment()
      return s
   end
   return parse()
end

return function (match_string)
   return function (s)
      local s_unix = string.gsub(s, "\r\n", "\n")
      return parser(lexer(s_unix, match_string))
   end
end
