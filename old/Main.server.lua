local AIManager = require(script.AI.AIManager)
local DirectorAI = require(script.AI.DirectorAI)

DirectorAI:DecayStress()
AIManager:Init()

task.spawn(function()
    HunterAI:Run()
end)
