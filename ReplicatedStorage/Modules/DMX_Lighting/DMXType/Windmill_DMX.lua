local v = {}

local _ = { minspeed = 1, maxspeed = 360 }

local _ = {
	WHITE = "rbxassetid://15307205005",
	RGB = "rbxassetid://98686088314745",
	MOVE = "rbxassetid://118970484473002",
	LOOP = "rbxassetid://118970484473002",
	EXPAND = "rbxassetid://91549295074375",
	ZOOM = "rbxassetid://118970484473002"
}

local v2 = {
	MOVE = { min = 0.4, max = 1.1, sU = 1.5, speed = 10 },
	LOOP = { min = 0.45, max = 1.55, sU = 2, speed = 10 },
	EXPAND = { min = -0.5, max = 0.5, sU = 2, speed = 10 }
}

local function deg2rad(rotAngle) -- 1 equivalent call inferred from this helper
	return rotAngle * 3.141592653589793 / 180
end

local function updateDecals(items, p, data, texture, studsPerTileU, p2, p3, p4, p5)
	for k, item in pairs(items) do
		local mtxi = item.MTXI

		if not mtxi then
			continue
		end

		local offsetStudsU, v3

		if p3 then
			if k == p3 then
				offsetStudsU = p2
				v3 = p
			else
				offsetStudsU = p2
				v3 = 0
			end
		elseif p4 then
			if k < p4 then
				offsetStudsU = p5.max
				v3 = p
			elseif k == p4 then
				offsetStudsU = p2
				v3 = p
			else
				offsetStudsU = p2
				v3 = 0
			end
		else
			offsetStudsU = p2
			v3 = p
		end

		local transparency = 1 - v3 / 255

		if mtxi.Transparency ~= transparency then
			mtxi.Transparency = transparency
		end

		local color = Color3.new(data.R * 4, data.G * 4, data.B * 4)

		if mtxi.Color3 ~= color then
			mtxi.Color3 = color
		end

		if texture and mtxi.Texture ~= texture then
			mtxi.Texture = texture
		end

		if studsPerTileU and mtxi.StudsPerTileU ~= studsPerTileU then
			mtxi.StudsPerTileU = studsPerTileU
		end

		if offsetStudsU and mtxi.OffsetStudsU ~= offsetStudsU then
			mtxi.OffsetStudsU = offsetStudsU
		end
	end
end

local WindmillDMX = {}
WindmillDMX.FixtureChannel = 8

