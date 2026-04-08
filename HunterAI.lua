local Players = game:GetService("Players")

local BaseAI = require(script.Parent.BaseAI)
local BT = require(script.Parent.BehaviorTree)
local MemorySystem = require(script.Parent.MemorySystem)
local SoundSystem = require(script.Parent.SoundSystem)
local DirectorAI = require(script.Parent.DirectorAI)

local Hunter = setmetatable({}, BaseAI)
Hunter.__index = Hunter

-- 🧠 CONSTRUCTOR
function Hunter.new(model)
    local self = BaseAI.new(model)
    setmetatable(self, Hunter)

    self.Type = "Hunter"

    -- Memory system
    self.Memory = MemorySystem.new(8)

    -- Targets
    self.TargetPlayer = nil
    self.TargetPosition = nil

    return self
end

-- 👁️ VISION (FOV + LOS)
function Hunter:CanSeePlayer(player)
    if not player.Character then return false end
    if player.Character:GetAttribute("Hidden") then return false end
    if self.Model:GetAttribute("Blinded") then return false end

    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local direction = (root.Position - self.Root.Position)
    local distance = direction.Magnitude

    if distance > 60 then return false end

    local dirUnit = direction.Unit
    local forward = self.Root.CFrame.LookVector

    -- FOV check
    local dot = forward:Dot(dirUnit)
    local angle = math.deg(math.acos(dot))
    if angle > 45 then return false end

    -- Line of sight
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {self.Model}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(self.Root.Position, dirUnit * distance, rayParams)

    return result and result.Instance:IsDescendantOf(player.Character)
end

-- 🔊 HEARING
function Hunter:HearNoise(position, intensity)
    local dist = (self.Root.Position - position).Magnitude

    if dist < intensity * 6 and SoundSystem:CanHear(self.Root.Position, position) then
        self.TargetPosition = position
    end
end

-- 🎯 FIND TARGET
function Hunter:FindTarget()
    for _, player in ipairs(Players:GetPlayers()) do
        if self:CanSeePlayer(player) then
            self.TargetPlayer = player

            MemorySystem:Update(self.Memory, player.Character.HumanoidRootPart.Position)
            return true
        end
    end

    self.TargetPlayer = nil
    return false
end

-- 🏃 CHASE
function Hunter:Chase()
    if not self.TargetPlayer then return false end
    if not self.TargetPlayer.Character then return false end

    local root = self.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    self:MoveTo(root.Position)
    return true
end

-- 🔍 SEARCH LAST KNOWN
function Hunter:Search()
    if not MemorySystem:IsValid(self.Memory) then return false end

    local pos = self.Memory.LastSeenPosition
    if not pos then return false end

    -- Move to last seen
    self:MoveTo(pos)

    -- Wander around
    local offset = Vector3.new(math.random(-10,10), 0, math.random(-10,10))
    self:MoveTo(pos + offset)

    return true
end

-- 🔎 INVESTIGATE SOUND
function Hunter:Investigate()
    if not self.TargetPosition then return false end

    self:MoveTo(self.TargetPosition)
    self.TargetPosition = nil

    return true
end

-- 🚶 PATROL
function Hunter:Patrol()
    local randomPos = self.Root.Position + Vector3.new(
        math.random(-30,30),
        0,
        math.random(-30,30)
    )

    self:MoveTo(randomPos)
    return true
end

-- 🌳 BUILD BEHAVIOR TREE
function Hunter:BuildTree()
    return BT.Selector({
        BT.Sequence({
            function() return self:FindTarget() end,
            function() return self:Chase() end
        }),
        function() return self:Search() end,
        function() return self:Investigate() end,
        function() return self:Patrol() end
    })
end

-- ▶️ MAIN LOOP
function Hunter:Run()
    local Tree = self:BuildTree()

    while true do
        Tree()

        -- Adjust memory based on stress
        local aggression = DirectorAI:GetAggression()

        if aggression == "HIGH" then
            self.Memory.Duration = 15
        elseif aggression == "MEDIUM" then
            self.Memory.Duration = 10
        else
            self.Memory.Duration = 6
        end

        task.wait(0.2)
    end
end

return Hunter
