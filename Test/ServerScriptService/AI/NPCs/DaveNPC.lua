-- DaveNPC.lua
-- Informant NPC that guides players

local BaseAI = require(game.ServerScriptService.AI.Shared.BaseAI)

local DaveNPC = setmetatable({}, BaseAI)
DaveNPC.__index = DaveNPC

function DaveNPC.new(model)
	local self = BaseAI.new(model)
	setmetatable(self, DaveNPC)
	
	-- Dave's script/story feed
	self.CurrentDialogueIdx = 1
	self.StoryFeed = {
		"Welcome to the facility. Keep it quiet if you want to live.",
		"The guards aren't your only problem. Something is hunting.",
		"I can see the security terminal from here. Get to the second floor.",
		"Careful, drones are everywhere."
	}
	
	return self
end

-- Simulating interaction
function DaveNPC:Interact(player)
	local msg = self.StoryFeed[self.CurrentDialogueIdx]
	print("Dave to " .. player.Name .. ": " .. msg)
	
	-- Increment dialogue
	self.CurrentDialogueIdx = (self.CurrentDialogueIdx % #self.StoryFeed) + 1
	return msg
end

function DaveNPC:Run()
	-- Dave mostly stays put or wanders slightly
	task.spawn(function()
		while self.Active do
			local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
			self:MoveTo(self.Root.Position + offset)
			task.wait(10)
		end
	end)
end

return DaveNPC
