local function match_qstring(s, i) --- "str"
   local t = {}
   local r = string.match(s, "^\"", i)
   if not r then return nil end

   while r do
      table.insert(t, r)
      i = i + string.len(r)
      r =
	 -- Escape sequences in C
	 string.match(s, "^\\[0-7][0-7]?[0-7]?", i) or
	 string.match(s, "^\\x%x%x?", i) or
	 string.match(s, "^\\u%x%x%x%x", i) or
	 string.match(s, "^\\U%x%x%x%x%x%x%x%x", i) or
	 string.match(s, "^\\[abefnrtv\\'\"?]", i) or
	 -- YAML specific
	 string.match(s, "^\\[/N_LP \t]", i) or
	 string.match(s, "^[^\"\\]+", i)
   end

   r = string.match(s, "^\"", i)
   if r then
      r = table.concat(t) .. r
   end

   return r
end

local function match_sqstring(s, i) --- 'str'
   local t = {}
   local r = string.match(s, "^'[^']*'", i)
   if not r then return nil end

   while r do
      table.insert(t, r)
      i = i + string.len(r)
      r = string.match(s, "^'[^']*'", i)
   end
   return table.concat(t)
end

local function match_rstring(s, i, unsafe) --- str
   local set1 = "^[^ :#\n]"
   local set2 = "^[^:#\n]+"
   if unsafe then
      set1 = "^[^ ,{}%[%]:#\n]"
      set2 = "^[^,{}%[%]:#\n]+"
   end

   local t = {}
   local r = string.match(s, set1, i)
   if not r then return nil end

   while r do
      table.insert(t, r)
      i = i + string.len(r)
      r = string.match(s, "^(:)[^ \n]", i) or
	 string.match(s, set2, i)
   end

   r = table.concat(t)
   local _, n = string.find(string.reverse(r), "^[ ]*")
   r = string.sub(r, 1, -(n + 1))

   return r
end

local function match_xstring(s, i) --- XXX: |str >str
   local r = string.match(s, "^|\n[ ]+", i) or
      string.match(s, "^>\n[ ]+", i)
   if r then
      local n = string.len(r) - 2
      local j = i + 2
      while true do
	 local l = string.match(s, "^[^\n]*\n", j)
	 if l then
	    local m = string.len(string.match(l, "^[ ]*"))
	    if l ~= "\n" then
	       if m ~= n then
		  break
	       end
	    end
	    j = j + string.len(l)
	 else
	    break
	 end
      end
      return string.sub(s, i, j - 2)
   end
end

local function match_string(s, i, flevel)
   return
      match_qstring(s, i) or
      match_sqstring(s, i) or
      match_xstring(s, i) or
      match_rstring(s, i, #flevel > 0)
end

local function match(c)
   return function (s, i)
      return string.match(s, "^" .. c, i)
   end
end

local function lexer(s)
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

local function quote_string_once(s, n)
   if match_sqstring(s, 1) == s or
      match_qstring(s, 1) == s then
      return s
   end

   if match_xstring(s .. "\n", 1) == s then
      return string.gsub(s, "\n[ ]+", "\n" .. string.rep(" ", n))
   end

   if string.len(s) == 0 or string.find(s, "[ ,{}%[%]:#'\"]") then
      if string.find(s, "\"") and
      not string.find(s, "[\a\b\x1b\f\n\r\t\v]") then
	 return "'" .. string.gsub(s, "'", "''") .. "'"
      else
	 local quote_tbl = {
	    ["\a"] = "\\a", ["\b"] = "\\b", ["\x1b"] = "\\e", ["\f"] = "\\f",
	    ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t", ["\v"] = "\\v",
	    ["\""] = "\\\"", ["\\"] = "\\\\",
	 }
	 return "\"" ..
	    string.gsub(s, "[\a\b\x1b\f\n\r\t\v\"\\]", quote_tbl) .. "\""
      end
   end
   return s
end

local function printer(r, n)
   local l

   if r.type == "str" then
      l = quote_string_once(r.val, n)
   elseif r.type == "map" then
      if r.inline or #r.val == 0 then
	 local s = {}
	 for _, i in ipairs(r.val) do
	    local v = printer(i.val, 0)
	    table.insert(s, i.key .. ": " .. v)
	 end
	 l = "{ " .. table.concat(s, ", ") .. " }"
      else
	 local s = {}
	 for _, i in ipairs(r.val) do
	    local sep = ""
	    local v = printer(i.val, n + 2)
	    if string.match(string.sub(i.key, -1, -1), "['\"]") then
	       sep = " "
	    end
	    if i.cmt or (i.val.type ~= "str" and not i.val.inline) then
	       local cmt = i.cmt or ""
	       table.insert(s, string.rep(" ", n) .. i.key .. sep .. ":" .. cmt .. "\n" .. v)
	    else
	       table.insert(s, string.rep(" ", n) .. i.key .. sep .. ": " .. v)
	    end
	 end
	 if n == 0 then
	    l = table.concat(s, "\n\n")
	 else
	    l = table.concat(s, "\n")
	 end
      end
   elseif r.type == "arr" then
      if r.inline or #r.val == 0 then
	 local s = {}
	 for _, i in ipairs(r.val) do
	    local v = printer(i.val, 0)
	    table.insert(s, v)
	 end
	 l = "[ " .. table.concat(s, ", ") .. " ]"
      else
	 local s = {}
	 for _, i in ipairs(r.val) do
	    local v = printer(i.val, n + 2)
	    table.insert(s, string.rep(" ", n) .. "- " .. string.gsub(v, "^[ ]+", ""))
	 end
	 l = table.concat(s, "\n")
      end
   end

   if r.cmt then l = l .. r.cmt end
   return l
end

return {
   parser = function(inp) return parser(lexer(inp)) end,
   printer = function(tree) return printer(tree, 0) end,
}
