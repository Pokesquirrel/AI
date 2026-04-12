-- SensoryModule.lua
-- Handles line-of-sight and sound detection

local SensoryModule = {}

-- Constant for standard Roblox field of view (degrees)
local FOV_ANGLE = 45 

function SensoryModule.CanSee(viewer, targetModel, maxDistance)
	local viewerRoot = viewer:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	
	if not viewerRoot or not targetRoot then return false end
	
	local direction = (targetRoot.Position - viewerRoot.Position)
	local distance = direction.Magnitude
	
	if distance > maxDistance then return false end
	
	-- FOV check
	local dirUnit = direction.Unit
	local forward = viewerRoot.CFrame.LookVector
	local dot = forward:Dot(dirUnit)
	local angle = math.deg(math.acos(dot))
	
	if angle > FOV_ANGLE then return false end
	
	-- Raycast check for obstruction
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {viewer, targetModel}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local result = workspace:Raycast(viewerRoot.Position, direction, rayParams)
	
	-- If nothing hit, or we hit the target model, we have line of sight
	return result == nil
end

function SensoryModule.CanHear(listenerPos, soundPos, intensity)
	local distance = (listenerPos - soundPos).Magnitude
	
	-- Simple falloff: audibility threshold is intensity * scalar
	local threshold = intensity * 10 
	
	if distance > threshold then return false end
	
	-- Optional: Add wall attenuation
	local rayParams = RaycastParams.new()
	local result = workspace:Raycast(listenerPos, (soundPos - listenerPos))
	
	if result then
		-- Sound is muffled by walls
		return distance < (threshold * 0.3)
	end
	
	return true
end

return SensoryModule
