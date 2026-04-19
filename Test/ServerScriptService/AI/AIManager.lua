-- AIManager.lua
-- Central manager for all AI instances

local HeroAI = require(script.Parent.NPCs.HeroAI)
local GuardAI = require(script.Parent.NPCs.GuardAI)
local DroneAI = require(script.Parent.NPCs.DroneAI)
local DaveNPC = require(script.Parent.NPCs.DaveNPC)
local Director = require(script.Parent.DirectorAI)

local AIManager = {}
AIManager.Agents = {}

function AIManager:Init()
	Director:Init()
	
	-- Register existing NPCs in workspace tagged appropriately
	-- Or find them by name for this example
	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Humanoid") then
			local agent = nil
			
			if model.Name == "Hero" then
				agent = HeroAI.new(model)
			elseif model.Name == "Guard" then
				agent = GuardAI.new(model)
			elseif model.Name == "Drone" then
				agent = DroneAI.new(model)
			elseif model.Name == "Dave" then
				agent = DaveNPC.new(model)
			end
			
			if agent then
				table.insert(self.Agents, agent)
				agent:Run()
			end
		end
	end
end

return AIManager
