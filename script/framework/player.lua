local M = {}

local Object = require("lib.object").Object

M.Player = Object:extend({
  path_finding_time = function(self)
    return 100
  end,
  current_level = function(self)
    return 1
  end,
  load = function(self, ctx, filename)
  end,
})

return M
