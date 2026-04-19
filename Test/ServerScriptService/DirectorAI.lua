-- DirectorAI.lua (OmniVision)
-- Managing game pacing, player stress, and Hunter jobs
local Players = game:GetService("Players")
local Threat = require(script.Parent.Systems.ThreatSystem)

local DirectorAI = {}
DirectorAI.JobQueue = {}

function DirectorAI:Init()
	task.spawn(function()
		while true do
			self:Update()
			task.wait(1)
		end
	end)
end

function DirectorAI:Update()
	local highest = 0
	local target = nil

	for _, p in ipairs(Players:GetPlayers()) do
		local s = Threat:GetStress(p)
		if s > highest then
			highest = s
			target = p
		end
	end

	-- Settings
	if highest > 75 then
		self:BroadcastState("HUNT")
	elseif highest < 25 then
		self:BroadcastState("SEARCH")
	end
end

function DirectorAI:BroadcastState(state)
	table.insert(self.JobQueue, {
		Type = state,
		Position = Vector3.new(math.random(-50,50), 0, math.random(-50,50)),
		Time = os.clock()
	})
end

function DirectorAI:PopJob()
	return table.remove(self.JobQueue, 1)
end

return DirectorAI
