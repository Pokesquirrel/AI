local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NoiseEvent = ReplicatedStorage.GameEvents:WaitForChild("NoiseEvent")

local Sensory = require(game.ServerScriptService.AI.Shared.SensoryModule)

NoiseEvent.OnServerEvent:Connect(function(player, position, intensity)

	for _, npc in ipairs(workspace:GetChildren()) do
		if npc:FindFirstChild("HumanoidRootPart") then
			local aiRoot = npc.HumanoidRootPart

			if Sensory.CanHear(aiRoot.Position, position, intensity) then
				npc:SetAttribute("LastHeardPosition", position)
				npc:SetAttribute("Alerted", true)
			end
		end
	end

end)
