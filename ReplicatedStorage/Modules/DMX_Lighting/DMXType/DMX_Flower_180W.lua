local v = {}
game:GetService("TweenService")

local v2 = {
	brightnessMultiplier = 2,
	motorMaxDegreesPerSecond = 360,
	motorCoastDeceleration = 120,
	motorTransitionTime = 0.18,
	visualModes = {
		{
			name = "Menyebar kembali lagi instan",
			frames = {
				{
					decal = "V1",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0,
					easingStyle = "Linear"
				},
				{
					decal = "V1",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		},
		{
			name = "Contoh static",
			frames = {
				{
					decal = "V1",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				},
				{
					decal = "V1",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		},
		{
			name = "Pingpong_1_RGBCMYW",
			frames = {
				{
					decal = "V1",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear",
					colorMacro = Color3.new(2, 0, 0)
				},
				{
					decal = "V1",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear",
					colorMacro = Color3.new(0, 2, 0)
				},
				{
					decal = "V1",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear",
					colorMacro = Color3.new(0, 0, 2)
				},
				{
					decal = "V1",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear",
					colorMacro = Color3.new(0, 2, 2)
				},
				{
					decal = "V1",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear",
					colorMacro = Color3.new(2, 0, 2)
				},
				{
					decal = "V1",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear",
					colorMacro = Color3.new(2, 2, 0)
				}
			}
		},
		{
			name = "Pingpong",
			frames = {
				{
					decal = "V2",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				},
				{
					decal = "V2",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		},
		{
			name = "Pingpong",
			frames = {
				{
					decal = "V3",
					uvScale = Vector2.new(3, 3),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				},
				{
					decal = "V3",
					uvScale = Vector2.new(0.7, 0.7),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		},
		{
			name = "InsideG",
			frames = {
				{
					decal = "V4",
					uvScale = Vector2.new(5, 5),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				},
				{
					decal = "V4",
					uvScale = Vector2.new(0.5, 0.5),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		},
		{
			name = "OutsideG",
			frames = {
				{
					decal = "V5",
					uvScale = Vector2.new(0.5, 0.5),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				},
				{
					decal = "V5",
					uvScale = Vector2.new(5, 5),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		},
		{
			name = "Rainbow",
			frames = {
				{
					decal = "V6",
					uvScale = Vector2.new(0.5, 0.5),
					uvOffset = Vector2.new(0, 0),
					rotation = 360,
					duration = 0.1,
					easingStyle = "Linear"
				},
				{
					decal = "V6",
					uvScale = Vector2.new(0.5, 0.5),
					uvOffset = Vector2.new(0, 0),
					rotation = 0,
					duration = 0.1,
					easingStyle = "Linear"
				}
			}
		}
	},
	motorModes = {
		{
			name = "Putar terus",
			frames = {
				{ direction = 1, hold = 1, easingStyle = "Linear" }
			}
		},
		{
			name = "Putar terus terbalik",
			frames = {
				{ direction = -1, hold = 1, easingStyle = "Linear" }
			}
		},
		{
			name = "Bolak-balik dengan jeda",
			frames = {
				{ direction = 1, hold = 5, easingStyle = "Sine" },
				{ direction = -1, hold = 5, easingStyle = "Sine" }
			}
		}
	}
}
local DMXFlower180W = {}
DMXFlower180W.FixtureChannel = 18
DMXFlower180W.Config_LED = v2

local function setProperty(p, p2, p3) -- 8 equivalent calls inferred from this helper
	if p[p2] ~= p3 then
		p[p2] = p3
	end
end

local function compileModeLookup(list)
	local result = table.create(256)

	if #list == 0 then
		return result
	end

	for i = 0, 255 do
		result[i + 1] = math.clamp(math.floor(i * #list / 256) + 1, 1, #list)
	end

	return result
end

local v3 = compileModeLookup(v2.visualModes)
local v4 = compileModeLookup(v2.motorModes)

local function easingStyle(value)
	return Enum.EasingStyle[value or "Linear"] or Enum.EasingStyle.Linear
end

local function eased(value, p) -- 2 equivalent calls inferred from this helper
	local v5 = math.clamp(value, 0, 1)

	if p == "Sine" then
		return -(math.cos(3.141592653589793 * v5) - 1) / 2
	elseif p == "Quad" then
		return v5 < 0.5 and 2 * v5 * v5 or 1 - (-2 * v5 + 2) ^ 2 / 2
	end

	return v5
end

local function centeredOffset(p, p2)
	local v5 = p2 or Vector2.zero
	return Vector2.new((1 - p.X) / 2, (1 - p.Y) / 2) + v5
end

local function findTexture(instance, childName) -- 2 equivalent calls inferred from this helper
	local instance2 = instance:FindFirstChild(childName)

	if instance2 and (instance2:IsA("Decal") or instance2:IsA("Texture")) then
		return instance2
	end

	return nil
end

local function turnOffLED(instance)
	if not instance then
		return
	end

	for i = 1, 6 do
		local texture = findTexture(instance, "V" .. i) -- inferred equivalent call

		if texture then
			setProperty(texture, "Transparency", 1) -- inferred equivalent call
		end
	end
end

local function cancelTween(state) -- 1 equivalent call inferred from this helper
	state.visualTween = nil
end
local function showVisualFrame(instance, state, displayedFrame, color, p, p2, _, value)
	local texture = findTexture(instance, displayedFrame.decal) -- inferred equivalent call

	if not texture then
		return
	end

	local _ = state.displayedFrame == displayedFrame

	if state.activeTexture ~= texture then
		cancelTween(state) -- inferred equivalent call

		if state.activeTexture then
			setProperty(state.activeTexture, "Transparency", 1) -- inferred equivalent call
		end

		state.activeTexture = texture
	end

	local colorMacro = displayedFrame.colorMacro or color
	local v5 = p2 and 1 - p or 1
	local currentRotation = displayedFrame.rotation or 0

	local uvScale = displayedFrame.uvScale or Vector2.new(1, 1)
	local startRawUVScale = state.startRawUVScale or uvScale
	local startRotation = state.startRotation or currentRotation

	local vector2 = Vector2.new(1 / math.max(0.001, startRawUVScale.X), 1 / math.max(0.001, startRawUVScale.Y))

	local vector2_2 = Vector2.new(1 / math.max(0.001, uvScale.X), 1 / math.max(0.001, uvScale.Y))

	if not (value >= 1) and displayedFrame.duration ~= 0 then
		local v6 = eased(value, displayedFrame.easingStyle) -- inferred equivalent call
		vector2_2 = vector2:Lerp(vector2_2, v6)
		currentRotation = startRotation + (currentRotation - startRotation) * v6
	end

	local vector2_3 = Vector2.new(1 / math.max(0.001, vector2_2.X), 1 / math.max(0.001, vector2_2.Y))

	local uvOffset = displayedFrame.uvOffset or Vector2.zero
	local v6 = Vector2.new((1 - vector2_3.X) / 2, (1 - vector2_3.Y) / 2) + uvOffset
	setProperty(texture, "Color3", colorMacro) -- inferred equivalent call
	setProperty(texture, "Transparency", v5) -- inferred equivalent call
	setProperty(texture, "Rotation", currentRotation) -- inferred equivalent call
	setProperty(texture, "UVScale", vector2_3) -- inferred equivalent call
	setProperty(texture, "UVOffset", v6) -- inferred equivalent call
	state.currentRawUVScale = vector2_3
	state.currentRotation = currentRotation
	state.displayedFrame = displayedFrame
end

local function processLED(p, state, data, strobeOn)
	if not p then
		return
	end

	local v5 = data.dimmer / 255

	if v5 <= 0 then
		turnOffLED(p)
		return
	end

	local modeIndex = v3[data.mode + 1]
	local v6 = modeIndex and v2.visualModes[modeIndex]

	if not v6 or #v6.frames == 0 then
		turnOffLED(p)
		return
	end

	if state.modeIndex ~= modeIndex then
		state.modeIndex = modeIndex
		state.frameIndex = 1
		state.frameTimer = 0
		state.displayedFrame = nil
		state.startRawUVScale = nil
		state.startRotation = nil
	end

	local v7 = data.speed / 255
	local v8 = v6.frames[state.frameIndex]
	local v9 = 0

	local v10 = v8.duration == 0

	if v10 or not (v7 > 0 and #v6.frames > 1) then
		if v10 then
			state.frameTimer += 1 / 60

			if state.frameTimer >= 0.001 then
				state.frameTimer = 0
				state.startRawUVScale = v8.uvScale
				state.startRotation = v8.rotation
				state.frameIndex = state.frameIndex % #v6.frames + 1
			end
		end
	else
		v9 = math.max(0.001, v8.duration or 1) / v7
		state.frameTimer += 1 / 60

		while v9 <= state.frameTimer do
			state.frameTimer -= v9

			state.startRawUVScale = state.currentRawUVScale or v8.uvScale
			state.startRotation = state.currentRotation or v8.rotation

			state.frameIndex = state.frameIndex % #v6.frames + 1
			v8 = v6.frames[state.frameIndex]
			v9 = math.max(0.001, v8.duration or 1) / v7
			v10 = v8.duration == 0
		end
	end

	if not state.startRawUVScale then
		state.startRawUVScale = v8.uvScale or Vector2.new(1, 1)
		state.startRotation = v8.rotation or 0
	end

	local v11 = (v10 or not (v9 > 0)) and 1 or math.clamp(state.frameTimer / v9, 0, 1)

	showVisualFrame(
		p,
		state,
		v8,
		Color3.new(
			data.red / 255 * v2.brightnessMultiplier,
			data.green / 255 * v2.brightnessMultiplier,
			data.blue / 255 * v2.brightnessMultiplier
		),
		v5,
		strobeOn,
		v9,
		v11
	)
end

local function applyMotorC0(p, state) -- 2 equivalent calls inferred from this helper
	state.angle = (state.angle + state.velocity * (1 / 60)) % 360
	setProperty(p, "C0", state.baseC0 * CFrame.Angles(math.rad(state.angle), 0, 0)) -- inferred equivalent call
end

local function coastMotor(p, state)
	if not (p and state.baseC0) then
		return
	end

	local v5 = v2.motorCoastDeceleration * (1 / 60)

	if state.velocity > 0 then
		state.velocity = math.max(0, state.velocity - v5)
	elseif state.velocity < 0 then
		state.velocity = math.min(0, state.velocity + v5)
	end

	applyMotorC0(p, state) -- inferred equivalent call
end

local function processMotor(p, state, p2, lastSpeedValue)
	if not (p and state.baseC0) then
		return
	end

	local modeIndex = v4[p2 + 1]
	local v5 = modeIndex and v2.motorModes[modeIndex]

	if not v5 or #v5.frames == 0 then
		return
	end

	if state.modeIndex ~= modeIndex then
		state.modeIndex = modeIndex
		state.frameIndex = 1
		state.phaseTime = 0
		state.lastDirection = nil
	end

	local v6 = v5.frames[state.frameIndex]
	state.phaseTime += 1 / 60

	if state.phaseTime >= math.max(0.001, v6.hold or 1) then
		state.phaseTime = 0
		state.frameIndex = state.frameIndex % #v5.frames + 1
		v6 = v5.frames[state.frameIndex]
	end

	local direction = v6 and v6.direction or 0
	local v7 = direction * v2.motorMaxDegreesPerSecond * (lastSpeedValue / 255)

	if state.lastDirection ~= direction or state.lastSpeedValue ~= lastSpeedValue then
		state.transitionStartVelocity = state.velocity
		state.transitionTime = 0
		state.transitionDuration = v6 and v6.transitionTime or v2.motorTransitionTime
		state.transitionStyle = v6 and v6.easingStyle or "Sine"
		state.lastDirection = direction
		state.lastSpeedValue = lastSpeedValue
	end

	state.transitionTime += 1 / 60
	local v8 = state.transitionDuration <= 0 and 1 or state.transitionTime / state.transitionDuration
	state.velocity = state.transitionStartVelocity + (v7 - state.transitionStartVelocity) * eased(v8, state.transitionStyle) -- inferred equivalent call
	applyMotorC0(p, state) -- inferred equivalent call
end

function DMXFlower180W.Update(p, buf, p2)
	local instance = p.Instance

	if not instance then
		return
	end

	local LED_1 = instance:FindFirstChild("LED_1", true) or instance:FindFirstChild("LED1", true)
	local LED_2 = instance:FindFirstChild("LED_2", true) or instance:FindFirstChild("LED2", true)
	local m1 = instance.MBase.M1
	local m2 = instance.MBase.M2

	local v5 = v[p]

	if not v5 then
		v5 = {
			led1 = {},
			led2 = {},
			motor1 = {
				baseC0 = m1 and m1.C0,
				angle = 0,
				velocity = 0
			},
			motor2 = {
				baseC0 = m2 and m2.C0,
				angle = 0,
				velocity = 0
			},
			strobeTimer = 0,
			strobeOn = true
		}

		v[p] = v5
	end

	if p2 then
		local v6 = p.Address - 1
		local v7 = {
			led1 = {
				dimmer = buffer.readu8(buf, v6),
				red = buffer.readu8(buf, v6 + 1),
				green = buffer.readu8(buf, v6 + 2),
				blue = buffer.readu8(buf, v6 + 3),
				mode = buffer.readu8(buf, v6 + 4),
				speed = buffer.readu8(buf, v6 + 5)
			},
			motor1Mode = buffer.readu8(buf, v6 + 6),
			motor1Speed = buffer.readu8(buf, v6 + 7),
			led2 = {
				dimmer = buffer.readu8(buf, v6 + 8),
				red = buffer.readu8(buf, v6 + 9),
				green = buffer.readu8(buf, v6 + 10),
				blue = buffer.readu8(buf, v6 + 11),
				mode = buffer.readu8(buf, v6 + 12),
				speed = buffer.readu8(buf, v6 + 13)
			},
			motor2Mode = buffer.readu8(buf, v6 + 14),
			motor2Speed = buffer.readu8(buf, v6 + 15),
			strobe = buffer.readu8(buf, v6 + 16)
		}

		if v7.strobe > 0 then
			v5.strobeTimer += 1 / 60
			local v8 = 0.5 / (1 + (v7.strobe - 1) / 254 * 29)

			while v8 <= v5.strobeTimer do
				v5.strobeTimer -= v8
				v5.strobeOn = not v5.strobeOn
			end
		else
			v5.strobeTimer = 0
			v5.strobeOn = true
		end

		processLED(LED_1, v5.led1, v7.led1, v5.strobeOn)
		processLED(LED_2, v5.led2, v7.led2, v5.strobeOn)

		if m1 and not v5.motor1.baseC0 then
			v5.motor1.baseC0 = m1.C0
		end

		if m2 and not v5.motor2.baseC0 then
			v5.motor2.baseC0 = m2.C0
		end

		processMotor(m1, v5.motor1, v7.motor1Mode, v7.motor1Speed)
		processMotor(m2, v5.motor2, v7.motor2Mode, v7.motor2Speed)
	else
		turnOffLED(LED_1)
		turnOffLED(LED_2)
		coastMotor(m1, v5.motor1)
		coastMotor(m2, v5.motor2)
	end
end

function DMXFlower180W.CleanUp(p)
	v[p] = nil
end

return DMXFlower180W