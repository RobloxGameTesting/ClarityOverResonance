local v = {}

local v2 = {
	R = Color3.new(1, 0, 0),
	G = Color3.new(0, 1, 0),
	B = Color3.new(0, 0, 1),
	C = Color3.new(0, 1, 1),
	M = Color3.new(1, 0, 1),
	Y = Color3.new(1, 1, 0),
	W = Color3.new(1, 1, 1),
	K = Color3.new(0, 0, 0)
}

local v3 = {
	Motor = { MaxSpeed = 620, Acceleration = 3600, Deceleration = 3600 }
}

local function setProp(p, p2, p3) -- 12 equivalent calls inferred from this helper
	if p and p[p2] ~= p3 then
		p[p2] = p3
	end
end

local function bakeTable(list)
	local result = table.create(256)
	local count = #list

	for i = 0, 255 do
		local v4 = math.clamp(math.floor(i / 256 * count) + 1, 1, count)
		result[i + 1] = {
			data = list[v4],
			size = i / (256 / count) % 1
		}
	end

	return result
end

local v4 = bakeTable({
	function(_, _, _): number
		return 1
	end,
	function(p, p2, _)
		return (math.sin(p - p2 * 0.5) + 1) / 2
	end,
	function(p, p2, _)
		return (math.sin(p + p2 * 0.5) + 1) / 2
	end,
	function(p, p2, p3): number
		return if math.floor(p * 2) % p3 + 1 == p2 then 1 else 0
	end,
	function(p, p2, p3): number
		return if p3 - math.floor(p * 2) % p3 == p2 then 1 else 0
	end,
	function(p, p2, p3)
		local v4 = p * 3 % p3 - p2

		if v4 < 0 then
			v4 += p3
		end

		return (math.clamp(1 - v4 / 3, 0, 1))
	end,
	function(p, p2, _)
		return (math.sin(p - math.abs(p2 - 6.5)) + 1) / 2
	end,
	function(p, p2, _)
		return (math.sin(p + math.abs(p2 - 6.5)) + 1) / 2
	end,
	function(p, p2, _): number
		return if math.noise(p * 3, p2 * 10, 0) > 0.1 then 1 else 0
	end,
	function(p, p2, _): number
		return if math.floor(p * 2) % 2 == p2 % 2 then 1 else 0
	end,
	function(p, p2, _)
		return (math.sin(p - p2 * 0.5) + 1) / 2, (math.sin(p + p2 * 0.5) + 1) / 2
	end,
	function(p, _, _)
		local v4 = math.floor(p * 3) % 2
		local selected = v4 == 0 and 1 or 0

		if v4 == 1 then
			return selected, 1
		end

		return selected, 0
	end,
	function(p, p2, _)
		local v4 = math.abs(p2 - 6.5)
		return (math.sin(p - v4) + 1) / 2, (math.sin(p + v4) + 1) / 2
	end
})

local v5 = bakeTable({
	{
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1,
		1
	},
	{
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1
	},
	{
		1,
		1,
		1,
		1,
		1,
		1,
		0,
		0,
		0,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		1,
		1,
		1,
		1,
		1
	},
	{
		1,
		1,
		1,
		0,
		0,
		0,
		1,
		1,
		1,
		0,
		0,
		0
	},
	{
		0,
		0,
		0,
		1,
		1,
		1,
		0,
		0,
		0,
		1,
		1,
		1
	},
	{
		1,
		0,
		1,
		0,
		1,
		0,
		1,
		0,
		1,
		0,
		1,
		0
	},
	{
		0,
		1,
		0,
		1,
		0,
		1,
		0,
		1,
		0,
		1,
		0,
		1
	},
	{
		1,
		0,
		0,
		1,
		0,
		0,
		1,
		0,
		0,
		1,
		0,
		0
	},
	{
		0,
		1,
		0,
		0,
		1,
		0,
		0,
		1,
		0,
		0,
		1,
		0
	},
	{
		0,
		0,
		1,
		0,
		0,
		1,
		0,
		0,
		1,
		0,
		0,
		1
	}
})

local v6 = bakeTable({
	{
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W,
		v2.W
	},
	{
		v2.R,
		v2.R,
		v2.R,
		v2.R,
		v2.R,
		v2.R,
		v2.B,
		v2.B,
		v2.B,
		v2.B,
		v2.B,
		v2.B
	},
	{
		v2.B,
		v2.B,
		v2.B,
		v2.B,
		v2.B,
		v2.B,
		v2.R,
		v2.R,
		v2.R,
		v2.R,
		v2.R,
		v2.R
	},
	{
		v2.R,
		v2.G,
		v2.B,
		v2.R,
		v2.G,
		v2.B,
		v2.R,
		v2.G,
		v2.B,
		v2.R,
		v2.G,
		v2.B
	},
	{
		v2.C,
		v2.M,
		v2.Y,
		v2.C,
		v2.M,
		v2.Y,
		v2.C,
		v2.M,
		v2.Y,
		v2.C,
		v2.M,
		v2.Y
	}
})

