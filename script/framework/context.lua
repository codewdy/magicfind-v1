local M = {}

local Object = require("lib.object").Object
local Enum = require("lib.enum").Enum

M.GameState = Enum({
  "Prepare",
  "PathFinding",
  "Battle",
  "Death"
})

M.Context = {
  state = M.GameState.Prepare,
}

return M
