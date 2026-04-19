local AIManager = require(script.AI.AIManager)
local Threat = require(script.AI.Systems.ThreatSystem)
local Metrics = require(script.AI.Systems.Metrics)
local Director = require(script.AI.DirectorAI)

Metrics:Start()
Director:Init()
AIManager:Init()

--Game Loop
game:GetService("RunService").Heartbeat:Connect(function(dt)
	Threat:Update(dt)
	Metrics:Tick(dt)
end)
