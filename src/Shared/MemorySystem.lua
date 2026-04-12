-- MemorySystem.lua
-- Tracks last known positions and durations

local MemorySystem = {}

function MemorySystem.new(maxDuration)
	return {
		LastPosition = nil,
		Timestamp = 0,
		MaxDuration = maxDuration or 10
	}
end

function MemorySystem:Update(memory, pos)
	memory.LastPosition = pos
	memory.Timestamp = os.clock()
end

function MemorySystem:IsCurrent(memory)
	if not memory.LastPosition then return false end
	return (os.clock() - memory.Timestamp) < memory.MaxDuration
end

function MemorySystem:Forget(memory)
	memory.LastPosition = nil
end

return MemorySystem
