local M = {}

local object = require("lib.object").object

M.list_fields = {}

function M.list_fields.init(self)
  self.vec = {}
  self.size = 0
end

function M.list_fields.recycle(self)
  self:resize(0)
end

function M.list_fields.add_back(self)
  self.size = self.size + 1
  if #self.vec < self.size then
    if self.init_unit ~= nil then
      self.vec[self.size] = self:init_unit()
    end
  end
  return self.vec[self.size]
end

function M.list_fields.push_back(self, v)
  self.size = self.size + 1
  self.vec[self.size] = v
end

function M.list_fields.resize(self, size)
  if self.size < size then
    if self.init_unit ~= nil then
      for i = math.max(self.size, #self.vec) + 1, size do
        self.vec[i] = self:init_unit()
      end
    end
    self.size = size
  elseif self.size > size then
    if self.recycle_unit ~= nil then
      for i = size + 1, self.size do
        self.vec[i] = self:recycle_unit(self.vec[i])
      end
    end
    self.size = size
  end
end

M.list = object:inherit(M.list_fields)

function M.object_list(cls)
  return M.list:inherit({
    init_unit = function(self)
      return cls:create()
    end,
    recycle_unit = function(self, unit)
      unit:release()
      return unit
    end
  })
end

return M
