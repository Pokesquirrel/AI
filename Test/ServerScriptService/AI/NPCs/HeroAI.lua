-- HeroAI.lua (The BIG AI)
-- Advanced sensory-driven agent with Dual-AI support

local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)
local Sensory = require(game.ReplicatedStorage.Shared.SensoryModule)
local Memory = require(game.ReplicatedStorage.Shared.MemorySystem)
local Director = require(script.Parent.Parent.DirectorAI)
local Threat = require(script.Parent.Parent.Systems.ThreatSystem)
local Metrics = require(script.Parent.Parent.Systems.Metrics)

local HeroAI = setmetatable({}, BaseAI)
HeroAI.__index = HeroAI

function HeroAI.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, HeroAI)
	self.Memory = Memory.new(10)
	self.Target = nil
	return self
end

-- Heuristic Function
function HeroAI:ScoreTarget(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return -math.huge end

	local dist = (self.Root.Position - root.Position).Magnitude
	local stress = Threat:GetStress(player)

	local visible = Sensory.CanSee(self.Model, player.Character, 60)

	return (100 - dist) + (stress * 2) + (visible and 50 or 0)
end

function HeroAI:Think()
	local bestScore = -math.huge
	local bestPlayer = nil

	for _, p in ipairs(game.Players:GetPlayers()) do
		local score = self:ScoreTarget(p)
		if score > bestScore then
			bestScore = score
			bestPlayer = p
		end
	end

	self.Target = bestPlayer
end

function HeroAI:Chase()
	if not self.Target or not self.Target.Character then return end

	local root = self.Target.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	self:MoveTo(root.Position)

	Metrics:PlayerDetected()
end

function HeroAI:Search()
	local job = Director:PopJob()

	if job then
		self:MoveTo(job.Position)
	else
		self:MoveTo(self.Root.Position + Vector3.new(math.random(-20,20),0,math.random(-20,20)))
	end
end

function HeroAI:Run()
	task.spawn(function()
		while self.Active do
			self:Think()

			if self.Target then
				self:Chase()
			else
				self:Search()
			end

			task.wait(0.5)
		end
	end)
end

return HeroAI
