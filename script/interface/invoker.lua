local M = {}

local Singleton = require("lib.singleton").Singleton
local List = require("lib.list").List

M.Invoker = Singleton({
  init = function(self)
    self.list = List:create()
    self.method = {}
  end,
  start = function(self)
    self.list:clear()
  end,
  invoke = function(self, method, ...)
    self.method[method](self.list, ...)
    return self.list
  end,
  register_method = function(self, name, method)
    self.method[name] = method
  end,
})

return M
