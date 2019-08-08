local function printer(quote)
   function rec(r, n)
      local l

      if r.type == "str" then
	 l = string.rep(" ", n) .. quote(r.val, n)
      elseif r.type == "map" then
	 if r.inline or #r.val == 0 then
	    local s = {}
	    for _, i in ipairs(r.val) do
	       local v = rec(i.val, 0)
	       table.insert(s, i.key .. ": " .. v)
	    end
	    l = "{ " .. table.concat(s, ", ") .. " }"
	 else
	    local s = {}
	    for _, i in ipairs(r.val) do
	       local v = rec(i.val, n + 2)
	       local qkey = quote(i.key, n)
	       if i.cmt or (i.val.type ~= "str" and not i.val.inline) then
		  local cmt = i.cmt or ""
		  table.insert(s, string.rep(" ", n) .. qkey .. ":" .. cmt .. "\n" .. v)
	       else
		  table.insert(s, string.rep(" ", n) .. qkey .. ": " .. string.gsub(v, "^[ ]+", ""))
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
	       local v = rec(i.val, 0)
	       table.insert(s, v)
	    end
	    l = "[ " .. table.concat(s, ", ") .. " ]"
	 else
	    local s = {}
	    for _, i in ipairs(r.val) do
	       local v = rec(i.val, n + 2)
	       if i.cmt then
		  table.insert(s, string.rep(" ", n) .. "-" .. i.cmt .. "\n" .. v)
	       else
		  table.insert(s, string.rep(" ", n) .. "- " .. string.gsub(v, "^[ ]+", ""))
	       end
	    end
	    l = table.concat(s, "\n")
	 end
      end

      if r.cmt then l = l .. r.cmt end
      return l
   end
   return rec
end

return printer
