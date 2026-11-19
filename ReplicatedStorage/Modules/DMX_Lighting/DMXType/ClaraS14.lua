local Lighting = game:GetService("Lighting")

local config = {
	Fixture = {
		ChannelCount = 16,
		UpdateHz = 60,
		DeltaTime = 1 / 60,
		ThrottleTime = 0.25
	},
	Channels = {
		PanCoarse = 0,
		TiltCoarse = 1,
		PanFine = 2,
		TiltFine = 3,
		Strobe = 6,
		Dimmer = 7,
		Color = 8,
		Gobo = 9,
		Prism = 11,
		Focus = 12,
		GoboRotation = 14
	},
	Paths = {
		PanBase = { "PanBase", "Motor" },
		TiltBase = { "TiltBase", "Motor" },
		GoboBase = { "Tilt", "Motor" },
		MGobo = "MGobo",
		Glow = "Glow",
		Start = "Start",
		End = "End",
		FolderRays = "FolderRays",
		MainBeam = "Light",
		SpotLight = "SpotLight",
		MachineLight = "MLight"
	},
	Motor = {
		Pan = {
			MaxSpeed = 520,
			Acceleration = 3600,
			Deceleration = 3600,
			MinMoveAngle = 0.01,
			RangeMin = -270,
			RangeMax = 270
		},
		Tilt = {
			MaxSpeed = 520,
			Acceleration = 3600,
			Deceleration = 3600,
			MinMoveAngle = 0.01,
			RangeMin = -135,
			RangeMax = 135
		},
		StopEpsilon = 0.4
	},
	Calibration = {
		Enabled = true,
		Step1Pan = 540,
		Step1Tilt = 135,
		Step1LerpAlpha = 0.01,
		Step1Time = 6,
		Step2Pan = 0,
		Step2Tilt = 0,
		Step2LerpAlpha = 0.05,
		Step2Time = 3.5,
		Step3Time = 2
	},
	Beam = {
		Single = { Width0 = 0.5, Width1Min = 250, Width1Max = 500 },
		Prism = {
			Width0Min = 0.25,
			Width0FocusExtra = 0.05,
			Width1Min = 0.25,
			Width1FocusExtra = 0.2,
			WidthGamma = 1.1,
			Width1Scale = 150
		},
		MaxDistance = 5000,
		IntensityTransparencyFactor = 0.3,
		EndTransparency = 1
	},
	Zoom = {
		FocusGamma = 1.2,
		MinSpreadDeg = 0.5,
		MaxSpreadDeg = 15,
		SingleWidthFactor = 1,
		PrismWidthFactor = 1
	},
	Prism = {
		SingleMax = 10,
		FlatMin = 11,
		FlatMax = 40,
		FlatSmallCountMax = 25,
		FlatSmallCount = 5,
		FlatLargeCount = 8,
		RingMin = 41,
		RingMax = 128,
		RingSmallCountMax = 60,
		RingSmallCount = 8,
		RingLargeCount = 12,
		DoubleRingInnerCount = 8,
		DoubleRingOuterCount = 12,
		InnerAngleFactor = 0.45,
		OuterAngleFactor = 0.9,
		OuterMinimumExtraDeg = 2,
		IntensityPower = 0.1,
		MinIntensityFactor = 0.4,
		MaxIntensityFactor = 1
	},
	Gobo = { ManualMaxDeg = 360, AutoMinSpeed = 1, AutoMaxSpeed = 360 },
	Strobe = {
		OffRanges = {
			{ 0, 3 },
			{ 105, 109 },
			{ 208, 212 },
			{ 252, 255 }
		},
		Range1 = { Min = 4, Max = 104 },
		Range2 = { Min = 110, Max = 207 },
		RandomRange = { Min = 213, Max = 251 },
		MinHz = 2,
		MaxHz = 22
	},
	Color = {
		SliceCount = 8,
		Colors = {
			Color3.new(1, 1, 1),
			Color3.new(1, 0, 0),
			Color3.new(1, 0.4, 0.7),
			Color3.new(0, 1, 0),
			Color3.new(0, 0, 1),
			Color3.new(1, 1, 0),
			Color3.new(0, 1, 1),
			Color3.new(1, 0, 1)
		}
	},
	GoboTextures = {
		"rbxassetid://901813002",
		"rbxassetid://88186256093851",
		"rbxassetid://72161455591838",
		"rbxassetid://100002956848676"
	},
	SpotLight = {
		Enabled = true,
		BrightnessMax = 8,
		BrightnessExponent = 1,
		AngleMin = 2,
		AngleMax = 6,
		Range = 90,
		Shadows = false,
		UsePrismIntensity = true
	},
	MachineLight = { EnabledTransparency = 0, DisabledTransparency = 1 },
	Environment = { IntensityBrightMin = 0, IntensityBrightMax = 1 }
}
local ClaraS14 = {}
ClaraS14.Config = config
ClaraS14.FixtureChannel = config.Fixture.ChannelCount
ClaraS14.ThrottleTime = config.Fixture.ThrottleTime

