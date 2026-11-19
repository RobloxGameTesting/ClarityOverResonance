local v = {}

local v2 = 0

local function setProperty(p, p2, p3) -- 22 equivalent calls inferred from this helper
	if p and p[p2] ~= p3 then
		p[p2] = p3
	end
end

local DMX3MappleLeaf = {}
DMX3MappleLeaf.FixtureChannel = 16

function DMX3MappleLeaf.SetIntBright(p)
	if not p then
		return
	end

	v2 = math.clamp(1 / (1 + p), 0, 1)
end

local v3 = {
	Motor = { MaxSpeed = 1080, Deceleration = 40, Acceleration = 300 },
	Macros = {
		Amber = {
			{
				name = "Sequence Running",
				baseDuration = 0.5,
				frames = {
					{ a1 = 1, a2 = 0, a3 = 0 },
					{ a1 = 0, a2 = 1, a3 = 0 },
					{ a1 = 0, a2 = 0, a3 = 1 }
				}
			},
			{
				name = "PingPong",
				baseDuration = 0.4,
				frames = {
					{ a1 = 1, a2 = 0, a3 = 0 },
					{ a1 = 1, a2 = 1, a3 = 0 },
					{ a1 = 0, a2 = 1, a3 = 1 },
					{ a1 = 0, a2 = 0, a3 = 1 }
				}
			},
			{
				name = "All Blink",
				baseDuration = 0.2,
				frames = {
					{ a1 = 1, a2 = 1, a3 = 1 },
					{ a1 = 0, a2 = 0, a3 = 0 }
				}
			}
		},
		RGB = {
			{
				name = "Running Red",
				baseDuration = 0.5,
				frames = {
					{ c1 = Color3.new(1, 0, 0), c2 = Color3.new(0, 0, 0), c3 = Color3.new(0, 0, 0) },
					{ c1 = Color3.new(0, 0, 0), c2 = Color3.new(1, 0, 0), c3 = Color3.new(0, 0, 0) },
					{ c1 = Color3.new(0, 0, 0), c2 = Color3.new(0, 0, 0), c3 = Color3.new(1, 0, 0) }
				}
			},
			{
				name = "Running Green",
				baseDuration = 0.5,
				frames = {
					{ c1 = Color3.new(0, 1, 0), c2 = Color3.new(0, 0, 0), c3 = Color3.new(0, 0, 0) },
					{ c1 = Color3.new(0, 0, 0), c2 = Color3.new(0, 1, 0), c3 = Color3.new(0, 0, 0) },
					{ c1 = Color3.new(0, 0, 0), c2 = Color3.new(0, 0, 0), c3 = Color3.new(0, 1, 0) }
				}
			},
			{
				name = "Running Blue",
				baseDuration = 0.5,
				frames = {
					{ c1 = Color3.new(0, 0, 1), c2 = Color3.new(0, 0, 0), c3 = Color3.new(0, 0, 0) },
					{ c1 = Color3.new(0, 0, 0), c2 = Color3.new(0, 0, 1), c3 = Color3.new(0, 0, 0) },
					{ c1 = Color3.new(0, 0, 0), c2 = Color3.new(0, 0, 0), c3 = Color3.new(0, 0, 1) }
				}
			},
			{
				name = "Rainbow Sync",
				baseDuration = 0.3,
				frames = {
					{ c1 = Color3.new(1, 0, 0), c2 = Color3.new(1, 0, 0), c3 = Color3.new(1, 0, 0) },
					{ c1 = Color3.new(0, 1, 0), c2 = Color3.new(0, 1, 0), c3 = Color3.new(0, 1, 0) },
					{ c1 = Color3.new(0, 0, 1), c2 = Color3.new(0, 0, 1), c3 = Color3.new(0, 0, 1) }
				}
			},
			{
				name = "Police",
				baseDuration = 0.15,
				frames = {
					{ c1 = Color3.new(1, 0, 0), c2 = Color3.new(0, 0, 0), c3 = Color3.new(0, 0, 1) },
					{ c1 = Color3.new(0, 0, 1), c2 = Color3.new(0, 0, 0), c3 = Color3.new(1, 0, 0) }
				}
			},
			{
				name = "Random Fill",
				baseDuration = 0.2,
				frames = {
					{ c1 = Color3.new(1, 0, 1), c2 = Color3.new(0, 1, 1), c3 = Color3.new(1, 1, 0) },
					{ c1 = Color3.new(0, 1, 1), c2 = Color3.new(1, 1, 0), c3 = Color3.new(1, 0, 1) }
				}
			}
		},
		Beam = {
			{
				name = "Pulse Fast",
				baseDuration = 0.1,
				frames = {
					{ color = Color3.new(1, 1, 1), dim = 1 },
					{ color = Color3.new(1, 1, 1), dim = 0 }
				}
			},
			{
				name = "Color Cycle",
				baseDuration = 0.5,
				frames = {
					{ color = Color3.new(1, 0, 0), dim = 1 },
					{ color = Color3.new(0, 1, 0), dim = 1 },
					{ color = Color3.new(0, 0, 1), dim = 1 }
				}
			},
			{
				name = "Strobe Macro",
				baseDuration = 0.05,
				frames = {
					{ color = Color3.new(1, 1, 1), dim = 1 },
					{ color = Color3.new(0, 0, 0), dim = 0 }
				}
			}
		}
	}
}

