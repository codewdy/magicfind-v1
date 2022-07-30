local M = {}

local Invoker = require("interface.invoker").Invoker
local import = require("lib.importer").import

function M.invoke(method, ...)
  return Invoker:invoke(method, ...)
end

function M.start_invoke()
  Invoker:start()
end

M.methods = import("interface", {
  "logger",
  "game",
})

for module, methods in pairs(M.methods) do
  for k,v in pairs(methods) do
    Invoker:register_method(module..'.'..k, v)
  end
end

return M
