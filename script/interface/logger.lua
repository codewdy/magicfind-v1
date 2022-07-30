local M = {}

local logger = require("lib.logger")

function M.init(result, filename, level)
  logger.init_logger(filename, level)
end

return M