local function decodeAmberStatic(p): (number, number, number)
	if p < 5 then
		return 0, 0, 0
	end

	if p <= 41 then
		return 1, 0, 0
	end

	if p <= 76 then
		return 0, 1, 0
	end

	if p <= 112 then
		return 0, 0, 1
	end

	if p <= 148 then
		return 1, 1, 0
	end

	if p <= 184 then
		return 1, 0, 1
	end

	if p <= 220 then
		return 0, 1, 1
	end

	return 1, 1, 1
end

local function decodeRGBStatic(p)
	if p < 5 then
		return Color3.new(0, 0, 0)
	end

	if p <= 41 then
		return Color3.new(1, 0, 0)
	end

	if p <= 76 then
		return Color3.new(0, 1, 0)
	end

	if p <= 112 then
		return Color3.new(0, 0, 1)
	end

	if p <= 148 then
		return Color3.new(1, 1, 0)
	end

	if p <= 184 then
		return Color3.new(1, 0, 1)
	end

	if p <= 220 then
		return Color3.new(0, 1, 1)
	end

	return Color3.new(1, 1, 1)
end

local function decodeBeamStatic(p)
	if p < 5 then
		return Color3.new(0, 0, 0)
	end

	if p <= 36 then
		return Color3.new(1, 0, 0)
	end

	if p <= 48 then
		return Color3.new(0, 1, 0)
	end

	if p <= 79 then
		return Color3.new(0, 0, 1)
	end

	if p <= 111 then
		return Color3.new(1, 1, 1)
	end

	if p <= 144 then
		return Color3.new(1, 1, 0)
	end

	if p <= 176 then
		return Color3.new(1, 0, 1)
	end

	if p <= 208 then
		return Color3.new(0, 1, 1)
	end

	return Color3.new(1, 1, 1)
end

local function processStrobe(p, p2)
	if p2 == 0 then
		return p, true
	end

	local v4 = 0.5 / (1 + (p2 - 1) / 254 * 24)
	local v5 = p + 1 / 60

	return v5, math.floor(v5 / v4) % 2 == 0
end

