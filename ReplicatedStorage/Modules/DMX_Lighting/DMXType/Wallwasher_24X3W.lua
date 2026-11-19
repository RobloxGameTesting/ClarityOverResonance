local v = {}

local config = {
	frameWidth = 24,
	frameHeight = 1,
	frameOffset = -1,
	normalFramesPerSecond = 60,
	Effects = {
		{
			name = "All White",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "1" }
			}
		},
		{
			name = "Kanan_kiri",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "2-3" }
			}
		},
		{
			name = "ODD2",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "4-5" }
			}
		},
		{
			name = "ODD3",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "6-7" }
			}
		},
		{
			name = "ODD4",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "8-9" }
			}
		},
		{
			name = "ODD4",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "10-11" }
			}
		},
		{
			name = "ODD5",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "12-17" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "19-32" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 1, frames = "34-55" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.6,
			segments = {
				{ column = 1, frames = "57-102" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "104-105" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.3,
			segments = {
				{ column = 1, frames = "106-117" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.2,
			segments = {
				{ column = 1, frames = "119-124" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.3,
			segments = {
				{ column = 1, frames = "126-135" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "137-158" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 1, frames = "160-195" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 1, frames = "197-244" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 1, frames = "245-292" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.35,
			segments = {
				{ column = 1, frames = "293-316" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "317-328" }
			}
		},
		{
			name = "stackingwhite",
			speedMultiplier = 0.9,
			segments = {
				{ column = 1, frames = "329-628" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "629-652" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.35,
			segments = {
				{ column = 1, frames = "653-664" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.35,
			segments = {
				{ column = 1, frames = "665-670" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.35,
			segments = {
				{ column = 1, frames = "671-686" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.35,
			segments = {
				{ column = 1, frames = "687-694" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.35,
			segments = {
				{ column = 1, frames = "695-704" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "705-726" }
			}
		},
		{
			name = "RGBSize",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "727-799" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "800-823" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "824-847" }
			}
		},
		{
			name = "RGBSTACKING",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "848-967" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.4,
			segments = {
				{ column = 1, frames = "968-1003" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.8,
			segments = {
				{ column = 2, frames = "1-96" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.8,
			segments = {
				{ column = 2, frames = "97-172" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.8,
			segments = {
				{ column = 2, frames = "173-472" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.6,
			segments = {
				{ column = 2, frames = "473-496" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 2, frames = "497-508" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 2, frames = "509-514" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 2, frames = "515-538" }
			}
		},
		{
			name = "ODD",
			speedMultiplier = 0.5,
			segments = {
				{ column = 2, frames = "539-659" }
			}
		}
	}
}
local Wallwasher24X3W = {}
Wallwasher24X3W.FixtureChannel = 8
Wallwasher24X3W.Config = config

local function setProperty(p, p2, p3) -- 12 equivalent calls inferred from this helper
	if p[p2] ~= p3 then
		p[p2] = p3
	end
end

local function parseFrameList(frames)
	local result = {}
	local set = {}

	if typeof(frames) == "number" then
		return { (math.max(0, (math.floor(frames)))) }
	end

	for k in string.gmatch(tostring(frames), "[^,%s]+") do
		local v2, v3 = string.match(k, "^(%-?%d+)%-(%-?%d+)$")

		if v2 then
			local v4 = tonumber(v2)
			local v5 = tonumber(v3)

			for i = v4, v5, v4 <= v5 and 1 or -1 do
				local v6 = math.max(0, i)

				if set[v6] then
					continue
				end

				set[v6] = true
				table.insert(result, v6)
			end
		else
			local v4 = tonumber(k)

			if v4 then
				local v5 = math.max(0, (math.floor(v4)))

				if not set[v5] then
					set[v5] = true
					table.insert(result, v5)
				end
			end
		end
	end

	return result
end

local function effectIndexFromDMX(p) -- 1 equivalent call inferred from this helper
	local count = #config.Effects

	if count == 0 then
		return nil
	end

	return (math.clamp(math.floor(p * count / 256) + 1, 1, count))
end

local function getFrames(state)
	if state._compiledFrames then
		return state._compiledFrames
	end

	local result = {}

	for _, v2 in ipairs(state.segments or {}) do
		local column = math.max(1, (math.floor(v2.column or 1)))

		for _, frame in ipairs(parseFrameList(v2.frames)) do
			table.insert(result, { column = column, frame = frame, colorMacro = v2.colorMacro })
		end
	end

	state._compiledFrames = result
	return result
end

local function setFrame(mainEffect, p)
	local v2 = p.column - 1
	local v3 = math.max(0, p.frame + config.frameOffset)
	setProperty(mainEffect, "ImageRectSize", Vector2.new(config.frameWidth, config.frameHeight)) -- inferred equivalent call
	setProperty(mainEffect, "ImageRectOffset", Vector2.new(v2 * config.frameWidth, v3 * config.frameHeight)) -- inferred equivalent call
end

local function setOff(p, p2)
	setProperty(p2, "Visible", false) -- inferred equivalent call
	setProperty(p, "Enabled", false) -- inferred equivalent call
end

function Wallwasher24X3W.Update(p, buf, p2)
	local instance = p.Instance

	if not instance then
		return
	end

	local screen = instance:FindFirstChild("Screen")
	local surfaceGUI = screen and (screen:FindFirstChild("SurfaceGUI") or screen:FindFirstChildWhichIsA("SurfaceGui"))
	local mainEffect = surfaceGUI and surfaceGUI:FindFirstChild("MainEffect")

	if not (surfaceGUI and mainEffect and mainEffect:IsA("ImageLabel")) then
		return
	end

	local v2 = v[p]

	if not v2 then
		v2 = {
			isOn = false,
			effectIndex = nil,
			framePosition = 1,
			frameTimer = 0,
			strobeTimer = 0,
			strobeOn = true
		}
		v[p] = v2
	end

	if p2 then
		v2.isOn = true

		local v3 = p.Address - 1
		local v4 = buffer.readu8(buf, v3) / 255
		local v5 = buffer.readu8(buf, v3 + 1)
		local v6 = buffer.readu8(buf, v3 + 2)
		local v7 = buffer.readu8(buf, v3 + 3)
		local v8 = buffer.readu8(buf, v3 + 4)
		local v9 = buffer.readu8(buf, v3 + 5)

		local v10 = buffer.readu8(buf, v3 + 7)
		local effectIndex = effectIndexFromDMX(v9) -- inferred equivalent call
		local v11 = effectIndex and config.Effects[effectIndex]
		local v12 = v11 and getFrames(v11)

		if v12 and #v12 ~= 0 and not (v4 <= 0) and (v6 ~= 0 or v7 ~= 0 or v8 ~= 0) then
			if effectIndex ~= v2.effectIndex then
				v2.effectIndex = effectIndex
				v2.framePosition = 1
				v2.frameTimer = 0
				setFrame(mainEffect, v12[1])
			end

			if v10 > 0 and #v12 > 1 then
				local v13 = v10 / 128 * config.normalFramesPerSecond * (v11.speedMultiplier or 1)
				v2.frameTimer += 1 / 60 * v13
				local frameTimer = math.floor(v2.frameTimer)

				if frameTimer > 0 then
					v2.frameTimer -= frameTimer
					v2.framePosition = (v2.framePosition - 1 + frameTimer) % #v12 + 1
					setFrame(mainEffect, v12[v2.framePosition])
				end
			end

			setProperty(mainEffect, "ImageColor3", v12[v2.framePosition].colorMacro or Color3.fromRGB(v6, v7, v8)) -- inferred equivalent call
			setProperty(mainEffect, "ImageTransparency", 1 - v4) -- inferred equivalent call
			setProperty(surfaceGUI, "Enabled", true) -- inferred equivalent call
			local v13 = true

			if v5 > 0 then
				local v14 = (v5 - 1) / 254 * 14 + 1
				v2.strobeTimer += 1 / 60
				local v15 = 0.5 / v14

				while v15 <= v2.strobeTimer do
					v2.strobeTimer -= v15
					v2.strobeOn = not v2.strobeOn
				end

				v13 = v2.strobeOn
			else
				v2.strobeTimer = 0
				v2.strobeOn = true
			end

			setProperty(mainEffect, "Visible", v13) -- inferred equivalent call
		else
			setProperty(mainEffect, "Visible", false) -- inferred equivalent call
			setProperty(surfaceGUI, "Enabled", false) -- inferred equivalent call
		end
	else
		if v2.isOn then
			setProperty(mainEffect, "Visible", false) -- inferred equivalent call
			setProperty(surfaceGUI, "Enabled", false) -- inferred equivalent call
		end

		v2.isOn = false
	end
end

function Wallwasher24X3W.CleanUp(p)
	v[p] = nil
end

return Wallwasher24X3W