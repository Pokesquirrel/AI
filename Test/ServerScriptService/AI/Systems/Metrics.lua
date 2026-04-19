local Metrics = {}

Metrics.Data = {
	Detections = 0,
	Catches = 0,
	Escapes = 0,
	ChaseTime = 0,
	Chasing = false,
	ChaseStart = 0
}

function Metrics:Start()
	self.Data = self.Data
end

function Metrics:PlayerDetected()
	self.Data.Detections += 1
	self.Data.Chasing = true
	self.Data.ChaseStart = os.clock()
end

function Metrics:PlayerCaught()
	self.Data.Catches += 1
	if self.Data.Chasing then
		self.Data.ChaseTime += os.clock() - self.Data.ChaseStart
		self.Data.Chasing = false
	end
end

function Metrics:PlayerEscaped()
	self.Data.Escapes += 1
	if self.Data.Chasing then
		self.Data.ChaseTime += os.clock() - self.Data.ChaseStart
		self.Data.Chasing = false
	end
end

function Metrics:Tick()
	-- passive tracking hook (future expansion)
end

function Metrics:GetReport()
	local total = self.Data.Catches + self.Data.Escapes

	return {
		CatchRate = total > 0 and self.Data.Catches / total or 0,
		AvgChaseTime = self.Data.ChaseTime,
		DetectionCount = self.Data.Detections
	}
end

return Metrics
