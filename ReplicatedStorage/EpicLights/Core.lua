local Core = {}
Core.Tag = "EpicLightsCar"
Core.StateAttr = "ELS"
Core.RemoteAttr = "ELRemote"
Core.DiscAttr = "ELD"
Core.SnapAttr = "ELT"
Core.ModeAttr = "ELM"
Core.StreamName = "TelemetryStream"
Core.Defaults = {
	Levels = { Full = 1, Dim = 0.82, Running = 0.75, Reflector = 0.75 },
	LOD = {
		{ Distance = 120, Interval = 0, Tween = true },
		{ Distance = 300, Interval = 0.1, Tween = false },
		{ Distance = 600, Interval = 0.5, Tween = false }
	},
	LightShadows = true,
	IndicatorBrightness = 1,
	RunningLightBrightness = 1.5,
	PlateLightBrightness = 1,
	InteriorBrightness = 0.38,
	EmissiveStrength = 15,
	ValidateDriver = true,
	LegacyValues = true,
	SortParts = true,
	TelemetrySendRate = 30,
	TelemetryBroadcastRate = 20,
	TelemetryRange = 1000,
	TelemetrySnapshotInterval = 1
}

function Core.applyDefaults(p)
	if getmetatable(p) == nil then
		setmetatable(p, { __index = Core.Defaults })
	end

	return p
end

function Core.levelToTransparency(value)
	return 1 - math.clamp(value, 0, 1) * 0.98
end

