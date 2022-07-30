require("main")

StartInvoke()
Invoke("logger.init", "a", 1)
for i = 1,10000 do
  StartInvoke()
  local result = Invoke("game.run_one_frame")
  print(result.vec[1])
end

--[[
local Object = require("lib.object").Object
local List = require("lib.list").List

local list = List:create()

for j=1,600 do
  list:clear()
  for i=1,100*100+1000*10 do
    list:push_back(i)
  end
end
--]]
