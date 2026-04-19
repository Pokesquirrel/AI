-- ThreatSystem.lua
-- Manages "Menace" and "Stress" levels for players

local Players = game:GetService("Players")
local Metrics = require(script.Parent.Metrics)

local ThreatSystem = {}
ThreatSystem.StressLevels = {} -- [PlayerName] = float (0 to 100)

function ThreatSystem:Update(dt)
	for _, player in ipairs(Players:GetPlayers()) do
		local name = player.Name
		local stress = self.StressLevels[name] or 0

		-- decay
		stress = math.max(0, stress - 2 * dt)
		self.StressLevels[name] = stress
	end
end

function ThreatSystem:AddStress(player, amount)
	local name = player.Name
	local current = self.StressLevels[name] or 0

	current = math.clamp(current + amount, 0, 100)
	self.StressLevels[name] = current

	-- Touching AI Directly
	if current > 60 then
		Metrics:PlayerDetected()
	end
end

function ThreatSystem:GetStress(player)
	return self.StressLevels[player.Name] or 0
end

return ThreatSystem
