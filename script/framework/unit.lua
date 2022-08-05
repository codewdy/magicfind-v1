local M = {}

local Object = require("lib.object").Object
local List = require("lib.list").List
local Enum = require("lib.enum").Enum
local Prototype = require("framework.prototype").Prototype

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
    self.buffs = List:create()
  end,
  clear = function(self)
    self.death = false
    self.buffs:clear()
  end,
  apply_talent = function(self)
    for i=1,self.prototype.talents.size do
      self.prototype.talents.vec[i]:update(self.status)
    end
    for i=1,self.buffs.size do
      self.buffs.vec[i]:update(self.status)
    end
    for i=1,self.prototype.post_buff_talents.size do
      self.prototype.post_buff_talents.vec[i]:update(self.status)
    end
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
  default_prototype = {
    talents = List:create(),
    post_buff_talents = List:create(),
  },
  extend = function(cls, fields)
    local prototype = Prototype:create()
    prototype:set_value(cls.default_prototype)
    prototype:set_value(fields)
    fields.prototype = prototype
    local result = Object.extend(cls, fields, { prototype = prototype })
    M.Unit.Type[fields.name] = result
    return result
  end
})

return M
