local M = {}

M.Object = {
  handle_manager = { pool = { }, ptr = 0 },

  init_class = function(cls)
    cls.meta = {
      pool = {},
      pool_ptr = 0
    }
  end,

  new = function(cls)
    local result = { class = cls }
    setmetatable(result, { __index = cls.fields })
    result:init()
    return result
  end,

  create = function(cls)
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
  end,

  release = function(cls, obj)
    obj:clear()
    cls.meta.pool_ptr = cls.meta.pool_ptr + 1
    cls.meta.pool[cls.meta.pool_ptr] = obj
  end,

  inherit = function(cls, fields)
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
  end,

  get_by_handle = function(cls, handle)
    return cls.handle_manager.pool[handle]
  end,

  fields = {
    init = function(self)
    end,

    clear = function(self)
    end,

    release = function(self)
      self.class:release(self)
    end,
  },
}

return M
