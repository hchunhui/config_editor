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

      if pos < level[#level] then
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
	   emit_brackets(pos + 1, "arr")
	   emit("-", t)
      end },

      { m = match("{"),
	a = function (t)
	   if flevel[#flevel] == "[" then
	      emit("-", "")
	   end
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
	   if flevel[#flevel] == "[" then
	      emit("-", "")
	   end
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
	      if flevel[#flevel] == "[" then
		 emit("-", "")
	      end
	      if t == "~" or t == "null" or t == "Null" or t == "NULL" then
		 emit("v", {type = "nul", val = t})
	      else
		 emit("v", {type = "str", val = t})
	      end
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
      local s = {}

      push_comment()
      s.pcmt = pop_comment()
      if t and t.type == "v" then
	 s.type = t.val.type
	 s.val = t.val.val
	 t = get()
      elseif t and t.type == "{" then
	 s.type = t.val
	 s.val = {}
	 t = get()
	 if s.type == "map" then
	    local key, cmt = parse_key()
	    local pcmt = pop_comment()
	    while key do
	       local val = parse()
	       table.insert(s.val, {key = key, val = val, cmt = cmt, pcmt = pcmt})
	       key, cmt = parse_key()
	       pcmt = pop_comment()
	    end
	 elseif s.type == "arr" then
	    local dash, cmt = parse_dash()
	    local pcmt = pop_comment()
	    while dash do
	       local val = parse()
	       table.insert(s.val, {val = val, cmt = cmt, pcmt = pcmt})
	       dash, cmt = parse_dash()
	       pcmt = pop_comment()
	    end
	 end

	 if t and t.type ~= "}" then error("bad }") end
	 s.inline = t.val
	 t = get()
      else
	 s.type = "nul"
	 s.val = ""
      end

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
