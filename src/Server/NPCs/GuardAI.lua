-- GuardAI.lua
-- Standard security guard AI

local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)
local BT = require(game.ServerScriptService.AI.Shared.BehaviorTree)
local Sensory = require(game.ServerScriptService.AI.Shared.SensoryModule)
local CollectionService = game:GetService("CollectionService")

local GuardAI = setmetatable({}, BaseAI)
GuardAI.__index = GuardAI

function GuardAI.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, GuardAI)
	
	self.PatrolPoints = CollectionService:GetTagged("GuardPath")
	self.CurrentPointIdx = 1
	self.AlertTarget = nil
	
	return self
end

function GuardAI:CheckSenses()
	for _, player in ipairs(game.Players:GetPlayers()) do
		if Sensory.CanSee(self.Model, player.Character, 40) then
			self.AlertTarget = player.Character.HumanoidRootPart.Position
			self.State = "Investigating"
			return BT.NodeStatus.Success
		end
	end
	return BT.NodeStatus.Failure
end

function GuardAI:Investigate()
	if self.AlertTarget then
		self:MoveTo(self.AlertTarget)
		if (self.Root.Position - self.AlertTarget).Magnitude < 5 then
			self.AlertTarget = nil
		end
		return BT.NodeStatus.Running
	end
	return BT.NodeStatus.Failure
end

function GuardAI:Patrol()
	if #self.PatrolPoints == 0 then return BT.NodeStatus.Failure end
	
	local target = self.PatrolPoints[self.CurrentPointIdx]
	self:MoveTo(target.Position)
	
	self.CurrentPointIdx = (self.CurrentPointIdx % #self.PatrolPoints) + 1
	return BT.NodeStatus.Success
end

function GuardAI:Run()
	local Tree = BT.Selector({
		BT.Sequence({
			function() return self:CheckSenses() end,
			function() return self:Investigate() end
		}),
		function() return self:Patrol() end
	})
	
	task.spawn(function()
		while self.Active do
			Tree()
			task.wait(1)
		end
	end)
end

return GuardAI
