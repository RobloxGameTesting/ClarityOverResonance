local v = {}

local v2 = {
	PULSE_SPEED = 5,
	SEQ_SPEED = 8,
	TRAIL_DECAY = 4,
	VERTICAL_SPEED = 6,
	MTXI_BASE_SPEED = 2,
	BLOOM_FACTOR = 8,
	MTXI_GLOW = Color3.fromRGB(1500, 1500, 1500),
	CACHE_INTERVAL = 10
}

local v3 = {
	{ 1 },
	{ 2, 6, 7 },
	{ 3, 5, 7 },
	{ 4 }
}

local function setProp(p, p2, p3) -- 6 equivalent calls inferred from this helper
	if p[p2] ~= p3 then
		p[p2] = p3
	end
end

local function GetColor(r, g, b)
	if r < 10 and g < 10 and b < 10 then
		return Color3.fromRGB(255, 255, 255)
	end

	return (Color3.fromRGB(r < 10 and 0 or r, g < 10 and 0 or g, b < 10 and 0 or b))
end

local function ProcessEffect(p, p2, p3, p4)
	local result = table.create(7, 0)

	if typeof(p[p3]) ~= "number" then
		p[p3] = 0
	end

	if p2 < 20 then
		result[1] = 1
		result[2] = 1
		result[3] = 1
		result[4] = 1
		result[5] = 1
		result[6] = 1
		result[7] = 1
	elseif p2 <= 59 then
		p[p3] = (p[p3] + 1 / 60 * v2.PULSE_SPEED) % 6.283185307179586
		local midpoint = (math.sin(p[p3]) + 1) / 2
		result[7] = midpoint
		result[1] = 1 - midpoint
		result[2] = 1 - midpoint
		result[3] = 1 - midpoint
		result[4] = 1 - midpoint
		result[5] = 1 - midpoint
		result[6] = 1 - midpoint
	elseif p2 <= 79 then
		p[p3] = (p[p3] + 1 / 60 * v2.SEQ_SPEED) % 6
		result[math.floor(p[p3]) + 1] = 1
	elseif p2 <= 129 then
		local v4 = (p2 - 80) / 49
		p[p3] = (p[p3] + 1 / 60 * v2.SEQ_SPEED) % 6
		local v5 = math.floor(p[p3]) + 1

		if not p[p4] then
			p[p4] = table.create(7, 0)
		end

		for i = 1, 6 do
			if i == v5 then
				p[p4][i] = 1
			else
				p[p4][i] = math.max(0, p[p4][i] - 1 / 60 * v2.TRAIL_DECAY * (1.1 - v4))
			end

			result[i] = p[p4][i]
		end
	elseif p2 <= 219 then
		p[p3] = (p[p3] + 1 / 60 * v2.VERTICAL_SPEED) % 4
		local v4 = math.floor(p[p3]) + 1

		for i, list in ipairs(v3) do
			for _, item in ipairs(list) do
				local v5 = i == v4 and 1 or 0

				if item == 7 then
					v5 *= 0.5
				end

				result[item] = v5
			end
		end
	end

	return result, nil
end

local function ApplyToGroup(state, items, p, str, p2, p3, data, _)
	if str > 10 then
		if str <= 200 then
			local v4 = 2 + (str - 10) / 190 * 20
			state.strobeT = (state.strobeT or 0) + 1 / 60
			local strobeT = state.strobeT

			if 1 / v4 <= strobeT then
				state.strobeT = 0
				state.strobeOn = not state.strobeOn
			end

			p = state.strobeOn and p or 0
		else
			p = math.random(0, 255) > 127 and p or 0
		end
	end

	local color = Color3.new(data.R * v2.BLOOM_FACTOR, data.G * v2.BLOOM_FACTOR, data.B * v2.BLOOM_FACTOR)

	for k, decal in pairs(items) do
		local v4 = 1 - p / 255 * (p2[k] or 1)

		if not decal:IsA("Decal") then
			continue
		end

		if decal.Name:find("DIM") then
			setProp(decal, "Transparency", v4) -- inferred equivalent call
			local v5

			if p3 then
				v5 = Color3.new(1, 1, 1) or color
			else
				v5 = color
			end

			setProp(decal, "Color3", v5) -- inferred equivalent call
		elseif decal.Name == "MTXI" then
			setProp(decal, "Transparency", p3 and v4 or 1) -- inferred equivalent call

			if p3 then
				setProp(decal, "OffsetStudsU", p3) -- inferred equivalent call
				setProp(decal, "Color3", v2.MTXI_GLOW) -- inferred equivalent call
			end
		end
	end
