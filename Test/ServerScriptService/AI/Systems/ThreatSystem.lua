-- ThreatSystem.lua
-- Manages "Menace" and "Stress" levels for players

local Players = game:GetService("Players")

local ThreatSystem = {}
ThreatSystem.StressLevels = {} -- [PlayerName] = float (0 to 100)

local DECAY_RATE = 2 -- stress lost per second
local PROXIMITY_THREAT_THRESHOLD = 50 -- distance where stress starts climbing

function ThreatSystem:Update(dt)
	for _, player in ipairs(Players:GetPlayers()) do
		local name = player.Name
		local currentStress = self.StressLevels[name] or 0
		
		-- Natural decay
		currentStress = math.max(0, currentStress - (DECAY_RATE * dt))
		
		-- Check proximity to Hunter (will be filled by Director)
		-- ... logic handled in Director ...
		
		self.StressLevels[name] = currentStress
	end
end

function ThreatSystem:AddStress(player, amount)
	local name = player.Name
	local current = self.StressLevels[name] or 0
	self.StressLevels[name] = math.clamp(current + amount, 0, 100)
end

function ThreatSystem:GetStress(player)
	return self.StressLevels[player.Name] or 0
end

return ThreatSystem
