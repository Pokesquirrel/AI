local event = game.ReplicatedStorage.GameEvents.DebugMetrics

local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(0.3, 0.2)
label.Position = UDim2.fromScale(0.7, 0.1)
label.TextScaled = true
label.Parent = gui

event.OnClientEvent:Connect(function(data)
	label.Text = "Detections: "..data.DetectionCount
end)
