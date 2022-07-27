local M = {}

local Object = require("lib.object").Object
local GameState = require("framework.context").GameState
local StaticClass = require("lib.static_class").StaticClass

M.GameRunner = StaticClass({
  run = function(cls, ctx)
    local state = GameState.Prepare
    if (ctx.change_to_state ~= nil) then
      state = ctx.change_to_state
      ctx.change_to_state = nil
    else
      state = cls.processor[ctx.state].run(ctx)
    end
    if state ~= ctx.state then
      cls.processor[ctx.state].stop(ctx)
      ctx.state = state
      cls.processor[ctx.state].start(ctx)
    end
  end,

  change_to_state = function(cls, ctx, state)
    ctx.change_to_state = state
  end,

  processor = {
    [GameState.Init] = {
      start = function(ctx) end,
      stop = function(ctx) end,
      run = function(ctx)
        return GameState.PathFinding
      end
    },
    [GameState.PathFinding] = {
      start = function(ctx) end,
      stop = function(ctx) end,
      run = function(ctx)
        return GameState.Battle
      end
    },
    [GameState.Battle] = {
      start = function(ctx) end,
      stop = function(ctx) end,
      run = function(ctx)
        return GameState.Battle
      end
    },
    [GameState.Death] = {
      start = function(ctx) end,
      stop = function(ctx) end,
      run = function(ctx)
        return GameState.PathFinding
      end
    },
  }
})

return M
