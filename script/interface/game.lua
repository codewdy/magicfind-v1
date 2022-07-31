local M = {}

local GameRunner = require("framework.game_runner").GameRunner
local GameState = require("framework.game_runner").GameState
local Context = require("framework.context").Context

function M.run_one_frame(result)
  GameRunner:update(Context)
  result:push_back(GameState.enums[Context.state])
  local unit_size = 0
  for i=1,#Context.units.units do
    unit_size = unit_size + Context.units.units[i].size
  end
  result:push_back(unit_size)
  for i=1,#Context.units.units do
    local units = Context.units.units[i]
    for j=1,units.size do
      local unit = units.vec[j]
      result:push_back(unit.handle)
      result:push_back(unit.prototype.handle)
    end
  end
end

return M
