local M = {}

local Object = require("lib.object").Object
local Enum = require("lib.enum").Enum

M.GameState = Enum({
  "Prepare",
  "PathFinding",
  "Battle",
  "Death"
})

M.Context = Object:inherit({
  init = function(self)
    self.state = M.GameState.Prepare
  end,
})

M.context = M.Context:create()

return M
