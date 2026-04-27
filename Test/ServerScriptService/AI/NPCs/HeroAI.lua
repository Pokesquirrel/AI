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

	-- PATH DATA
	self.CurrentPath = nil
	self.PathIndex = 1
	self.LastPathTime = 0
	self.LastGoalPos = Vector3.new()

	-- MOVEMENT SMOOTHING
	self.MoveTarget = nil

	-- RAYCAST PARAMS (filter out self)
	self.RayParams = RaycastParams.new()
	self.RayParams.FilterDescendantsInstances = {model}
	self.RayParams.FilterType = Enum.RaycastFilterType.Exclude

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

	-- SWITCH TO HUNT IMMEDIATELY
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
-- PATH FOLLOW (WITH WALL AVOIDANCE)
-- =========================
function HeroAI:FollowPath()
	if not self.CurrentPath then return end

	local target = self.CurrentPath[self.PathIndex]
	if not target then
		self.CurrentPath = nil
		return
	end

	-- Apply wall avoidance to target position
	local avoidVector = self:GetWallAvoidanceVector()
	local adjustedTarget = target

	if avoidVector.Magnitude > 0.1 then
		adjustedTarget = target + avoidVector * 1.5
	end

	self.MoveTarget = adjustedTarget
	self:MoveTo(adjustedTarget)

	-- Advance to next waypoint when close enough
	if (self.Root.Position - target).Magnitude < 3 then
		self.PathIndex += 1
		if self.PathIndex > #self.CurrentPath then
			self.CurrentPath = nil
		end
	end
end

-- =========================
-- WALL AVOIDANCE
-- =========================
function HeroAI:GetWallAvoidanceVector()
	local avoidVector = Vector3.new(0, 0, 0)
	local rayDistance = 4

	-- Cast rays in multiple directions
	local angles = {-120, -90, -60, -30, 0, 30, 60, 90, 120}

	for _, angleDeg in ipairs(angles) do
		local angle = math.rad(angleDeg)
		local direction = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), angle) * self.Root.CFrame.LookVector

		local rayResult = workspace:Raycast(
			self.Root.Position + Vector3.new(0, 2, 0),
			direction * rayDistance,
			self.RayParams
		)

		if rayResult then
			local hitDist = (rayResult.Position - self.Root.Position).Magnitude
			local strength = math.pow((rayDistance - hitDist) / rayDistance, 2) * 2

			local normal = rayResult.Normal
			local pushDir = Vector3.new(normal.X, 0, normal.Z)
			if pushDir.Magnitude > 0.1 then
				pushDir = pushDir.Unit
				avoidVector = avoidVector + pushDir * strength
			end
		end
	end

	return avoidVector
end

-- =========================
-- HUNT MODE (PATHFINDING TO PLAYER)
-- =========================
function HeroAI:Hunt()
	if not self.HuntTarget or not self.HuntTarget.Character then return end

	local root = self.HuntTarget.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local dist = (self.Root.Position - root.Position).Magnitude

	-- Kill player if close enough
	if dist < 5 then
		local hum = self.HuntTarget.Character:FindFirstChild("Humanoid")
		if hum then hum.Health = 0 end
		Metrics:PlayerDetected()
		return
	end

	-- Use A* pathfinding to reach player
	local path = self:GetPath(root.Position)

	if path then
		self.CurrentPath = path
	else
		-- Fallback: direct movement with wall avoidance
		local avoidVector = self:GetWallAvoidanceVector()
		local targetPos = root.Position
		if avoidVector.Magnitude > 0.1 then
			targetPos = targetPos + avoidVector * 2
		end
		self.MoveTarget = targetPos
		self:MoveTo(targetPos)
	end
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
		-- Apply wall avoidance
		local avoidVector = self:GetWallAvoidanceVector()
		if avoidVector.Magnitude > 0.1 then
			targetPos = targetPos + avoidVector * 2
		end
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
