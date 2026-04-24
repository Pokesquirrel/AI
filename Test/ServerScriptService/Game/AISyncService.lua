local Director = require(game.ServerScriptService.AI.DirectorAI)

local Sync = {}

function Sync:Run()
	task.spawn(function()
		while true do
			local job = Director:PopJob()

			if job then
				for _, npc in ipairs(workspace:GetChildren()) do
					if npc:FindFirstChild("Humanoid") then
						npc:SetAttribute("AI_STATE", job.Type)
					end
				end
			end

			task.wait(0.5)
		end
	end)
end

return Sync
