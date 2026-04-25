-- SensoryModule.lua
-- Handles vision, hearing, and perception logic for all AI

local SensoryModule = {}

-- SETTINGS

local FOV_ANGLE = 60              -- degrees (vision cone)
local HEARING_FALLOFF = 10        -- multiplier for sound range
local WALL_ATTENUATION = 0.35     -- % of sound that passes through walls

function SensoryModule.CanSee(viewerModel, targetModel, maxDistance)
	if not viewerModel or not targetModel then return false end
	
	local viewerRoot = viewerModel:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	
	if not viewerRoot or not targetRoot then return false end
	
	local direction = targetRoot.Position - viewerRoot.Position
	local distance = direction.Magnitude

	if distance > maxDistance then
		return false
	end
	
	local dirUnit = direction.Unit
	local forward = viewerRoot.CFrame.LookVector
	
	local dot = forward:Dot(dirUnit)
	local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
	
	if angle > FOV_ANGLE then
		return false
	end
	
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {viewerModel}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(
		viewerRoot.Position,
		direction,
		rayParams
	)
	
	-- If we hit something that's NOT the target → blocked
	if result and not result.Instance:IsDescendantOf(targetModel) then
		return false
	end
	
	return true
end

function SensoryModule.CanHear(listenerPos, soundPos, intensity)
	if not listenerPos or not soundPos then return false end
	
	local direction = soundPos - listenerPos
	local distance = direction.Magnitude
	
	-- Max hearing range based on intensity
	local maxRange = intensity * HEARING_FALLOFF
	
	if distance > maxRange then
		return false
	end
	
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local result = workspace:Raycast(listenerPos, direction, rayParams)
	
	if result then
		-- Sound is muffled
		return distance < (maxRange * WALL_ATTENUATION)
	end
	
	return true
end

function SensoryModule.GetMovementNoise(state)	
	if state == "Sprint" then
		return 10   -- very loud
	elseif state == "Run" then
		return 7
	elseif state == "Walk" then
		return 4
	elseif state == "Crouch" then
		return 1   -- very quiet
	end
	
	return 0
end

function SensoryModule.DetectPlayer(aiModel, playerCharacter, visionRange, hearingBoost)
	if not aiModel or not playerCharacter then return false end
	
	local aiRoot = aiModel:FindFirstChild("HumanoidRootPart")
	local playerRoot = playerCharacter:FindFirstChild("HumanoidRootPart")
	
	if not aiRoot or not playerRoot then return false end
	
	-- 1. Vision check
	if SensoryModule.CanSee(aiModel, playerCharacter, visionRange) then
		return true, "Vision"
	end
	
	-- 2. Hearing check
	local movementState = playerCharacter:GetAttribute("MovementState") or "Walk"
	local noise = SensoryModule.GetMovementNoise(movementState)
	
	if SensoryModule.CanHear(aiRoot.Position, playerRoot.Position, noise + (hearingBoost or 0)) then
		return true, "Sound"
	end
	
	return false, nil
end

-- Debug

function SensoryModule.DebugDrawLine(startPos, endPos, color)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = color or Color3.new(1,0,0)
	
	local distance = (endPos - startPos).Magnitude
	
	part.Size = Vector3.new(0.2, 0.2, distance)
	part.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance/2)
	part.Parent = workspace
	
	game:GetService("Debris"):AddItem(part, 0.1)
end

return SensoryModule
