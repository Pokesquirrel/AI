local Players = game:GetService("Players")
local GameState = require(script.Parent.GameStateManager)

local ATTACK_RANGE = 5

local Combat = {}

function Combat:CheckAttacks()
	while true do
		for _, npc in ipairs(workspace:GetChildren()) do
			if npc:FindFirstChild("HumanoidRootPart") then
				for _, player in ipairs(Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local dist = (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
						
						if dist < ATTACK_RANGE then
							GameState:Lose(player)
						end
					end
				end
			end
		end
		
		task.wait(0.2)
	end
end

return Combat
