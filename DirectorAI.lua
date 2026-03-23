-- DirectorAI.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NoiseEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("NoiseEvent")

local DirectorAI = {}

DirectorAI.LastKnownPlayerPos = nil
DirectorAI.AlertLevel = 0

-- Track players constantly (but don’t directly give exact info)
function DirectorAI:UpdatePlayerTracking()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local pos = player.Character.HumanoidRootPart.Position

                -- Only occasionally update (keeps tension)
                if math.random() < 0.1 then
                    self.LastKnownPlayerPos = pos
                end
            end
        end
        task.wait(1)
    end
end

-- React to noise
NoiseEvent.OnServerEvent:Connect(function(player, position, intensity)
    DirectorAI.LastKnownPlayerPos = position
    DirectorAI.AlertLevel = math.clamp(DirectorAI.AlertLevel + intensity, 0, 100)
end)

function DirectorAI:GetHintPosition()
    if not self.LastKnownPlayerPos then return nil end

    -- Add randomness so AI isn't perfect
    local offset = Vector3.new(
        math.random(-20, 20),
        0,
        math.random(-20, 20)
    )

    return self.LastKnownPlayerPos + offset
end

return DirectorAI
