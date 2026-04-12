-- DirectorAI.lua (OmniVision)
-- Managing game pacing, player stress, and Hunter jobs

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThreatSystem = require(script.Parent.Systems.ThreatSystem)

local DirectorAI = {}
DirectorAI.MenaceGauge = 0
DirectorAI.TargetPlayer = nil
DirectorAI.JobQueue = {} -- Search locations issued to NPCs

-- Settings
local STRESS_THRESHOLD_PEAK = 80 -- Point where we give the player a break
local STRESS_THRESHOLD_LOW = 20  -- Point where we re-introduce tension

function DirectorAI:Init()
	task.spawn(function()
		while true do
			self:UpdatePacing(1)
			task.wait(1)
		end
	end)
end

function DirectorAI:UpdatePacing(dt)
	local highestStress = 0
	local totalPlayers = 0
	
	for _, player in ipairs(Players:GetPlayers()) do
		local stress = ThreatSystem:GetStress(player)
		if stress > highestStress then
			highestStress = stress
			self.TargetPlayer = player
		end
		totalPlayers += 1
	end
	
	-- Manage Hunter state based on stress
	if highestStress > STRESS_THRESHOLD_PEAK then
		self:CommandRetreat()
	elseif highestStress < STRESS_THRESHOLD_LOW then
		self:IssueSearchJob()
	end
end

function DirectorAI:IssueSearchJob()
	if not self.TargetPlayer or not self.TargetPlayer.Character then return end
	
	local root = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	-- Issue a job near the player (with random offset to avoid cheating)
	local offset = Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
	local jobPos = root.Position + offset
	
	table.insert(self.JobQueue, {
		Type = "Search",
		Position = jobPos,
		Timestamp = os.clock()
	})
end

function DirectorAI:CommandRetreat()
	-- Tells Hunter to go to vents/remote areas
	table.insert(self.JobQueue, {
		Type = "Retreat",
		Position = Vector3.new(0, 100, 0), -- Placeholder for vent height/remote
		Timestamp = os.clock()
	})
end

function DirectorAI:PopJob()
	if #self.JobQueue > 0 then
		return table.remove(self.JobQueue, 1)
	end
	return nil
end

return DirectorAI
