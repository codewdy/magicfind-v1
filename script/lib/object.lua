local M = {}

M.object = { fields = { }, handle_manager = { pool = { }, ptr = 0 } }

function M.object.init_class(cls)
  cls.meta = {
    pool = {},
    pool_ptr = 0
  }
end

function M.object.new(cls)
  local result = { class = cls }
  setmetatable(result, { __index = cls.fields })
  result:init()
  return result
end

function M.object.create(cls)
  if cls.meta.pool_ptr == 0 then
    cls.handle_manager.ptr = cls.handle_manager.ptr + 1
    local result = cls:new()
    result.handle = cls.handle_manager.ptr
    cls.handle_manager.pool[result.handle] = result
    return result
  else
    local x = cls.meta.pool[cls.meta.pool_ptr]
    cls.meta.pool_ptr = cls.meta.pool_ptr - 1
    return x
  end
end

function M.object.release(cls, obj)
  obj:recycle()
  cls.meta.pool_ptr = cls.meta.pool_ptr + 1
  cls.meta.pool[cls.meta.pool_ptr] = obj
end

function M.object.inherit(cls, fields)
  local result = {}
  for k, v in pairs(cls) do
    result[k] = v
  end
  result.fields = {}
  for k, v in pairs(cls.fields) do
    result.fields[k] = v
  end
  for k, v in pairs(fields) do
    result.fields[k] = v
  end
  result:init_class()
  return result
end

function M.object.get_by_handle(cls, handle)
  return cls.handle_manager.pool[handle]
end

function M.object.fields.init(self)
end

function M.object.fields.recycle(self)
end

function M.object.fields.release(self)
  self.class:release(self)
end

return M
