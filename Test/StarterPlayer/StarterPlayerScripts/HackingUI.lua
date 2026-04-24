local UIS = game:GetService("UserInputService")
local event = game.ReplicatedStorage.GameEvents.HackingEvent

local targetWord = "UNLOCK"
local currentIndex = 1

local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(0.4, 0.2)
label.Position = UDim2.fromScale(0.3, 0.1)
label.TextScaled = true
label.Parent = gui

local active = false
local currentLetter = ""

function spawnLetter()
	local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	currentLetter = letters:sub(math.random(1,26), math.random(1,26))
	label.Text = currentLetter
end

function startHack()
	active = true
	currentIndex = 1
	
	while active do
		spawnLetter()
		task.wait(0.8)
	end
end

UIS.InputBegan:Connect(function(input)
	if not active then return end
	
	local key = input.KeyCode.Name
	
	if key == currentLetter then
		if key == targetWord:sub(currentIndex, currentIndex) then
			currentIndex += 1
			
			if currentIndex > #targetWord then
				event:FireServer(true)
				active = false
				label.Text = "SUCCESS"
			end
		else
			event:FireServer(false)
		end
	end
end)

return {
	Start = startHack
}
