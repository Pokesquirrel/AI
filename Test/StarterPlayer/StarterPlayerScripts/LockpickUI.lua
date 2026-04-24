local UIS = game:GetService("UserInputService")
local event = game.ReplicatedStorage.GameEvents.LockpickEvent

local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.3, 0.2)
frame.Position = UDim2.fromScale(0.35, 0.7)
frame.Visible = false
frame.Parent = gui

local pin = Instance.new("Frame")
pin.Size = UDim2.fromScale(0.1, 0.5)
pin.Position = UDim2.fromScale(0.45, 1)
pin.BackgroundColor3 = Color3.new(1,1,1)
pin.Parent = frame

local active = false
local successZone = 0.2

function startLockpick()
	frame.Visible = true
	active = true
	
	while active do
		for i = 1, 20 do
			pin.Position = UDim2.fromScale(0.45, 1 - (i/20))
			task.wait(0.03)
		end
		
		for i = 20, 1, -1 do
			pin.Position = UDim2.fromScale(0.45, 1 - (i/20))
			task.wait(0.03)
		end
	end
end

UIS.InputBegan:Connect(function(input)
	if not active then return end
	
	if input.KeyCode == Enum.KeyCode.E then
		local y = pin.Position.Y.Scale
		
		if y < successZone then
			event:FireServer(true)
			active = false
			frame.Visible = false
		else
			event:FireServer(false)
		end
	end
end)

return {
	Start = startLockpick
}
