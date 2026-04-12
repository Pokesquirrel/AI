-- NoiseSystem.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NoiseEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("NoiseEvent")

local NoiseSystem = {}

function NoiseSystem:MakeNoise(player, position, intensity)
    NoiseEvent:FireAllClients(player, position, intensity)
    NoiseEvent:FireServer(player, position, intensity)
end

return NoiseSystem
