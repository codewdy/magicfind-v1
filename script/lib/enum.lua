local M = {}

function M.Enum(enums)
  local result = {}
  for id, key in ipairs(enums) do
    result[id] = key
    result[key] = id
  end
  return result
end

return M