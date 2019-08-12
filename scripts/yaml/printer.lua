local tree = require("tree")

local function printer(quote)
   function rec(r, n, unsafe)
      local l

      if r.type == tree.PRIM then
	 l = string.rep(" ", n) .. quote(r.val, n, unsafe)
      elseif r.type == tree.MAP then
	 if r.inline or r:iter_len() == 0 then
	    local s = {}
	    for key, x in r:iter() do
	       local v = rec(x.val, 0, unsafe or r.inline)
	       table.insert(s, key .. ": " .. v)
	    end
	    l = "{ " .. table.concat(s, ", ") .. " }"
	 else
	    local s = {}
	    for key, x in r:iter() do
	       if x.pcmt then table.insert(s, x.pcmt) end
	       local v = rec(x.val, n + 2, unsafe)
	       local qkey = quote(key, n, unsafe)
	       if x.cmt or (x.val.type ~= tree.PRIM and not x.val.inline) then
		  x.cmt = x.cmt or ""
		  table.insert(s, string.rep(" ", n) .. qkey .. ":" .. x.cmt .. "\n" .. v)
	       else
		  table.insert(s, string.rep(" ", n) .. qkey .. ": " .. string.gsub(v, "^[ ]+", ""))
	       end
	    end
	    l = table.concat(s, "\n")
	 end
      elseif r.type == tree.ARRAY then
	 if r.inline or r:iter_len() == 0 then
	    local s = {}
	    for _, x in r:iter() do
	       local v = rec(x.val, 0, unsafe or r.inline)
	       table.insert(s, v)
	    end
	    l = "[ " .. table.concat(s, ", ") .. " ]"
	 else
	    local s = {}
	    for _, x in r:iter() do
	       if x.pcmt then table.insert(s, x.pcmt) end
	       local v = rec(x.val, n + 2, unsafe)
	       if x.cmt then
		  table.insert(s, string.rep(" ", n) .. "-" .. x.cmt .. "\n" .. v)
	       else
		  table.insert(s, string.rep(" ", n) .. "- " .. string.gsub(v, "^[ ]+", ""))
	       end
	    end
	    l = table.concat(s, "\n")
	 end
      end

      if not unsafe and r.cmt then l = l .. r.cmt end
      if not unsafe and r.pcmt then l = r.pcmt .. "\n" .. l end
      return l
   end
   return rec
end

return printer
