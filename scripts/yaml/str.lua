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
   local r1, r2 = string.match(s, "^([|>][%+%-]?\n)([ ]+)", i)
   if r1 then
      local n = string.len(r2)
      local j = i + string.len(r1)
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

return { match = match_string,
	 quote_once = quote_string_once }
