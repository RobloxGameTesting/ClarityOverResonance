local Spring = {}
Spring.__index = Spring

function Spring.new(value, value2, p)
	return (setmetatable({
		pos = p or Vector3.new(0, 0, 0),
		vel = Vector3.new(0, 0, 0),
		freq = value or 2,
		damp = value2 or 1
	}, Spring))
end

function Spring:step(p, p2)
	local v = self.freq * 2 * 3.141592653589793

	local v2 = v * v * (p - self.pos) - 2 * self.damp * v * self.vel

	self.vel += v2 * p2

	self.pos += self.vel * p2
	return self.pos
end

return Spring