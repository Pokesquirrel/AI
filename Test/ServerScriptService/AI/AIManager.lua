-- AIManager.lua
-- Central manager for all AI instances

local HeroAI = require(script.NPCs.HeroAI)
local GuardAI = require(script.NPCs.GuardAI)
local DroneAI = require(script.NPCs.DroneAI)
local DaveNPC = require(script.NPCs.DaveNPC)

local AIManager = {}
AIManager.Agents = {}

function AIManager:Init()
	
	-- Register existing NPCs in workspace tagged appropriately
	-- Or find them by name for this example
	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Humanoid") then

			local ai

			if model.Name == "Hero" then
				ai = HeroAI.new(model)
			elseif model.Name == "Guard" then
				ai = GuardAI.new(model)
			elseif model.Name == "Drone" then
				ai = DroneAI.new(model)
			elseif model.Name == "Dave" then
				ai = DaveNPC.new(model)
			end

			if ai then
				table.insert(self.Agents, ai)
				ai:Run()
			end
		end
	end
end

return AIManager
