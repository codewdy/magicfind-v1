local M = {}

local Object = require("lib.object").Object
local Enum = require("lib.enum").Enum

M.UnitGroup = Enum({
  "Player",
  "Enemy"
})

M.UnitPrototype = Object:extend({
  init = function(self)
  end,
  set_value = function(self, dict)
    for k,v in pairs(dict) do
      self[k] = v
    end
  end
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
}, {
  Type = {},
  extend = function(cls, fields)
    local prototype = M.UnitPrototype:create()
    prototype:set_value(fields)
    fields.prototype = prototype
    local result = Object.extend(cls, fields)
    M.Unit.Type[fields.name] = result
    return result
  end
})

return M
