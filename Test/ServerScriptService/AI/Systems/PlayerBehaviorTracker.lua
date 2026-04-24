local Players = game:GetService("Players")

local Tracker = {}
Tracker.Data = {}

function Tracker:InitPlayer(player)
	self.Data[player] = {
		Vent = 0,
		Locker = 0,
		Crate = 0
	}
end

function Tracker:Record(player, hideType)
	if self.Data[player] and self.Data[player][hideType] then
		self.Data[player][hideType] += 1
	end
end

function Tracker:GetPreference(player)
	local data = self.Data[player]
	if not data then return nil end

	local best, max = nil, -1

	for k,v in pairs(data) do
		if v > max then
			max = v
			best = k
		end
	end

	return best
end

Players.PlayerAdded:Connect(function(player)
	Tracker:InitPlayer(player)
end)

return Tracker
