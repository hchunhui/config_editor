--- common
local PRIM = "prim"
local ARRAY = "array"
local MAP = "map"

local function iter_len(tree)
   return #tree.val
end

--- map
local function map_iter(tree)
   local i = 1
   return function()
      if i <= #tree.val then
	 local t = (tree.val)[i]
	 i = i + 1
	 return t.key, t, i - 1
      end
   end
end

local function map_set(tree, key, val, cmt, pcmt)
   for k, v, i in map_iter(tree) do
      if key == k then
	 if val ~= nil then
	    v.val = val
	    v.cmt = cmt
	    v.pcmt = pcmt
	 else
	    table.remove(tree.val, i)
	 end
	 return
      end
   end
   if val ~= nil then
      table.insert(tree.val, {key = key, val = val, cmt = cmt, pcmt = pcmt})
   end
end

local map_intf = {
   iter_len = iter_len,
   iter = map_iter,
   set = map_set,
   insert = map_set,
}

--- array
local function array_iter(tree)
   local i = 1
   return function()
      if i <= #tree.val then
	 local t = (tree.val)[i]
	 i = i + 1
	 return i - 1, t, i - 1
      end
   end
end

local function array_set(tree, key, val, cmt, pcmt)
   assert(key >= 1 and key <= #tree.val + 1)
   if val == nil then
      table.remove(tree.val, key)
   else
      tree.val[key] = {val = val, cmt = cmt, pcmt = pcmt}
   end
end

local function array_insert(tree, pos, val, cmt, pcmt)
   table.insert(tree.val, pos, {val = val, cmt = cmt, pcmt = pcmt})
end

local array_intf = {
   iter_len = iter_len,
   iter = array_iter,
   set = array_set,
   insert = array_insert,
}

--- new
local mts = {
   [PRIM] = {},
   [MAP] = {__index = map_intf},
   [ARRAY] = {__index = array_intf},
}

local function new(type, val)
   local r
   if val ~= nil then
      r = {type = type, val = val}
   else
      r = {type = type, val = {}}
   end
   setmetatable(r, mts[type])
   return r
end

local function lower(tree, unquote)
   if tree.type == PRIM then
      return unquote(tree.val)
   elseif tree.type == MAP then
      local r = {}
      for k, v in map_iter(tree) do
	 r[k] = lower(v.val, unquote)
      end
      return r
   elseif tree.type == ARRAY then
      local r = {}
      for _, v in array_iter(tree) do
	 table.insert(r, lower(v.val, unquote))
      end
      return r
   end
end

local function lift(root, quote)
   function is_array(t)
      if #t > 0 then
	 return true
      end

      for _, _ in pairs(t) do
	 return false
      end

      return true
   end

   local r
   if type(root) == "table" then
      if is_array(root) then
	 r = new(ARRAY)
	 for i, x in ipairs(root) do
	    array_set(r, i, lift(x, quote))
	 end
      else
	 r = new(MAP)
	 for k, v in pairs(root) do
	    map_set(r, quote(k), lift(v, quote))
	 end
      end
   else
      r = new(PRIM, quote(root))
   end
   return r
end

return {
   PRIM = PRIM,
   ARRAY = ARRAY,
   MAP = MAP,
   new = new,
   lower = lower,
   lift = lift,
}