local v = 1
local v2 = {}

local function deg2rad(p) -- 8 equivalent calls inferred from this helper
	return p * 0.017453292519943295
end

local function setintbright(brightness) -- 2 equivalent calls inferred from this helper
	if brightness == nil then
		return
	end

	v = math.clamp(1 / (1 + brightness), config.Environment.IntensityBrightMin, config.Environment.IntensityBrightMax)
end

Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
	setintbright(Lighting.Brightness) -- inferred equivalent call
end)
setintbright(Lighting.Brightness) -- inferred equivalent call

local function getPath(instance, list) -- 3 equivalent calls inferred from this helper
	for i = 1, #list do
		instance = instance:FindFirstChild(list[i])

		if not instance then
			return nil
		end
	end

	return instance
end

local function applyBeamVisual(p, p2, p3, texture, width, width2)
	if not p then
		return
	end

	p.Color = ColorSequence.new(p2)
	p.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1 - p3 * config.Beam.IntensityTransparencyFactor * v),
		NumberSequenceKeypoint.new(0.5, 1 - p3 * config.Beam.IntensityTransparencyFactor * v),
		NumberSequenceKeypoint.new(1, config.Beam.EndTransparency)
	})

	if texture ~= nil then
		p.Texture = texture
	end

	if width ~= nil then
		p.Width0 = width
	end

	if width2 ~= nil then
		p.Width1 = width2
	end
end

local function getGoboIndex(p) -- 1 equivalent call inferred from this helper
	local count = #config.GoboTextures

	if count == 0 then
		return nil
	end

	return (math.clamp(math.floor(p * count / 256) + 1, 1, count))
end

