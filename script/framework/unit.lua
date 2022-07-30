local M = {}

local Object = require("lib.object").Object
local Enum = require("lib.enum").Enum

M.UnitGroup = Enum({
  "Player",
  "Enemy"
})

M.Unit = Object:extend({
  init = function(self)
    self.pos_x = 0.0
    self.pos_y = 0.0
    self.group = M.UnitGroup.Player
    self.death = false
    self.hp = 1
    self.maxHp = 1
  end,
  clear = function(self)
    self.death = false
  end,
  pre_update = function(self)
  end,
  update = function(self)
  end,
  post_update = function(self)
    if self.hp < 0 then
      self.death = true
    end
  end
})

return M
