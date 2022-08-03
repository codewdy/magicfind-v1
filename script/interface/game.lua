local M = {}

local GameRunner = require("framework.game_runner").GameRunner
local GameState = require("framework.game_runner").GameState
local Context = require("framework.context").Context
local Prototype = require("framework.prototype").Prototype
local json = require("lib.json")

function M.run_one_frame(result)
  GameRunner:update(Context)
  result:push_back(GameState.enums[Context.state])
  local unit_size = 0
  for _,units in ipairs(Context.units.units) do
    unit_size = unit_size + units.size
  end
  result:push_back(unit_size)
  for _,units in ipairs(Context.units.units) do
    for j=1,units.size do
      local unit = units.vec[j]
      result:push_back(unit.handle)
      result:push_back(unit.prototype.handle)
    end
  end
  result:push_back(Context.effects.effects.size)
  for i=1,Context.effects.effects.size do
    local effect = Context.effects.effects.vec[i]
    result:push_back(effect.prototype.handle)
    result:push_back(effect.size)
    for j=1,effect.size do
      result:push_back(effect.vec[j])
    end
  end
end

function M.get_prototype(result, handle)
  result:push_back(json.dump(Prototype:get_by_handle(handle).dict))
end

return M