local v7 = bakeTable({
	{
		g1 = {
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		g2 = {
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	{
		g1 = {
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		},
		g2 = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		}
	},
	{
		g1 = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		g2 = {
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	{
		g1 = {
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0
		},
		g2 = {
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1
		}
	},
	{
		g1 = {
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1
		},
		g2 = {
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1,
			0,
			1
		}
	},
	{
		g1 = {
			0,
			0,
			0,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1
		},
		g2 = {
			0,
			0,
			0,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	{
		g1 = {
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			0,
			0,
			0
		},
		g2 = {
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			0,
			0,
			0
		}
	}
})

local v8 = bakeTable({
	function(_): number
		return 0
	end,
	function(p)
		return (math.sin(p))
	end,
	function(p)
		return math.abs(p / 3.141592653589793 % 2 - 1) * 2 - 1
	end,
	function(p): number
		return if math.sin(p) > 0 then 1 else -1
	end
})

local function getStrobe(p, strobeTime): boolean -- 2 equivalent calls inferred from this helper
	if p < 5 then
		return true
	end

	local v9 = 1 + (p - 5) / 250 * 24
	local v10 = strobeTime % (1 / v9)
	return 0.5 / v9 < v10
end

local function initFixture(p)
	local instance = p.Instance
	local v9 = { motors = {}, heads = {}, globalTime = 0, strobeTime = 0 }

	for i = 1, 12 do
		local child = instance:FindFirstChild("M" .. i)
		local weld = child and child:FindFirstChild("M" .. i)

		if weld and weld:IsA("Weld") then
			v9.motors[i] = { weld = weld, baseC0 = weld.C0, currentAngle = 0, velocity = 0 }
		end

		local child2 = instance:FindFirstChild("H" .. i)

		if not child2 then
			continue
		end

		local child3 = child2:FindFirstChild("L_" .. i)
		v9.heads[i] = {
			amb1Mat = child2:FindFirstChild("AMB_1_" .. i) and child2["AMB_1_" .. i]:FindFirstChild("MAT"),
			amb2Mat = child2:FindFirstChild("AMB_2_" .. i) and child2["AMB_2_" .. i]:FindFirstChild("MAT"),
			lMat = child3 and child3:FindFirstChild("MAT"),
			lLight = child3 and child3:FindFirstChild("Light"),
			lBeam = child3 and child3:FindFirstChild("Beam"),
			cache = { beamSeqAlpha = -1 }
		}
	end

	v[p] = v9
	return v9
end

local PixelBeamBar12x60W = {}
PixelBeamBar12x60W.FixtureChannel = 20

function PixelBeamBar12x60W.Update(p, buf, p2)
	local v9 = v[p] or initFixture(p)
	v9.globalTime += 1 / 60
	v9.strobeTime += 1 / 60

	local v10 = p.Address - 1
	local v11 = {
		tiltC = buffer.readu8(buf, v10),
		tiltF = buffer.readu8(buf, v10 + 1),
		tiltSpd = buffer.readu8(buf, v10 + 2),
		tiltEff = buffer.readu8(buf, v10 + 3),
		tiltSprd = buffer.readu8(buf, v10 + 4),
		mDim = buffer.readu8(buf, v10 + 5),
		mStrb = buffer.readu8(buf, v10 + 6),
		mStat = buffer.readu8(buf, v10 + 7),
		mR = buffer.readu8(buf, v10 + 8),
		mG = buffer.readu8(buf, v10 + 9),
		mB = buffer.readu8(buf, v10 + 10),
		mMac = buffer.readu8(buf, v10 + 11),
		mEff = buffer.readu8(buf, v10 + 12),
		mEffSpd = buffer.readu8(buf, v10 + 13),
		aDim = buffer.readu8(buf, v10 + 14),
		aStat = buffer.readu8(buf, v10 + 15),
		aEff = buffer.readu8(buf, v10 + 16),
		aEffSpd = buffer.readu8(buf, v10 + 17),
		aStrb = buffer.readu8(buf, v10 + 18),
		zoom = buffer.readu8(buf, v10 + 19)
	}

	if not p2 then
		v11.mDim = 0
		v11.aDim = 0
	end

	local v12 = (v11.tiltC * 256 + v11.tiltF) / 65535 * 180 - 90
	local v13 = v8[v11.tiltEff + 1]
	local v14 = v13.size * 90
	local v15 = v9.globalTime * (math.max(0.1, v11.tiltSpd / 255) * 5)
	local v16 = v11.tiltSprd / 255 * 3.141592653589793
	local maxSpeed = v3.Motor.MaxSpeed

	for k, motor in pairs(v9.motors) do
		local v17

		if v11.tiltEff > 5 then
			v17 = v12 + v13.data(v15 + v16 * k) * v14
		else
			v17 = v12
		end

		local v18 = math.clamp(v17, -90, 90)

		if p2 then
			local v19 = v18 - motor.currentAngle
			local v20 = v19 >= 0 and 1 or -1
			local v21 = math.abs(v19)

			if v21 <= 0.15 then
				motor.velocity = 0
			else
				local v22 = motor.velocity * motor.velocity / (2 * v3.Motor.Deceleration)
				local v23 = math.min(maxSpeed, v21 / (1 / 60))

				if v21 <= v22 then
					motor.velocity -= v20 * v3.Motor.Deceleration * (1 / 60)

					if v20 == 1 and motor.velocity < 0 or v20 == -1 and motor.velocity > 0 then
						motor.velocity = 0
					end
				else
					local v24 = v20 * v23

					if motor.velocity < v24 then
						motor.velocity = math.min(v24, motor.velocity + v3.Motor.Acceleration * (1 / 60))
					else
						motor.velocity = math.max(v24, motor.velocity - v3.Motor.Acceleration * (1 / 60))
					end
				end
			end
		elseif motor.velocity > 0 then
			motor.velocity = math.max(0, motor.velocity - v3.Motor.Deceleration * (1 / 60))
		elseif motor.velocity < 0 then
			motor.velocity = math.min(0, motor.velocity + v3.Motor.Deceleration * (1 / 60))
		end

		motor.currentAngle = math.clamp(motor.currentAngle + motor.velocity * (1 / 60), -90, 90)
		setProp(motor.weld, "C0", motor.baseC0 * CFrame.Angles(0, 0, (math.rad(motor.currentAngle)))) -- inferred equivalent call
	end

	local v17 = v11.zoom / 255
	local v18 = 3.1 + v17 * 27.9
	local v19 = 1.5 + v17 * 13.5
	local strobe = getStrobe(v11.mStrb, v9.strobeTime) -- inferred equivalent call
	local strobe2 = getStrobe(v11.aStrb, v9.strobeTime) -- inferred equivalent call

	local color = Color3.new(v11.mR / 255, v11.mG / 255, v11.mB / 255)
	local data = v6[v11.mMac + 1].data
	local data2 = v5[v11.mStat + 1].data
	local data3 = v7[v11.aStat + 1].data
	local v20 = v11.mDim / 255 * (strobe and 1 or 0)

	local data4 = v4[v11.mEff + 1].data
	local data5 = v4[v11.aEff + 1].data

	local v21 = v9.globalTime * (v11.mEffSpd / 255 * 10)
	local v22 = v9.globalTime * (v11.aEffSpd / 255 * 10)

	for i = 1, 12 do
		local head = v9.heads[i]

		if not head then
			continue
		end

		local v23 = v11.aDim / 255 * (strobe2 and 1 or 0)
		local v24, v25

		if v11.aEff > 5 then
			v24, v25 = data5(v22, i, 12)

			if not v25 then
				v25 = v24
			end
		else
			v24 = 1
			v25 = 1
		end

		local v26 = v23 * (data3.g1[i] or 0) * v24 * 40
		local v27 = v23 * (data3.g2[i] or 0) * v25 * 40
		setProp(head.amb1Mat, "EmissiveStrength", v26) -- inferred equivalent call
		setProp(head.amb2Mat, "EmissiveStrength", v27) -- inferred equivalent call

		local v28 = v20 * (data2[i] or 0) * (v11.mEff > 5 and data4(v21, i, 12) or 1)
		local v29

		if v11.mMac > 5 then
			v29 = data[i] or color
		else
			v29 = color
		end

		local v30 = v28 > 0.001
		local v31 = v30 and v29 or v2.K
		local v32 = v28 * 40

		local v33 = 1 - math.max(v31.R, v31.G, v31.B)

		local color2 = Color3.new(
			math.clamp(v31.R + v33, 0, 1),
			math.clamp(v31.G + v33, 0, 1),
			(math.clamp(v31.B + v33, 0, 1))
		)

		setProp(head.lMat, "Color", color2) -- inferred equivalent call
		setProp(head.lMat, "EmissiveStrength", v32) -- inferred equivalent call
		setProp(head.lMat, "EmissiveTint", v31) -- inferred equivalent call

		setProp(head.lLight, "Color", v31) -- inferred equivalent call
		setProp(head.lLight, "Brightness", v28 * 5) -- inferred equivalent call
		setProp(head.lLight, "Angle", v18) -- inferred equivalent call
		setProp(head.lLight, "Enabled", v30) -- inferred equivalent call

		if not head.lBeam then
			continue
		end

		setProp(head.lBeam, "Color", ColorSequence.new(v31)) -- inferred equivalent call
		setProp(head.lBeam, "Width1", v19) -- inferred equivalent call
		local beamSeqAlpha = math.clamp(1 - v28 * 0.1, 0, 1)

		if not (math.abs(head.cache.beamSeqAlpha - beamSeqAlpha) > 0.01) then
			continue
		end

		head.lBeam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, beamSeqAlpha),
			NumberSequenceKeypoint.new(1, 1)
		})

		head.cache.beamSeqAlpha = beamSeqAlpha
	end
end

function PixelBeamBar12x60W.CleanUp(p)
	v[p] = nil
end

return PixelBeamBar12x60W