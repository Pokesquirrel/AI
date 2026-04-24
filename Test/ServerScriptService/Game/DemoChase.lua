local Director = require(game.ServerScriptService.AI.DirectorAI)
local Threat = require(game.ServerScriptService.AI.Systems.ThreatSystem)

local Demo = {}

function Demo:StartFinalHunt(player)
	Threat:AddStress(player, 80)

	for i = 1, 5 do
		Director:IssueSearchJob()
	end
end

return Demo
