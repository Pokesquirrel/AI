-- DroneAI.lua
-- Weakest AI, alerts others upon detection

local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)
local BT = require(game.ServerScriptService.AI.Shared.BehaviorTree)
local Sensory = require(game.ServerScriptService.AI.Shared.SensoryModule)
local Director = require(game.ServerScriptService.AI.Server.DirectorAI)

local DroneAI = setmetatable({}, BaseAI)
DroneAI.__index = DroneAI

function DroneAI.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, DroneAI)
	return self
end

function DroneAI:SpottedPlayer()
	for _, player in ipairs(game.Players:GetPlayers()) do
		if Sensory.CanSee(self.Model, player.Character, 80) then
			-- Alert the Director immediately
			Director:IssueSearchJob() -- Forces Director to look at player
			
			-- Vibe/Effect logic would go here (sirens, etc)
			print("Drone spotted player " .. player.Name)
			return BT.NodeStatus.Success
		end
	end
	return BT.NodeStatus.Failure
end

function DroneAI:RandomPatrol()
	local randomPos = self.Root.Position + Vector3.new(math.random(-50, 50), 20, math.random(-50, 50))
	self:MoveTo(randomPos)
	return BT.NodeStatus.Success
end

function DroneAI:Run()
	local Tree = BT.Selector({
		function() return self:SpottedPlayer() end,
		function() return self:RandomPatrol() end
	})
	
	task.spawn(function()
		while self.Active do
			Tree()
			task.wait(2)
		end
	end)
end

return DroneAI
