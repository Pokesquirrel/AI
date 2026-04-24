local event = game.ReplicatedStorage.GameEvents.LockpickEvent
local Threat = require(game.ServerScriptService.AI.Systems.ThreatSystem)
local Objective = require(script.Parent.ObjectiveSystem)

event.OnServerEvent:Connect(function(player, success)
	if success then
		Objective:Collect(player)
	else
		Threat:AddStress(player, 10)
	end
end)
