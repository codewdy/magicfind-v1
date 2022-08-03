require("main")

local Effect = require("framework.effect").Effect
local Skeleton = require("content.unit.skeleton").Skeleton

function InvokeAndPrint(func, ...)
  StartInvoke()
  print("Invoking: ", func)
  local result = Invoke(func, ...)
  for j = 1,result.size do
    print(result.vec[j])
  end
  print()
end

local X = Effect:extend({
  size = 3,
  name = "AAA"
})

InvokeAndPrint("logger.init", "a", 1)
for i = 1,1000 do
  InvokeAndPrint("game.run_one_frame")
end

InvokeAndPrint("game.get_prototype", Skeleton.prototype.handle)

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
