local v = {}
local DMX900WFogger = {}
DMX900WFogger.FixtureChannel = 1

function DMX900WFogger.Update(p, buf, p2)
	local v2 = v[p]

	if not v2 then
		local boundingBox = p.Instance.Parent:FindFirstChild("BoundingBox")
		local nozzle = boundingBox and boundingBox:FindFirstChild("Nozzle")

		v2 = {
			heat = 30,
			isReheating = false,
			haze = nozzle and nozzle:FindFirstChild("Haze"),
			spray = nozzle and nozzle:FindFirstChild("Spray")
		}

		v[p] = v2
	end

	if not (v2.haze and v2.spray) then
		return
	end

	if p2 then
		local v3 = buffer.readu8(buf, p.Address - 1)

		local rate = 0
		local v4

		if v3 >= 12 then
			v4 = not v2.isReheating
		else
			v4 = false
		end

		if v4 then
			local v5 = (v3 - 12) / 243

			rate = v5 * 45 + 5

			v2.heat = math.max(0, v2.heat - v5 * (1 / 60))

			if v2.heat <= 0 then
				v2.isReheating = true
				v4 = false
			end
		elseif v2.heat < 30 then
			v2.heat = math.min(30, v2.heat + 1 / 120)

			if v2.heat >= 30 then
				v2.isReheating = false
			end
		end

		if v4 then
			v2.haze.Enabled = true
			v2.spray.Enabled = true
			v2.haze.Rate = rate * 0.24
			v2.spray.Rate = rate
		elseif v2.haze.Enabled then
			v2.haze.Enabled = false
			v2.spray.Enabled = false
			v2.haze.Rate = 0
			v2.spray.Rate = 0
		end
	else
		if v2.haze.Enabled then
			v2.haze.Enabled = false
			v2.spray.Enabled = false
			v2.haze.Rate = 0
			v2.spray.Rate = 0
		end

		if v2.heat < 30 then
			v2.heat = math.min(30, v2.heat + 1 / 120)

			if v2.heat >= 30 then
				v2.isReheating = false
			end
		end
	end
end

function DMX900WFogger.CleanUp(p)
	v[p] = nil
end

return DMX900WFogger