local function ensureRayPool(parent, p, instance, attachment, name)
	local v3 = {}

	for _, attachment2 in ipairs(parent:GetChildren()) do
		if attachment2:IsA("Attachment") then
			v3[#v3 + 1] = attachment2
		end
	end

	while #v3 < p do
		local clone = instance:Clone()
		clone.Name = "EndRay_" .. #v3 + 1
		clone.Parent = parent

		local v4 = clone:FindFirstChildOfClass("Beam")

		if not v4 then
			v4 = Instance.new("Beam")
			v4.Name = name or "Beam"
			v4.Parent = clone
		end

		v4.Attachment0 = attachment
		v4.Attachment1 = clone
		v3[#v3 + 1] = clone
	end

	for i = p + 1, #v3 do
		v3[i]:Destroy()
	end

	local rayPool = table.create(p)

	for i = 1, p do
		local child = parent:FindFirstChild("EndRay_" .. i)

		if child then
			rayPool[i] = {
				endAtt = child,
				beam = child:FindFirstChildOfClass("Beam")
			}
		end
	end

	return rayPool
end

local function computeRayDirections(p, p2, lookVector, rightVector)
	local prism = config.Prism
	local zoom = config.Zoom
	local v3 = (p2 / 255) ^ zoom.FocusGamma
	local v4 = zoom.MinSpreadDeg + v3 * (zoom.MaxSpreadDeg - zoom.MinSpreadDeg)
	local result = {}

	if p <= prism.SingleMax then
		return result, "single", 1
	end

	if prism.FlatMin <= p and p <= prism.FlatMax then
		local flatSmallCount = p <= prism.FlatSmallCountMax and prism.FlatSmallCount or prism.FlatLargeCount

		for i = 1, flatSmallCount do
			local v5 = (i - 1) / (flatSmallCount - 1)
			local v6 = (-v4 + v5 * 2 * v4) * 0.017453292519943295
			result[i] = CFrame.fromAxisAngle(rightVector, v6) * lookVector
		end

		return result, "flat", flatSmallCount
	elseif prism.RingMin <= p and p <= prism.RingMax then
		local ringSmallCount = p <= prism.RingSmallCountMax and prism.RingSmallCount or prism.RingLargeCount
		local v5 = v4 * 0.017453292519943295

		for i = 1, ringSmallCount do
			local v6 = (i - 1) * (360 / ringSmallCount) * 0.017453292519943295
			local cframe = CFrame.fromAxisAngle(rightVector, v5)
			result[i] = CFrame.fromAxisAngle(lookVector, v6) * cframe * lookVector
		end

		return result, "ring1", ringSmallCount
	else
		local doubleRingInnerCount = prism.DoubleRingInnerCount
		local doubleRingOuterCount = prism.DoubleRingOuterCount
		local v5 = math.max(0.5, v4 * prism.InnerAngleFactor)
		local v6 = math.max(v5 + prism.OuterMinimumExtraDeg, v4 * prism.OuterAngleFactor)
		local count = 0

		for i = 1, doubleRingInnerCount do
			count += 1
			local v7 = (i - 1) * (360 / doubleRingInnerCount) * 0.017453292519943295
			result[count] = CFrame.fromAxisAngle(lookVector, v7) * CFrame.fromAxisAngle(rightVector, v5 * 0.017453292519943295) * lookVector
		end

		for i = 1, doubleRingOuterCount do
			count += 1
			local v7 = (i - 1) * (360 / doubleRingOuterCount) * 0.017453292519943295
			result[count] = CFrame.fromAxisAngle(lookVector, v7) * CFrame.fromAxisAngle(rightVector, v6 * 0.017453292519943295) * lookVector
		end

		return result, "ring2", count
	end
end

local function computeBeamWidths(p) -- 1 equivalent call inferred from this helper
	local prism = config.Beam.Prism
	local zoom = config.Zoom
	local v3 = (p / 255) ^ prism.WidthGamma
	return
		(prism.Width0Min + v3 * prism.Width0FocusExtra) * zoom.PrismWidthFactor,
		(prism.Width1Min + v3 * prism.Width1FocusExtra) * prism.Width1Scale * zoom.PrismWidthFactor
end

local function moveMotor(state, data, p, current, deltaTime)
	local v3 = current - state.current
	local v4 = math.abs(v3)
	local v5 = v3 >= 0 and 1 or -1

	if v4 <= config.Motor.StopEpsilon then
		state.current = current
		state.velocity = 0
		p.C0 = CFrame.Angles(deg2rad(current), 0, 0) -- inferred equivalent call
	else
		local deceleration = data.Deceleration
		local acceleration = data.Acceleration
		local v6 = state.velocity * state.velocity / (math.max(deceleration, 0.001) * 2)
		local v7 = math.min(data.MaxSpeed, v4 / math.max(deltaTime, 0.001))

		if v4 <= v6 or state.velocity * v5 < 0 then
			if state.velocity > 0 then
				state.velocity = math.max(0, state.velocity - deceleration * deltaTime)
			elseif state.velocity < 0 then
				state.velocity = math.min(0, state.velocity + deceleration * deltaTime)
			end
		else
			local v8 = v5 * v7

			if state.velocity < v8 then
				state.velocity = math.min(v8, state.velocity + acceleration * deltaTime)
			else
				state.velocity = math.max(v8, state.velocity - acceleration * deltaTime)
			end
		end

		state.velocity = math.clamp(state.velocity, -data.MaxSpeed, data.MaxSpeed)
		state.current = math.clamp(state.current + state.velocity * deltaTime, data.RangeMin, data.RangeMax)
		p.C0 = CFrame.Angles(deg2rad(state.current), 0, 0) -- inferred equivalent call
	end
end

local function updatePrism(_, attcStart, attcEnd, folderRays, beamLight, spotLight, p, p2, p3, color, texture)
	local worldCFrame = attcStart.WorldCFrame
	local lookVector = worldCFrame.LookVector
	local upVector = worldCFrame.UpVector
	local rightVector = worldCFrame.RightVector
	local worldPosition = attcStart.WorldPosition
	local v3, v4, v5 = computeRayDirections(p, p2, lookVector, rightVector)

	local zoom = config.Zoom
	local spotLight2 = config.SpotLight
	local v6 = spotLight2.AngleMin + (spotLight2.AngleMax - spotLight2.AngleMin) * (p2 / 255)
	local width = (config.Beam.Single.Width1Min + p2 / 255 * (config.Beam.Single.Width1Max - config.Beam.Single.Width1Min)) * zoom.SingleWidthFactor

	if spotLight then
		spotLight.Enabled = spotLight2.Enabled and p3 > 0
		spotLight.Color = color
		spotLight.Brightness = spotLight2.BrightnessMax * p3 ^ spotLight2.BrightnessExponent
		spotLight.Angle = math.clamp(v6, spotLight2.AngleMin, spotLight2.AngleMax)
		spotLight.Range = spotLight2.Range
		spotLight.Shadows = spotLight2.Shadows
	end

	if v4 == "single" then
		beamLight.Enabled = true
		applyBeamVisual(beamLight, color, p3, texture, config.Beam.Single.Width0, width)

		for _, child in ipairs(folderRays:GetChildren()) do
			child:Destroy()
		end
	else
		beamLight.Enabled = false
		local rayPool = ensureRayPool(folderRays, v5, attcEnd, attcStart, beamLight.Name)
		local prism = config.Prism
		local v7 = p3 * math.clamp(1 / v5 ^ prism.IntensityPower, prism.MinIntensityFactor, prism.MaxIntensityFactor)
		local width2, width3 = computeBeamWidths(p2) -- inferred equivalent call

		if spotLight and spotLight2.UsePrismIntensity then
			spotLight.Brightness = spotLight2.BrightnessMax * v7 ^ spotLight2.BrightnessExponent
		end

		for i = 1, v5 do
			local v8 = rayPool[i]
			local v9 = v3[i]

			if not (v8 and v8.endAtt) then
				continue
			end

			v8.endAtt.WorldCFrame = CFrame.lookAt(worldPosition + v9 * config.Beam.MaxDistance, worldPosition, upVector)

			if not v8.beam then
				continue
			end

			v8.beam.Attachment0 = attcStart
			v8.beam.Attachment1 = v8.endAtt
			applyBeamVisual(v8.beam, color, v7, texture, width2, width3)
			v8.beam.Enabled = true
		end
	end
end

function ClaraS14.Update(p, buf, p2)
	local v3 = v2[p]

	if not v3 then
		v3 = {
			ison = false,
			iscalibration = false,
			calibStep = 0,
			calibTimer = 0,
			currentPan = 0,
			currentTilt = 0,
			panVelocity = 0,
			tiltVelocity = 0,
			targetPan = 0,
			targetTilt = 0,
			lastPanC = -1,
			lastPanF = -1,
			lastTiltC = -1,
			lastTiltF = -1,
			lastToggle = 0,
			toggleState = true,
			lastColorIndex = -1,
			lastFocus = -1,
			lastPrismMode = -1,
			lastIntensity = -1,
			lastGoboRotation = -1,
			lastGobo = -1,
			lastColor = nil,
			lastEffectiveIntensity = -1,
			currentGoboAngle = 0,
			panMotor = { current = 0, velocity = 0 },
			tiltMotor = { current = 0, velocity = 0 },
			refs = nil
		}

		v2[p] = v3
	end

	local instance = p.Instance

	if not v3.refs or v3.refs.model ~= instance then
		local paths = config.Paths
		local child = instance:FindFirstChild(paths.MGobo)
		local child2 = child and child:FindFirstChild(paths.Glow)
		local path = getPath(instance, paths.PanBase) -- inferred equivalent call
		local path2 = getPath(instance, paths.TiltBase) -- inferred equivalent call
		local path3 = getPath(instance, paths.GoboBase) -- inferred equivalent call
		local child3 = child2 and child2:FindFirstChild(paths.Start)
		local child4 = child2 and child2:FindFirstChild(paths.End)
		local child5 = child2 and child2:FindFirstChild(paths.FolderRays)
		local child6 = child4 and child4:FindFirstChild(paths.MainBeam)
		local child7 = child2 and child2:FindFirstChild(paths.SpotLight)
		local child8 = child and child:FindFirstChild(paths.MachineLight)

		if path and path2 and path3 and child3 and child4 and child5 and child6 and child8 then
			v3.refs = {
				model = instance,
				PanBase = path,
				TiltBase = path2,
				GoboBase = path3,
				AttcStart = child3,
				AttcEnd = child4,
				FolderRays = child5,
				BeamLight = child6,
				SpotLight = child7,
				MLight = child8
			}
		else
			return
		end
	end

	local refs = v3.refs
	local deltaTime = config.Fixture.DeltaTime

	if p2 then
		if not v3.ison then
			v3.ison = true

			if config.Calibration.Enabled then
				v3.iscalibration = true
				v3.calibStep = 1
				v3.calibTimer = 0
			end
		end

		if v3.iscalibration then
			local calibration = config.Calibration

			if v3.calibStep == 1 then
				refs.PanBase.C0 = refs.PanBase.C0:Lerp(
					CFrame.Angles(deg2rad(calibration.Step1Pan), 0, 0), -- inferred equivalent call
					calibration.Step1LerpAlpha
				)
				refs.TiltBase.C0 = refs.TiltBase.C0:Lerp(
					CFrame.Angles(deg2rad(calibration.Step1Tilt), 0, 0), -- inferred equivalent call
					calibration.Step1LerpAlpha
				)
				v3.calibTimer += deltaTime

				if v3.calibTimer >= calibration.Step1Time then
					v3.calibStep = 2
					v3.calibTimer = 0
				end
			elseif v3.calibStep == 2 then
				refs.PanBase.C0 = refs.PanBase.C0:Lerp(
					CFrame.Angles(deg2rad(calibration.Step2Pan), 0, 0), -- inferred equivalent call
					calibration.Step2LerpAlpha
				)
				refs.TiltBase.C0 = refs.TiltBase.C0:Lerp(
					CFrame.Angles(deg2rad(calibration.Step2Tilt), 0, 0), -- inferred equivalent call
					calibration.Step2LerpAlpha
				)
				v3.calibTimer += deltaTime

				if v3.calibTimer >= calibration.Step2Time then
					v3.calibStep = 3
					v3.calibTimer = 0
				end
			else
				v3.calibTimer += deltaTime

				if v3.calibTimer >= calibration.Step3Time then
					v3.iscalibration = false
					v3.calibStep = 0
					v3.calibTimer = 0
				end
			end
		else
			local v4 = p.Address - 1
			local channels = config.Channels
			local lastPanC = buffer.readu8(buf, v4 + channels.PanCoarse)
			local lastTiltC = buffer.readu8(buf, v4 + channels.TiltCoarse)
			local lastPanF = buffer.readu8(buf, v4 + channels.PanFine)
			local lastTiltF = buffer.readu8(buf, v4 + channels.TiltFine)
			local v5 = buffer.readu8(buf, v4 + channels.Strobe)
			local v6 = buffer.readu8(buf, v4 + channels.Dimmer)
			local v7 = buffer.readu8(buf, v4 + channels.Color)
			local lastGobo = buffer.readu8(buf, v4 + channels.Gobo)
			local lastPrismMode = buffer.readu8(buf, v4 + channels.Prism)
			local lastFocus = buffer.readu8(buf, v4 + channels.Focus)
			local lastGoboRotation = buffer.readu8(buf, v4 + channels.GoboRotation)

			local color = config.Color
			local lastColorIndex = math.min(math.floor(v7 / math.floor(256 / color.SliceCount)) + 1, #color.Colors)
			local color2 = color.Colors[lastColorIndex]

			if
				lastPanC ~= v3.lastPanC
				or lastPanF ~= v3.lastPanF
				or lastTiltC ~= v3.lastTiltC
				or lastTiltF ~= v3.lastTiltF
			then
				local v8 = lastPanC + lastPanF / 256
				local v9 = lastTiltC + lastTiltF / 256
				local pan = config.Motor.Pan
				local tilt = config.Motor.Tilt
				v3.targetPan = math.clamp(
					v8 * ((pan.RangeMax - pan.RangeMin) / 255) + pan.RangeMin,
					pan.RangeMin,
					pan.RangeMax
				)
				v3.targetTilt = math.clamp(
					v9 * ((tilt.RangeMax - tilt.RangeMin) / 255) + tilt.RangeMin,
					tilt.RangeMin,
					tilt.RangeMax
				)
				v3.lastPanC = lastPanC
				v3.lastPanF = lastPanF
				v3.lastTiltC = lastTiltC
				v3.lastTiltF = lastTiltF
			end

			local panMotor = v3.panMotor
			panMotor.current = v3.currentPan
			panMotor.velocity = v3.panVelocity
			moveMotor(panMotor, config.Motor.Pan, refs.PanBase, v3.targetPan, deltaTime)
			v3.currentPan = panMotor.current
			v3.panVelocity = panMotor.velocity

			local tiltMotor = v3.tiltMotor
			tiltMotor.current = v3.currentTilt
			tiltMotor.velocity = v3.tiltVelocity
			moveMotor(tiltMotor, config.Motor.Tilt, refs.TiltBase, v3.targetTilt, deltaTime)
			v3.currentTilt = tiltMotor.current
			v3.tiltVelocity = tiltMotor.velocity

			if lastColorIndex ~= v3.lastColorIndex then
				v3.lastColorIndex = lastColorIndex
				refs.MLight.Color = color2
				refs.BeamLight.Color = ColorSequence.new(color2)

				if refs.SpotLight then
					refs.SpotLight.Color = color2
				end
			end

			if lastGoboRotation <= 127 then
				if lastGoboRotation ~= v3.lastGoboRotation then
					v3.lastGoboRotation = lastGoboRotation
					v3.currentGoboAngle = lastGoboRotation / 127 * config.Gobo.ManualMaxDeg % 360
					refs.GoboBase.C0 = CFrame.Angles(0, 0, deg2rad(v3.currentGoboAngle)) -- inferred equivalent call
				end
			else
				local v8 = (lastGoboRotation - 128) / 127
				local v9 = config.Gobo.AutoMinSpeed + v8 * (config.Gobo.AutoMaxSpeed - config.Gobo.AutoMinSpeed)
				v3.currentGoboAngle = (v3.currentGoboAngle + v9 * deltaTime) % 360
				v3.lastGoboRotation = lastGoboRotation
				refs.GoboBase.C0 = CFrame.Angles(0, 0, deg2rad(v3.currentGoboAngle)) -- inferred equivalent call
			end

			local strobe = config.Strobe
			local v8

			if v5 <= 3 or v5 >= 105 and v5 <= 109 or v5 >= 208 and v5 <= 212 then
				v8 = true
			elseif v5 >= 252 then
				v8 = v5 <= 255
			else
				v8 = false
			end

			local lastEffectiveIntensity

			if v8 then
				lastEffectiveIntensity = v6 / 255
			else
				local v9

				if strobe.Range1.Min <= v5 and v5 <= strobe.Range1.Max then
					v9 = (v5 - strobe.Range1.Min) / (strobe.Range1.Max - strobe.Range1.Min)
				elseif strobe.Range2.Min <= v5 and v5 <= strobe.Range2.Max then
					v9 = (v5 - strobe.Range2.Min) / (strobe.Range2.Max - strobe.Range2.Min)
				else
					v9 = not (strobe.RandomRange.Min <= v5 and v5 <= strobe.RandomRange.Max) and 0 or math.random()
				end

				local v10 = 1 / (strobe.MinHz + v9 * (strobe.MaxHz - strobe.MinHz))
				v3.lastToggle += deltaTime

				if v10 <= v3.lastToggle then
					v3.lastToggle -= v10
					v3.toggleState = not v3.toggleState
				end

				lastEffectiveIntensity = v3.toggleState and v6 / 255 or 0
			end

			refs.MLight.Transparency = 1 - lastEffectiveIntensity
			local goboIndex = getGoboIndex(lastGobo) -- inferred equivalent call
			local texture = goboIndex and config.GoboTextures[goboIndex] or nil

			local v9 = lastEffectiveIntensity ~= v3.lastEffectiveIntensity
			local v10 = lastPrismMode ~= v3.lastPrismMode or lastFocus ~= v3.lastFocus
			local v11 = lastGobo ~= v3.lastGobo
			local v12 = color2 ~= v3.lastColor

			if v10 or v9 or v11 or v12 then
				updatePrism(
					v3,
					refs.AttcStart,
					refs.AttcEnd,
					refs.FolderRays,
					refs.BeamLight,
					refs.SpotLight,
					lastPrismMode,
					lastFocus,
					lastEffectiveIntensity,
					color2,
					texture
				)
				v3.lastPrismMode = lastPrismMode
				v3.lastFocus = lastFocus
				v3.lastEffectiveIntensity = lastEffectiveIntensity
				v3.lastGobo = lastGobo
				v3.lastColor = color2
			end
		end
	elseif v3.ison then
		v3.ison = false
		v3.iscalibration = false
		v3.calibStep = 0
		v3.calibTimer = 0
		v3.lastEffectiveIntensity = -1
		v3.panVelocity = 0
		v3.tiltVelocity = 0

		for _, child in ipairs(refs.FolderRays:GetChildren()) do
			local beam = child:FindFirstChildOfClass("Beam")

			if not beam then
				continue
			end

			applyBeamVisual(beam, refs.BeamLight.Color.Keypoints[1].Value, 0, nil)
			beam.Enabled = false
		end

		applyBeamVisual(refs.BeamLight, refs.BeamLight.Color.Keypoints[1].Value, 0, nil)
		refs.BeamLight.Enabled = false

		if refs.SpotLight then
			refs.SpotLight.Enabled = false
			refs.SpotLight.Brightness = 0
		end

		refs.MLight.Transparency = config.MachineLight.DisabledTransparency
	end
end

function ClaraS14.CleanUp(p)
	v2[p] = nil
end

return ClaraS14