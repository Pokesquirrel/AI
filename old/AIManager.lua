local HunterAI = require(script.Parent.HunterAI)
local GuardAI = require(script.Parent.GuardAI)

local AIManager = {}

AIManager.Agents = {}

function AIManager:Init()
    -- Hunter
    local hunterModel = workspace:WaitForChild("Monster")
    local hunter = HunterAI.new(hunterModel)
    table.insert(self.Agents, hunter)

    -- Guards
    for _, model in ipairs(workspace:GetChildren()) do
        if model.Name == "Guard" then
            local guard = GuardAI.new(model)
            table.insert(self.Agents, guard)

            task.spawn(function()
                guard:Run()
            end)
        end
    end

    -- Start Hunter
    task.spawn(function()
        hunter:Run()
    end)
end

return AIManager
