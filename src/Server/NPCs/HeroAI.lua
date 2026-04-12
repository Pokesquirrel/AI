-- HeroAI.lua (The BIG AI)
-- Advanced sensory-driven agent with Dual-AI support

local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)
local BT = require(game.ServerScriptService.AI.Shared.BehaviorTree)
local Sensory = require(game.ServerScriptService.AI.Shared.SensoryModule)
local Memory = require(game.ServerScriptService.AI.Shared.MemorySystem)
local Director = require(game.ServerScriptService.AI.Server.DirectorAI)

local HeroAI = setmetatable({}, BaseAI)
HeroAI.__index = HeroAI

function HeroAI.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, HeroAI)
	
	self.Memory = Memory.new(15) -- Remembers for 15 seconds
	self.CurrentJob = nil
	self.Leaning = {} -- Place for "unlocked" behaviors
	
	return self
end

-- BEHAVIORS
function HeroAI:CheckDirectorJob()
	if not self.CurrentJob then
		self.CurrentJob = Director:PopJob()
		if self.CurrentJob then
			self.State = self.CurrentJob.Type
			return BT.NodeStatus.Success
		end
	end
	return BT.NodeStatus.Failure
end

function HeroAI:Perceive()
	for _, player in ipairs(game.Players:GetPlayers()) do
		if Sensory.CanSee(self.Model, player.Character, 60) then
			Memory:Update(self.Memory, player.Character.HumanoidRootPart.Position)
			self.State = "Hunting"
			return BT.NodeStatus.Success
		end
	end
	return BT.NodeStatus.Failure
end

function HeroAI:Chase()
	if self.Memory.LastPosition then
		self:MoveTo(self.Memory.LastPosition)
		if (self.Root.Position - self.Memory.LastPosition).Magnitude < 5 then
			Memory:Forget(self.Memory)
		end
		return BT.NodeStatus.Running
	end
	return BT.NodeStatus.Failure
end

function HeroAI:ExecuteJob()
	if self.CurrentJob then
		self:MoveTo(self.CurrentJob.Position)
		self.CurrentJob = nil
		return BT.NodeStatus.Success
	end
	return BT.NodeStatus.Failure
end

function HeroAI:Patrol()
	self.State = "Patrolling"
	local randomPos = self.Root.Position + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
	self:MoveTo(randomPos)
	return BT.NodeStatus.Success
end

-- RUN LOOP
function HeroAI:Run()
	local Tree = BT.Selector({
		-- Priority 1: Direct Perception (Chase)
		BT.Sequence({
			function() return self:Perceive() end,
			function() return self:Chase() end
		}),
		-- Priority 2: Director Instructions
		BT.Sequence({
			function() return self:CheckDirectorJob() end,
			function() return self:ExecuteJob() end
		}),
		-- Priority 3: Idle Patrol
		function() return self:Patrol() end
	})
	
	task.spawn(function()
		while self.Active do
			Tree()
			task.wait(0.5)
		end
	end)
end

return HeroAI
