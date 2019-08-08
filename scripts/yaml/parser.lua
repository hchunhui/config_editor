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

   local level = {-1}
   local flevel = {}
   local function emit_brackets(pos, tp)
      if #flevel > 0 then
	 return
      end

      if pos > level[#level] then
	 table.insert(level, pos)
	 emit("{", tp)
      else
	 while pos < level[#level] do
	    table.remove(level)
	    emit("}", false)
	 end

	 if pos ~= level[#level] then
	    error("emit_brackets")
	 end
      end
   end
   local function check_indent(pos)
      if #flevel > 0 then
	 return
      end

      if pos <= level[#level] then
	 error("check indent")
      end
   end

   local function match(c)
      return function (s, i)
	 return string.match(s, "^" .. c, i)
      end
   end

   local matchers = {
      { m = match("(-)[ \n]"),
	a = function (t, pos)
	   emit_brackets(pos + 1, "arr")
      end },

      { m = match("{"),
	a = function (t)
	   table.insert(flevel, "{")
	   emit("{", "map")
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
	   table.insert(flevel, "[")
	   emit("{", "arr")
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
	      emit_brackets(pos, "map")
	      emit("k", t)
	   else
	      check_indent(pos)
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
	   emit("#", t)
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

   local function skip_comment()
      while t.type == "#" do t = get() end
   end

   local function parse_comment()
      local cmt
      if t and t.type == "#" and string.sub(t.val, 1, 1) ~= "\n" then
	 cmt = t.val
	 t = get()
      end
      return cmt
   end

   local function parse_key()
      skip_comment()
      if t and t.type == "k" then
	 local key = t.val
	 local cmt
	 t = get()
	 return key, parse_comment()
      end
      return nil
   end

   local function parse()
      local s = {}

      skip_comment()
      if t and t.type == "v" then
	 s.type = "str"
	 s.val = t.val
	 t = get()
      elseif t and t.type == "{" then
	 s.type = t.val
	 s.val = {}
	 t = get()
	 if s.type == "map" then
	    local key, cmt = parse_key()
	    while key do
	       local val = parse()
	       if not val then error("bad value") end
	       table.insert(s.val, {key = key, val = val, cmt = cmt})
	       key, cmt = parse_key()
	    end
	 elseif s.type == "arr" then
	    local val = parse()
	    while val do
	       table.insert(s.val, {val = val})
	       val = parse()
	    end
	 end

	 skip_comment()
	 if t and t.type ~= "}" then error("bad }") end
	 s.inline = t.val
	 t = get()
      else
	 return nil
      end

      s.cmt = parse_comment()
      return s
   end
   return parse()
end

return function (match_string)
   return function (s)
      return parser(lexer(s, match_string))
   end
end
