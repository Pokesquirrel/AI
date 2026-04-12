-- Behavioral Tree Implementation for Roblox Luau
local BehaviorTree = {}

BehaviorTree.NodeStatus = {
	Success = "Success",
	Failure = "Failure",
	Running = "Running"
}

-- BASE NODE
local Node = {}
Node.__index = Node
function Node.new(action)
	return setmetatable({ action = action }, Node)
end
function Node:run(...)
	return self.action(...)
end

-- SELECTOR: Runs children until one succeeds
function BehaviorTree.Selector(children)
	return function(...)
		for _, child in ipairs(children) do
			local status = child(...)
			if status ~= BehaviorTree.NodeStatus.Failure then
				return status
			end
		end
		return BehaviorTree.NodeStatus.Failure
	end
end

-- SEQUENCE: Runs children until one fails
function BehaviorTree.Sequence(children)
	return function(...)
		for _, child in ipairs(children) do
			local status = child(...)
			if status ~= BehaviorTree.NodeStatus.Success then
				return status
			end
		end
		return BehaviorTree.NodeStatus.Success
	end
end

-- TASK (LEAF)
function BehaviorTree.Task(action)
	return action
end

return BehaviorTree