function WindmillDMX.Update(p, buf, p2)
	local instance = p.Instance
	local v3 = v[p]
	local motor = instance.ART.Motor

	if not v3 then
		v3 = {
			ison = false,
			timerEI = 0,
			timerEO = 0,
			seqIdxEI = 1,
			seqIdxEO = 1,
			rotAngle = 0,
			last = {
				dim = -1,
				str = -1,
				rot = -1,
				ei = -1,
				eo = -1,
				r = -1,
				g = -1,
				b = -1
			},
			toggle = 0,
			tState = true,
			innerParts = {},
			outerParts = {},
			loadedCount = 0
		}

		v[p] = v3
	end

	if v3.loadedCount < 14 then
		local count = 0

		for i = 1, 8 do
			if not v3.outerParts[i] then
				local child = instance.LED:FindFirstChild("LMP_" .. i, true)

				if child then
					v3.outerParts[i] = child
					count += 1
				end
			end

			if not (i <= 6) or v3.innerParts[i] then
				continue
			end

			local child = instance.RotatePT.LED:FindFirstChild("LMP_" .. i, true)

			if not child then
				continue
			end

			v3.innerParts[i] = child
			count += 1
		end

		v3.loadedCount += count
	end

	if p2 then
		v3.ison = true

		local v4 = p.Address - 1
		local last = {
			dim = buffer.readu8(buf, v4 + 0),
			str = buffer.readu8(buf, v4 + 1),
			rot = buffer.readu8(buf, v4 + 2),
			ei = buffer.readu8(buf, v4 + 3),
			eo = buffer.readu8(buf, v4 + 4),
			r = buffer.readu8(buf, v4 + 5),
			g = buffer.readu8(buf, v4 + 6),
			b = buffer.readu8(buf, v4 + 7)
		}
		local dim

		if last.str <= 3 or last.str >= 105 and last.str <= 109 or last.str >= 252 then
			dim = last.dim
		else
			local v5 = 1 / (2 + (last.str >= 4 and last.str <= 104 and (last.str - 4) / 100 or last.str >= 110 and last.str <= 207 and (last.str - 110) / 97 or math.random()) * 20)
			v3.toggle += 1 / 60

			if v5 <= v3.toggle then
				v3.toggle = 0
				v3.tState = not v3.tState
			end

			dim = v3.tState and last.dim or 0
		end

		local color

		if last.r < 10 and last.g < 10 and last.b < 10 then
			color = Color3.fromRGB(255, 255, 255)
		else
			color = Color3.fromRGB(
				last.r < 10 and 0 or last.r,
				last.g < 10 and 0 or last.g,
				last.b < 10 and 0 or last.b
			)
		end

		if last.rot >= 3 then
			local v5 = 1 + (last.rot - 3) / 252 * 359

			v3.rotAngle = (v3.rotAngle + v5 * (1 / 60)) % 360

			motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(deg2rad(v3.rotAngle), 0, 0) -- inferred equivalent call
		end

		local function processRing(list, p3, p4, p5)
			local v5 = nil
			local v6 = nil
			local v7 = nil
			local v8, v9, v10

			if p3 <= 20 then
				v8 = p4
				v9 = "rbxassetid://15307205005"
				v10 = 0
			elseif p3 <= 81 then
				v8 = p4 * 6
				local v11 = (p3 - 21) / 60
				v3[p5] = (v3[p5] + v11 * (1 / 60) * 10) % (p4 * 6)
				v10 = v3[p5]
				v9 = "rbxassetid://98686088314745"
			elseif p3 <= 140 then
				v7 = v2.MOVE
				v8 = v7.sU
				local v11 = (p3 - 82) / 58

				v3[p5] += v11 * (1 / 60) * v7.speed

				local v12 = math.abs(v3[p5] % 2 - 1)

				v10 = v7.min + v12 * (v7.max - v7.min)
				v9 = "rbxassetid://118970484473002"
			elseif p3 <= 180 then
				v7 = v2.LOOP
				v9 = "rbxassetid://118970484473002"
				v8 = v7.sU
				local v11 = (p3 - 141) / 39
				v3[p5] += v11 * (1 / 60) * v7.speed

				local v12 = p5 == "timerEI" and "seqIdxEI" or "seqIdxEO"

				if v3[p5] > 1 then
					v3[p5] = 0
					v3[v12] = v3[v12] % #list + 1
				end

				v10 = v7.min + v3[p5] * (v7.max - v7.min)
				v5 = v3[v12]
			elseif p3 <= 221 then
				v7 = v2.EXPAND
				v9 = "rbxassetid://91549295074375"
				v8 = v7.sU
				local v11 = (p3 - 181) / 40
				v3[p5] += v11 * (1 / 60) * v7.speed

				local v12 = p5 == "timerEI" and "seqIdxEI" or "seqIdxEO"

				if v3[p5] > 1 then
					v3[p5] = 0
					v3[v12] += 1

					if v3[v12] > #list then
						v3[v12] = 1
					end
				end

				v10 = v7.min + v3[p5] * (v7.max - v7.min)
				v6 = v3[v12]
			else
				v9 = "rbxassetid://118970484473002"
				local v11 = (p3 - 222) / 33
				v3[p5] = (v3[p5] or 0.5) + v11 * (1 / 60) * 15

				if v3[p5] > 6 then
					v3[p5] = 0.1
				end

				v8 = v3[p5]
				v10 = v3[p5] / 2
			end

			updateDecals(list, dim, color, v9, v8, v10, v5, v6, v7)
		end

		processRing(v3.outerParts, last.eo, 0.795, "timerEO")
		processRing(v3.innerParts, last.ei, 0.638, "timerEI")

		v3.last = last
	elseif v3.ison then
		v3.ison = false
		updateDecals(v3.innerParts, 0, Color3.new(1, 1, 1))
		updateDecals(v3.outerParts, 0, Color3.new(1, 1, 1))
	end
end

function WindmillDMX.CleanUp(p)
	v[p] = nil
end

return WindmillDMX