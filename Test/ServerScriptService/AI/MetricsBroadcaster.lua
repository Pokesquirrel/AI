local Metrics = require(script.Parent.Metrics)
local event = game.ReplicatedStorage.GameEvents.DebugMetrics

while true do
	task.wait(2)
	event:FireAllClients(Metrics:GetReport())
end
