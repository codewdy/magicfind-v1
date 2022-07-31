local M = {}

local Unit = require("framework.unit").Unit

M.Player = Unit:extend({
  name = "Player",
  icon = "Player",
  size = 2,
  maxHp = 100,
  path_finding_time = function(self)
    return 10
  end,
  current_level = function(self)
    return 1
  end,
  load = function(self, ctx, filename)
  end,
})

return M
