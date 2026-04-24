local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage.GameEvents.GameStateEvent

local GameState = {}

function GameState:Win(player)
	event:FireAllClients("WIN", player.Name)
end

function GameState:Lose(player)
	event:FireAllClients("LOSE", player.Name)
end

function GameState:Restart()
	for _, p in ipairs(game.Players:GetPlayers()) do
		p:LoadCharacter()
	end
end

return GameState
