local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage.GameEvents.ObjectiveUpdate

local ObjectiveSystem = {}

ObjectiveSystem.Total = 10
ObjectiveSystem.Collected = 0

function ObjectiveSystem:Collect(player)
	self.Collected += 1
	event:FireAllClients(self.Collected, self.Total)

	if self.Collected == self.Total - 1 then
		require(script.Parent.DemoChase):StartFinalHunt(player)
	end

	if self.Collected >= self.Total then
		require(script.Parent.GameStateManager):Win(player)
	end
end

return ObjectiveSystem