function Core.tweenInfo(p)
	if p.LightType == "Incandescent" then
		return TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end

	if p.LightType == "LED" then
		return TweenInfo.new(0.07, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end

	error("EpicLights // LightType tidak dikenal: " .. tostring(p.LightType))
end

function Core.parse(value)
	if string.byte(value, 1) ~= 35 then
		return nil
	end

	local v, v2, v3 = string.match(string.lower(value), "^#(%w+)_(%w+)_?(%d*)$")

	if v then
		return v, v2, (tonumber(v3))
	end

	return nil
end

local v = {
	Incandescent = Color3.fromRGB(255, 180, 161),
	Xenon = Color3.fromRGB(226, 231, 255),
	["Pure White"] = Color3.fromRGB(255, 255, 255),
	["Brilliant Blue"] = Color3.fromRGB(138, 150, 255),
	["Light Green"] = Color3.fromRGB(156, 255, 209),
	["Golden Yellow"] = Color3.fromRGB(255, 214, 155),
	Yellow = Color3.fromRGB(255, 175, 110),
	["Light Orange"] = Color3.fromRGB(255, 130, 80),
	["Dark Orange"] = Color3.fromRGB(198, 107, 54),
	Red = Color3.fromRGB(241, 57, 60)
}

local v2 = {
	Incandescent = Color3.fromRGB(255, 237, 199),
	Xenon = Color3.fromRGB(205, 227, 255),
	["Pure White"] = Color3.fromRGB(255, 255, 255),
	["Brilliant Blue"] = Color3.fromRGB(116, 188, 255),
	["Light Green"] = Color3.fromRGB(175, 196, 196),
	["Golden Yellow"] = Color3.fromRGB(255, 239, 193),
	Yellow = Color3.fromRGB(181, 178, 87),
	["Light Orange"] = Color3.fromRGB(255, 130, 80),
	["Dark Orange"] = Color3.fromRGB(198, 107, 54),
	Red = Color3.fromRGB(241, 57, 60)
}

local function resolveColor(p, p2) -- 2 equivalent calls inferred from this helper
	if typeof(p2) == "Color3" then
		return p2
	end

	return p[p2] or Color3.new(1, 1, 1)
end

function Core.partColor(p)
	return resolveColor(v, p) -- inferred equivalent call
end

function Core.lightColor(p)
	return resolveColor(v2, p) -- inferred equivalent call
end

local state = {}
Core.State = state

state.Signal = { None = 0, Left = 1, Right = 2, Hazard = 3 }

local v3 = {
	R = 2,
	F = 3,
	B = 4,
	V = 5,
	FL = 6,
	IC = 9,
	IF = 10,
	DO = 11
}

function state.new()
	return {
		H = 0,
		SG = 0,
		R = false,
		F = false,
		B = false,
		V = false,
		FL = false,
		IC = false,
		IF = false,
		DO = false
	}
end

function state.pack(p)
	local v4 = bit32.band(p.H, 3) + bit32.lshift(bit32.band(p.SG, 3), 7)

	for k, v5 in v3 do
		if p[k] then
			v4 += bit32.lshift(1, v5)
		end
	end

	return v4
end

function state.unpack(p)
	local result = {
		H = bit32.band(p, 3),
		SG = bit32.band(bit32.rshift(p, 7), 3)
	}

	for k, v4 in v3 do
		result[k] = bit32.btest(p, (bit32.lshift(1, v4)))
	end

	return result
end

function state.read(instance)
	return state.unpack(instance:GetAttribute(Core.StateAttr) or 0)
end

local lampLogic = {}
Core.LampLogic = lampLogic

local lb = { Level = 0, Bright = 0 }

function lampLogic.compute(data, data2)
	local levels = data2.Levels
	local h = data.H
	local v4 = {}

	local v5 = h == 2 or data.FL
	local v6 = data2.IlluminatedReflectors and (h > 0 or data.R)

	if v5 then
		v4.lb = { Level = levels.Full, Bright = data2.HighBeamBrightness }
	elseif h == 1 then
		v4.lb = { Level = levels.Dim, Bright = data2.LowBeamBrightness }
	elseif data.R and data2.RunningHeadlight then
		v4.lb = { Level = levels.Running, Bright = 0 }
	else
		v4.lb = lb
	end

	v4.hb = v5 and { Level = levels.Full, Bright = data2.HighBeamBrightness } or lb
	v4.rl = data.R
		and not data2.RunningHeadlight
		and { Level = levels.Running, Bright = data2.RunningLightBrightness }
		or lb
	v4.fog = data.F and h > 0 and { Level = levels.Full, Bright = data2.FogLightBrightness } or lb

	v4.tail = h >= 1 and { Level = levels.Dim, Bright = data2.RearLightBrightness } or lb
	v4.brk = data.B and { Level = levels.Full, Bright = data2.BrakeLightBrightness } or lb
	v4.rev = data.V and { Level = levels.Full, Bright = data2.ReverseLightBrightness } or lb

	v4.plate = data2.PlateLights and h >= 1 and {
		Level = levels.Full,
		Bright = data2.PlateLightBrightness
	} or lb
	local v7 = { Level = levels.Full, Bright = data2.InteriorBrightness }
	v4.intc = data2.InteriorLights and (data.IC or data.DO) and v7 or lb
	v4.intf = data2.InteriorLights and (data.IF or data.DO) and v7 or lb
	local v8 = v6 and { Level = levels.Reflector, Bright = 0 } or lb
	v4.refo = v8
	v4.refr = v8

	local blink = data.SG == 1 or data.SG == 3
	local blink2 = data.SG == 2 or data.SG == 3
	local reflector = v6 and levels.Reflector or 0
	v4.indleft = { Level = reflector, Bright = 0, Blink = blink }
	v4.indright = { Level = reflector, Bright = 0, Blink = blink2 }
	v4.rindleft = { Level = 0, Bright = 0, Blink = blink }
	v4.rindright = { Level = 0, Bright = 0, Blink = blink2 }
	return v4
end

function lampLogic.blinkLit(p, p2, p3, p4): boolean
	local v4 = p % (p2 * 2)
	return not (p2 <= v4) and (not p3 or p4 <= 1 or (p3 - 1) * p2 / p4 <= v4)
end

local tel = {}
Core.Tel = tel

tel.Fields = {
	{ "RPM", 0, 20000, 1 },
	{ "SteerC", -1, 1, 0.001 },
	{ "SteerT", -1, 1, 0.001 },
	{ "Throttle", 0, 1, 0.001 },
	{ "Brake", 0, 1, 0.001 },
	{ "InputThrottle", 0, 1, 0.001 },
	{ "InputBrake", 0, 1, 0.001 },
	{ "Velocity", 0, 1000, 0.1 },
	{ "Acceleration", -1000, 1000, 0.1 },
	{ "ABSAmt", 0, 1, 0.001 },
	{ "TCSAmt", 0, 1, 0.001 },
	{ "ESCAmt", 0, 1, 0.001 },
	{ "Clutch", 0, 1, 0.001 },
	{ "CurrentRatio", -20, 20, 0.01 },
	{ "Horsepower", 0, 10000, 1 },
	{ "Torque", 0, 10000, 1 },
	{ "AverageRotSpeed", 0, 500, 0.05 }
}

tel.Flags = { "ABS", "ABSActive", "TCS", "TCSActive", "ESC", "ESCActive", "PBrake" }

tel.Index = {}

for k, field in tel.Fields do
	tel.Index[field[1]] = k
end

tel.Discrete = { Gear = true }

for _, flag in tel.Flags do
	tel.Discrete[flag] = true
end

local allMask = bit32.lshift(1, #tel.Fields) - 1
tel.AllMask = allMask

function tel.quantize(p, p2)
	local field = tel.Fields[p]
	return (math.floor(math.clamp((p2 - field[2]) / (field[3] - field[2]), 0, 1) * 65535 + 0.5))
end

function tel.dequantize(p, p2)
	local field = tel.Fields[p]
	return field[2] + p2 / 65535 * (field[3] - field[2])
end

function tel.packDisc(p)
	local v4 = math.clamp(math.floor((p.Gear or 0) + 0.5) + 2, 0, 15)

	for k, flag in tel.Flags do
		if p[flag] then
			v4 = bit32.bor(v4, (bit32.lshift(1, 3 + k)))
		end
	end

	return v4
end

function tel.pack(value, list, value2)
	local count = 0

	for i = 1, #tel.Fields do
		if not bit32.btest(value, (bit32.lshift(1, i - 1))) then
			continue
		end

		count += 1
	end

	local buf = buffer.create(count * 2 + 8)
	buffer.writeu32(buf, 0, value)
	buffer.writeu32(buf, 4, value2)
	local total = 8

	for i = 1, #tel.Fields do
		if not bit32.btest(value, (bit32.lshift(1, i - 1))) then
			continue
		end

		buffer.writeu16(buf, total, list[i])
		total += 2
	end

	return buf
end

function tel.unpack(buf)
	if typeof(buf) ~= "buffer" or buffer.len(buf) < 8 then
		return nil
	end

	local v4 = bit32.band(buffer.readu32(buf, 0), allMask)
	local v5 = buffer.readu32(buf, 4)
	local count = 0

	for i = 1, #tel.Fields do
		if not bit32.btest(v4, (bit32.lshift(1, i - 1))) then
			continue
		end

		count += 1
	end

	if buffer.len(buf) < count * 2 + 8 then
		return nil
	end

	local total = 8
	local result = {}

	for i = 1, #tel.Fields do
		if not bit32.btest(v4, (bit32.lshift(1, i - 1))) then
			continue
		end

		result[i] = buffer.readu16(buf, total)
		total += 2
	end

	return v4, v5, result
end

function tel.decode(p, p2, p3)
	local result = {}

	for k, field in tel.Fields do
		if not bit32.btest(p, (bit32.lshift(1, k - 1))) then
			continue
		end

		result[field[1]] = tel.dequantize(k, p3[k])
	end

	result.Gear = bit32.band(p2, 15) - 2

	for k, flag in tel.Flags do
		result[flag] = bit32.btest(p2, (bit32.lshift(1, 3 + k)))
	end

	return result
end

function tel.toHex(buf)
	local v4 = table.create(buffer.len(buf))

	for i = 0, buffer.len(buf) - 1 do
		v4[i + 1] = string.format("%02x", (buffer.readu8(buf, i)))
	end

	return table.concat(v4)
end

function tel.fromHex(value)
	local v4 = #value // 2
	local buf = buffer.create(v4)

	for i = 0, v4 - 1 do
		local v5 = tonumber(string.sub(value, i * 2 + 1, i * 2 + 2), 16)

		if not v5 then
			return nil
		end

		buffer.writeu8(buf, i, v5)
	end

	return buf
end

return Core