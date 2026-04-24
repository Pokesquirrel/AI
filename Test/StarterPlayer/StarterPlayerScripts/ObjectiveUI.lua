local event = game.ReplicatedStorage.GameEvents.ObjectiveUpdate

local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(0.3, 0.05)
label.Position = UDim2.fromScale(0.35, 0.05)
label.TextScaled = true
label.Parent = gui

event.OnClientEvent:Connect(function(collected, total)
	label.Text = collected.." / "..total
end)
