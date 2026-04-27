local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)
local Sensory = require(game.ReplicatedStorage.Shared.SensoryModule)
local Memory = require(game.ReplicatedStorage.Shared.MemorySystem)
local Director = require(game.ServerScriptService.DirectorAI)
local Threat = require(script.Parent.Parent.Systems.ThreatSystem)
local Metrics = require(script.Parent.Parent.Systems.Metrics)
local Tracker = require(game.ServerScriptService.AI.Systems.PlayerBehaviorTracker)
local AStar = require(game.ServerScriptService.AI.Systems.AStar)
local Players = game:GetService("Players")

local HeroAI = setmetatable({}, BaseAI)
HeroAI.__index = HeroAI

function HeroAI.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, HeroAI)

	self.Memory = Memory.new(10)

	self.Target = nil
	self.State = "Patrol"
	self.HuntTarget = nil

	self.CurrentPath = nil
	self.PathIndex = 1
	self.LastPathTime = 0
	self.LastGoalPos = Vector3.new()

	self.MoveTarget = nil

	return self
end

-- =========================
-- TARGET SCORE
-- =========================
function HeroAI:ScoreTarget(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return -math.huge end

	local dist = (self.Root.Position - root.Position).Magnitude
	local stress = Threat:GetStress(player)
	local visible = Sensory.CanSee(self.Model, player.Character, 60)

	return (100 - dist) + (stress * 2) + (visible and 50 or 0)
end

-- =========================
-- THINK
-- =========================
function HeroAI:Think()
	local bestScore = -math.huge
	local bestPlayer = nil

	for _, p in ipairs(Players:GetPlayers()) do
		local score = self:ScoreTarget(p)
		if score > bestScore then
			bestScore = score
			bestPlayer = p
		end
	end

	self.Target = bestPlayer

	if self.Target and self.Target.Character then
		local seen = Sensory.CanSee(self.Model, self.Target.Character, 60)

		if seen then
			self.State = "Hunt"
			self.HuntTarget = self.Target
		else
			self.State = "Patrol"
			self.HuntTarget = nil
		end
	end
end

-- =========================
-- PATH REQUEST (3s cooldown)
-- =========================
function HeroAI:GetPath(goalPos)
	local now = tick()

	if self.Target and self.Target.Character then
		local root = self.Target.Character:FindFirstChild("HumanoidRootPart")
		if root then
			if (self.LastGoalPos - root.Position).Magnitude > 10 then
				self.LastPathTime = 0
			end
			self.LastGoalPos = root.Position
		end
	end

	if self.CurrentPath and (now - self.LastPathTime < 3) then
		return self.CurrentPath
	end

	self.LastPathTime = now
	self.CurrentPath = AStar.FindPath(self.Root.Position, goalPos, 6)
	self.PathIndex = 1

	return self.CurrentPath
end

-- =========================
-- PATH FOLLOW (FIXED RAYCAST)
-- =========================
function HeroAI:FollowPath()
	if not self.CurrentPath then return end

	local target = self.CurrentPath[self.PathIndex]
	if not target then return end

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {self.Model}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local origin = self.Root.Position
	local direction = (target - origin)

	local result = workspace:Raycast(origin, direction, rayParams)

	-- ✅ FIX: only treat as wall if NOT the target player
	if result then
		if not (self.Target and self.Target.Character and result.Instance:IsDescendantOf(self.Target.Character)) then
			self.PathIndex += 1
			return
		end
	end

	self.MoveTarget = target
	self:MoveTo(target)

	if (self.Root.Position - target).Magnitude < 3 then
		self.PathIndex += 1
	end
end

-- =========================
-- DIRECT CHASE (HUNT MODE)
-- =========================
function HeroAI:Hunt()
	if not self.HuntTarget or not self.HuntTarget.Character then return end

	local root = self.HuntTarget.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local dist = (self.Root.Position - root.Position).Magnitude

	if dist < 5 then
		local hum = self.HuntTarget.Character:FindFirstChild("Humanoid")
		if hum then hum.Health = 0 end
		Metrics:PlayerDetected()
		return
	end

	self.MoveTarget = root.Position
	self:MoveTo(root.Position)
end

-- =========================
-- PATROL / SEARCH
-- =========================
function HeroAI:Search()
	local job = Director:PopJob()

	local targetPos = job and job.Position or (
		self.Root.Position + Vector3.new(
			math.random(-20, 20),
			0,
			math.random(-20, 20)
		)
	)

	local path = self:GetPath(targetPos)

	if path then
		self.CurrentPath = path
	else
		self:MoveTo(targetPos)
	end
end

-- =========================
-- MAIN LOOP
-- =========================
function HeroAI:RunStep()
	self:Think()

	if self.State == "Hunt" then
		self:Hunt()
	elseif self.Target then
		self:Search()
	end

	self:FollowPath()
end

function HeroAI:Run()
	task.spawn(function()
		while self.Active do
			self:RunStep()
			task.wait(0.15)
		end
	end)
end

return HeroAI
