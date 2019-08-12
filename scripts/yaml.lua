local prim = require("yaml.prim")
local parser = require("yaml.parser")
local printer = require("yaml.printer")

return {
   parser = parser(prim.match),
   printer = printer(prim.quote_once),
}