local function getMacroData(list, p, _, _) -- 3 equivalent calls inferred from this helper
	local v4 = math.clamp(math.floor((p - 1) / 255 * #list) + 1, 1, #list)
	local item = list[v4]

	local v5 = (v4 - 1) * (255 / #list)
	local v6 = v4 * (255 / #list)
	return item, 1 - (p - v5) / math.max(1, v6 - v5) * 0.9
end

function DMX3MappleLeaf.Update(p, buf, p2)
	local instance = p.Instance

	if not instance then
		return
	end

	local body_Motor = instance:FindFirstChild("Body_Motor")
	local m1 = instance:FindFirstChild("M1") and instance.M1:FindFirstChild("M1")

	local mat = body_Motor.Amber_1:FindFirstChild("MAT")
	local mat2 = body_Motor.Amber_2:FindFirstChild("MAT")
	local mat3 = body_Motor.Amber_3:FindFirstChild("MAT")

	local mat4 = body_Motor.RGB_1:FindFirstChild("MAT")
	local mat5 = body_Motor.RGB_2:FindFirstChild("MAT")
	local mat6 = body_Motor.RGB_3:FindFirstChild("MAT")

	local light = body_Motor.Beam:FindFirstChild("Light")
	local mat7 = body_Motor.Beam:FindFirstChild("MAT")

	local v4 = v[p]

	if not v4 then
		v4 = {
			motor = {
				baseC1 = m1 and m1.C1,
				angle = 0,
				velocity = 0,
				targetAngle = 0
			},
			amberStrobeTimer = 0,
			rgbStrobeTimer = 0,
			macroTimers = { amber = 0, rgb = 0, beam = 0 },
			macroFrames = { amber = 1, rgb = 1, beam = 1 }
		}

		v[p] = v4
	end

	local v5 = p.Address - 1
	local v6 = buffer.readu8(buf, v5)
	local v7 = buffer.readu8(buf, v5 + 1)
	local v8 = buffer.readu8(buf, v5 + 2)
	local v9 = buffer.readu8(buf, v5 + 3)
	local v10 = buffer.readu8(buf, v5 + 4)
	local v11 = buffer.readu8(buf, v5 + 5)
	local v12 = buffer.readu8(buf, v5 + 6)
	local v13 = buffer.readu8(buf, v5 + 7)
	local v14 = buffer.readu8(buf, v5 + 8)
	local v15 = buffer.readu8(buf, v5 + 9)
	local v16 = buffer.readu8(buf, v5 + 10)
	local v17 = buffer.readu8(buf, v5 + 11)
	local v18 = buffer.readu8(buf, v5 + 12)
	local v19 = buffer.readu8(buf, v5 + 13)
	local v20 = buffer.readu8(buf, v5 + 14)
	buffer.readu8(buf, v5 + 15)

	if m1 and v4.motor.baseC1 then
		local motor = v4.motor
		local v21

		if p2 then
			if v7 <= 49 then
				motor.targetAngle = v6 / 255 * 360
				local v22 = motor.targetAngle - motor.angle % 360

				if v22 > 180 then
					v22 -= 360
				elseif v22 < -180 then
					v22 += 360
				end

				local v23 = 1 - v7 / 49
				local v24 = math.sign(v22) * v3.Motor.MaxSpeed * v23
				v21 = math.abs(v22) < 2 and 0 or v24
			elseif v7 <= 152 then
				local v22 = 1 - (v7 - 50) / 102
				v21 = v3.Motor.MaxSpeed * v22
			else
				local v22 = (v7 - 153) / 102
				v21 = -v3.Motor.MaxSpeed * v22
			end
		else
			v21 = 0
		end

		if motor.velocity < v21 then
			motor.velocity = math.min(v21, motor.velocity + v3.Motor.Acceleration * (1 / 60))
		elseif v21 < motor.velocity then
			motor.velocity = math.max(v21, motor.velocity - v3.Motor.Deceleration * (1 / 60))
		end

		motor.angle += motor.velocity * (1 / 60)
		setProperty(m1, "C1", motor.baseC1 * CFrame.Angles(math.rad(motor.angle), 0, 0)) -- inferred equivalent call
	end

	if p2 then
		local v21 = 1 - v2

		local amberStrobeTimer = v4.amberStrobeTimer
		local v22

		if v9 == 0 then
			v22 = true
		else
			local v23 = 0.5 / (1 + (v9 - 1) / 254 * 24)
			amberStrobeTimer += 1 / 60

			v22 = math.floor(amberStrobeTimer / v23) % 2 == 0
		end

		v4.amberStrobeTimer = amberStrobeTimer
		local v23, v24, v25

		if v18 > 4 then
			local macroData, v26 = getMacroData(v3.Macros.Amber, v18) -- inferred equivalent call
			v4.macroTimers.amber += 1 / 60

			if v4.macroTimers.amber >= macroData.baseDuration * v26 then
				v4.macroTimers.amber = 0
				v4.macroFrames.amber = v4.macroFrames.amber % #macroData.frames + 1
			end

			local v27 = macroData.frames[v4.macroFrames.amber] or macroData.frames[1]
			v23 = v27.a1
			v24 = v27.a2
			v25 = v27.a3
		elseif v10 < 5 then
			v23 = 0
			v24 = 0
			v25 = 0
		elseif v10 <= 41 then
			v23 = 1
			v24 = 0
			v25 = 0
		elseif v10 <= 76 then
			v23 = 0
			v24 = 1
			v25 = 0
		elseif v10 <= 112 then
			v23 = 0
			v24 = 0
			v25 = 1
		elseif v10 <= 148 then
			v23 = 1
			v24 = 1
			v25 = 0
		else
			if v10 <= 184 then
				v23 = 1
				v24 = 0
			else
				v23 = if v10 <= 220 then 0 else 1
				v24 = 1
			end

			v25 = 1
		end

		local v26 = v22 and v8 / 255 * 40 or 0

		if mat then
			setProperty(mat, "EmissiveStrength", v23 * v26) -- inferred equivalent call
		end

		if mat2 then
			setProperty(mat2, "EmissiveStrength", v24 * v26) -- inferred equivalent call
		end

		if mat3 then
			setProperty(mat3, "EmissiveStrength", v25 * v26) -- inferred equivalent call
		end

		local rgbStrobeTimer = v4.rgbStrobeTimer
		local v27

		if v12 == 0 then
			v27 = true
		else
			local v28 = 0.5 / (1 + (v12 - 1) / 254 * 24)
			rgbStrobeTimer += 1 / 60

			v27 = math.floor(rgbStrobeTimer / v28) % 2 == 0
		end

		v4.rgbStrobeTimer = rgbStrobeTimer

		Color3.new(0, 0, 0)
		Color3.new(0, 0, 0)
		Color3.new(0, 0, 0)
		local v28, v29, v30

		if v19 > 4 then
			local macroData, v31 = getMacroData(v3.Macros.RGB, v19) -- inferred equivalent call
			v4.macroTimers.rgb += 1 / 60

			if v4.macroTimers.rgb >= macroData.baseDuration * v31 then
				v4.macroTimers.rgb = 0
				v4.macroFrames.rgb = v4.macroFrames.rgb % #macroData.frames + 1
			end

			local v32 = macroData.frames[v4.macroFrames.rgb] or macroData.frames[1]
			v28 = v32.c1
			v29 = v32.c2
			v30 = v32.c3
		else
			v28 = decodeRGBStatic(v13)
			v29 = decodeRGBStatic(v14)
			v30 = decodeRGBStatic(v15)
		end

		local v31 = v27 and v11 / 255 * 40 or 0

		if mat4 then
			setProperty(mat4, "EmissiveTint", v28) -- inferred equivalent call
			setProperty(mat4, "EmissiveStrength", (v28 == Color3.new(0, 0, 0) or not v31) and 0 or v31) -- inferred equivalent call
		end

		if mat5 then
			setProperty(mat5, "EmissiveTint", v29) -- inferred equivalent call
			setProperty(mat5, "EmissiveStrength", (v29 == Color3.new(0, 0, 0) or not v31) and 0 or v31) -- inferred equivalent call
		end

		if mat6 then
			setProperty(mat6, "EmissiveTint", v30) -- inferred equivalent call
			setProperty(mat6, "EmissiveStrength", (v30 == Color3.new(0, 0, 0) or not v31) and 0 or v31) -- inferred equivalent call
		end

		Color3.new(0, 0, 0)
		local v32 = 1
		local v33

		if v20 > 4 then
			local macroData, v34 = getMacroData(v3.Macros.Beam, v20) -- inferred equivalent call
			v4.macroTimers.beam += 1 / 60

			if v4.macroTimers.beam >= macroData.baseDuration * v34 then
				v4.macroTimers.beam = 0
				v4.macroFrames.beam = v4.macroFrames.beam % #macroData.frames + 1
			end

			local v35 = macroData.frames[v4.macroFrames.beam] or macroData.frames[1]
			v33 = v35.color
			v32 = v35.dim
		else
			v33 = decodeBeamStatic(v17)
		end

		local v34 = v16 / 255 * v32

		if mat7 then
			setProperty(mat7, "EmissiveTint", v33) -- inferred equivalent call
			setProperty(mat7, "EmissiveStrength", v33 == Color3.new(0, 0, 0) and 0 or v34 * 40 or 0) -- inferred equivalent call
		end

		if light then
			setProperty(light, "Color", ColorSequence.new(v33)) -- inferred equivalent call

			local v35 = math.clamp(1 - v34 * v21, 0, 1)

			local numberSequence = NumberSequence.new({
				NumberSequenceKeypoint.new(0, v35),
				NumberSequenceKeypoint.new(1, 1)
			})

			if not v4.lastBeamTrans or v4.lastBeamTrans.Keypoints[1].Value ~= v35 then
				setProperty(light, "Transparency", numberSequence) -- inferred equivalent call
				v4.lastBeamTrans = numberSequence
			end
		end
	else
		setProperty(mat, "EmissiveStrength", 0) -- inferred equivalent call
		setProperty(mat2, "EmissiveStrength", 0) -- inferred equivalent call
		setProperty(mat3, "EmissiveStrength", 0) -- inferred equivalent call
		setProperty(mat4, "EmissiveStrength", 0) -- inferred equivalent call
		setProperty(mat5, "EmissiveStrength", 0) -- inferred equivalent call
		setProperty(mat6, "EmissiveStrength", 0) -- inferred equivalent call
		setProperty(mat7, "EmissiveStrength", 0) -- inferred equivalent call

		if light then
			setProperty(light, "Transparency", NumberSequence.new(1, 1)) -- inferred equivalent call
		end
	end
end

function DMX3MappleLeaf.CleanUp(p)
	v[p] = nil
end

return DMX3MappleLeaf