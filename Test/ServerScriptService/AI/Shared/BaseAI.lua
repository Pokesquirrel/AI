-- BaseAI.lua
-- Foundation for all NPC entities

local PathfindingService = game:GetService("PathfindingService")

local BaseAI = {}
BaseAI.__index = BaseAI

function BaseAI.new(model)
	local self = setmetatable({}, BaseAI)

	self.Model = model
	self.Humanoid = model:WaitForChild("Humanoid")
	self.Root = model:WaitForChild("HumanoidRootPart")
	
	-- State tracking
	self.Active = true
	self.State = "Idle" -- Idle, Patrolling, Searching, Hunting, Retreating
	
	return self
end

function BaseAI:MoveTo(pos)
	local path = PathfindingService:CreatePath({
		AgentRadius = 3,
		AgentHeight = 6,
		AgentCanJump = true
	})
	
	path:ComputeAsync(self.Root.Position, pos)

	if path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		for i, wp in ipairs(waypoints) do
			if not self.Active then break end
			
			self.Humanoid:MoveTo(wp.Position)
			
			-- Timeout/Blocked logic
			local finished = self.Humanoid.MoveToFinished:Wait(2)
			if not finished then
				-- Recalculate if stuck
				return self:MoveTo(pos)
			end
			
			if wp.Action == Enum.PathWaypointAction.Jump then
				self.Humanoid.Jump = true
			end
		end
	else
		warn("Pathfinding failed for " .. self.Model.Name)
	end
end

function BaseAI:Stop()
	self.Humanoid:MoveTo(self.Root.Position)
end

return BaseAI
