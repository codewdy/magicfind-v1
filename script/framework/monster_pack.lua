local M = {}

local Singleton = require("lib.singleton").Singleton
local Enum = require("lib.enum").Enum
local List = require("lib.list").List

M.MonsterPack = Singleton({
  Type = Enum({
    "Normal",
    "Boss"
  }),
  init = function(self)
    self.packs = {}
    for id, name in ipairs(self.Type.enums) do
      self.packs[id] = List:create()
    end
  end,
  register_pack = function(self, type, creator)
    self.packs[type]:push_back(creator)
  end,
  create_pack = function(self, type)
    self.packs[type]:random_one()()
  end
})

return M
