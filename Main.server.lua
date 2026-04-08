local DirectorAI = require(script.AI.DirectorAI)
local HunterAI = require(script.AI.HunterAI)

DirectorAI:DecayStress()

task.spawn(function()
    HunterAI:Run()
end)
