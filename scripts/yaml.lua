local str = require("yaml.str")
local parser = require("yaml.parser")
local printer = require("yaml.printer")

return {
   parser = parser(str.match),
   printer = printer(str.quote_once),
}
