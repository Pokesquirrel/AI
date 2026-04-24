local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

local NoiseEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("NoiseEvent")

local stamina = 100
local maxStamina = 100

local isSprinting = false
local isCrouching = false

-- SETTINGS
local WALK_SPEED = 10
local SPRINT_SPEED = 18
local CROUCH_SPEED = 6

-- INPUT
UserInput.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		isCrouching = true
	end
end)

UserInput.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then
		isCrouching = false
	end
end)

-- LOOP
RunService.RenderStepped:Connect(function(dt)
	if not char or not humanoid then return end

	local speed = WALK_SPEED
	local noise = 1

	if isCrouching then
		speed = CROUCH_SPEED
		noise = 0.2
	elseif isSprinting and stamina > 0 then
		speed = SPRINT_SPEED
		stamina -= 20 * dt
		noise = 5
	else
		stamina = math.min(maxStamina, stamina + 10 * dt)
	end

	humanoid.WalkSpeed = speed

	-- Emit noise
	if humanoid.MoveDirection.Magnitude > 0 then
		NoiseEvent:FireServer(char.HumanoidRootPart.Position, noise)
	end
end)
