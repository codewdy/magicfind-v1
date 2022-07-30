local M = {}

local Object = require("lib.object").Object
local Singleton = require("lib.singleton").Singleton
local Enum = require("lib.enum").Enum

M.GameState = Enum({
  "Prepare",
  "PathFinding",
  "Battle",
  "Death"
})

M.GameRunner = Singleton({
  update = function(self, ctx)
    local state = M.GameState.Prepare
    if (ctx.change_to_state ~= nil) then
      state = ctx.change_to_state
      ctx.change_to_state = nil
    else
      state = self.processor[ctx.state].run(ctx)
    end
    if state ~= ctx.state then
      self.processor[ctx.state].stop(ctx)
      ctx.state = state
      self.processor[ctx.state].start(ctx)
    end
  end,

  change_state = function(self, ctx, state)
    ctx.change_to_state = state
  end,

  processor = {
    [M.GameState.Prepare] = {
      start = function(ctx) end,
      stop = function(ctx) end,
      run = function(ctx)
        if ctx.player ~= nil then
          ctx.player:recycle()
        end
        ctx.player = ctx:load_player(ctx.player_filename)
        return M.GameState.PathFinding
      end
    },
    [M.GameState.PathFinding] = {
      start = function(ctx)
        ctx.path_finding_countdown = ctx.player:path_finding_time()
      end,
      stop = function(ctx) end,
      run = function(ctx)
        ctx.path_finding_countdown = ctx.path_finding_countdown - 1
        if ctx.path_finding_countdown <= 0 then
          return M.GameState.Battle
        else
          return M.GameState.PathFinding
        end
      end
    },
    [M.GameState.Battle] = {
      start = function(ctx)
        ctx.level = ctx.player:current_level()
      end,
      stop = function(ctx) end,
      run = function(ctx)
        return M.GameState.Battle
      end
    },
    [M.GameState.Death] = {
      start = function(ctx) end,
      stop = function(ctx) end,
      run = function(ctx)
        return M.GameState.PathFinding
      end
    },
  },
})

return M
