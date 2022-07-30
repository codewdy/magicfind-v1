local M = {}

local GameRunner = require("framework.game_runner").GameRunner
local GameState = require("framework.game_runner").GameState
local Context = require("framework.context").Context

function M.run_one_frame(result)
  GameRunner:update(Context)
  result:push_back(GameState.enums[Context.state])
end

return M
