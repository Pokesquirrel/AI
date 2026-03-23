-- HunterAI.lua
local PathfindingService = game:GetService("PathfindingService")
local DirectorAI = require(script.Parent:WaitForChild("DirectorAI"))

local Hunter = {}
Hunter.Model = workspace:WaitForChild("Monster")
Hunter.Humanoid = Hunter.Model:WaitForChild("Humanoid")
Hunter.Root = Hunter.Model:WaitForChild("HumanoidRootPart")

Hunter.State = "PATROL"
Hunter.TargetPosition = nil

-- Vision check
function Hunter:CanSeePlayer(player)
    if not player.Character then return false end
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local direction = (root.Position - self.Root.Position).Unit
    local ray = Ray.new(self.Root.Position, direction * 50)

    local hit = workspace:FindPartOnRay(ray, self.Model)
    return hit and hit:IsDescendantOf(player.Character)
end

-- Move using pathfinding
function Hunter:MoveTo(position)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(self.Root.Position, position)

    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            self.Humanoid:MoveTo(waypoint.Position)
            self.Humanoid.MoveToFinished:Wait()
        end
    end
end

-- Attack logic
function Hunter:Attack(player)
    print("Attacking:", player.Name)
    -- Add damage logic here
end

-- Main loop
function Hunter:Run()
    while true do
        local hint = DirectorAI:GetHintPosition()

        if hint then
            self.State = "INVESTIGATE"
            self:MoveTo(hint)
        else
            self.State = "PATROL"
            self:MoveTo(self.Root.Position + Vector3.new(math.random(-30,30),0,math.random(-30,30)))
        end

        -- Check for players
        for _, player in ipairs(game.Players:GetPlayers()) do
            if self:CanSeePlayer(player) then
                self.State = "CHASE"
                self:MoveTo(player.Character.HumanoidRootPart.Position)
                self:Attack(player)
            end
        end

        task.wait(0.5)
    end
end

return Hunter