end

return {
	FixtureChannel = 11,
	Update = function(p, buf, p2)
		local v4 = v[p]

		if not v4 then
			v4 = {
				lastCache = 0,
				ringParts = {},
				reflectorParts = {},
				insideParts = {},
				loadedCount = 0
			}
			v[p] = v4
		end

		if v4.loadedCount < 17 then
			v4.lastCache += 1 / 60

			if v4.lastCache >= v2.CACHE_INTERVAL or v4.loadedCount == 0 then
				v4.lastCache = 0
				local instance = p.Instance
				local count = 0

				for i = 1, 7 do
					local child = instance.OuterRingLMP:FindFirstChild("DIM_" .. i, true)
					local child2 = instance.ReflectorLMP:FindFirstChild("DIM_" .. i, true)

					if child then
						v4.ringParts[i] = child
						count += 1
					end

					if not child2 then
						continue
					end

					v4.reflectorParts[i] = child2
					count += 1
				end

				if not (v4.ringParts.MTXI and v4.reflectorParts.MTXI) then
					local mtxi = instance.OuterRingLMP:FindFirstChild("MTXI", true)
					local mtxi2 = instance.ReflectorLMP:FindFirstChild("MTXI", true)

					if mtxi then
						v4.ringParts.MTXI = mtxi
						count += 1
					end

					if mtxi2 then
						v4.reflectorParts.MTXI = mtxi2
						count += 1
					end
				end

				local dim = instance.InsideLMP:FindFirstChild("DIM", true)

				if dim then
					v4.insideParts[1] = dim
					count += 1
				end

				v4.loadedCount = count
			end
		end

		if not p2 then
			return
		end

		local v5 = p.Address - 1
		local v6 = {
			dimR = buffer.readu8(buf, v5 + 0),
			dimRef = buffer.readu8(buf, v5 + 1),
			dimIn = buffer.readu8(buf, v5 + 2),
			str = buffer.readu8(buf, v5 + 3),
			effR = buffer.readu8(buf, v5 + 4),
			effRef = buffer.readu8(buf, v5 + 5),
			r = buffer.readu8(buf, v5 + 6),
			g = buffer.readu8(buf, v5 + 7),
			b = buffer.readu8(buf, v5 + 8),
			mtxiR = buffer.readu8(buf, v5 + 9),
			mtxiRef = buffer.readu8(buf, v5 + 10)
		}

		local color = GetColor(v6.r, v6.g, v6.b)

		local timerMR = nil

		if v6.mtxiR >= 21 then
			local v7 = 1 / 60 * (0.2 + (v6.mtxiR - 21) / 234 * 4.8) * v2.MTXI_BASE_SPEED
			v4.timerMR = ((v4.timerMR or 0) + v7) % 10
			timerMR = v4.timerMR
		else
			v4.timerMR = 0
		end

		local timerMRef = nil

		if v6.mtxiRef >= 21 then
			local v7 = 1 / 60 * (0.2 + (v6.mtxiRef - 21) / 234 * 4.8) * v2.MTXI_BASE_SPEED
			v4.timerMRef = ((v4.timerMRef or 0) + v7) % 10
			timerMRef = v4.timerMRef
		else
			v4.timerMRef = 0
		end

		local processEffect = ProcessEffect(v4, v6.effR, "tRing", "trailR")
		local processEffect2 = ProcessEffect(v4, v6.effRef, "tRef", "trailRef")

		ApplyToGroup(v4, v4.ringParts, v6.dimR, v6.str, processEffect, timerMR, color, false)
		ApplyToGroup(v4, v4.reflectorParts, v6.dimRef, v6.str, processEffect2, timerMRef, color, false)

		if v4.insideParts[1] then
			setProp(v4.insideParts[1], "Transparency", 1 - v6.dimIn / 255) -- inferred equivalent call
		end
	end
}