local v = {}

local v2 = {
	{ 1, 5 },
	{ 6, 7 },
	{ 8, 14 },
	{ 15, 23 },
	{ 24, 25 },
	{ 26, 35 },
	{ 36, 43 },
	{ 44, 47 },
	{ 48, 59 },
	{ 60, 83 },
	{ 84, 168 },
	{ 169, 250 },
	{ 251, 295 },
	{ 296, 340 },
	{ 341, 385 },
	{ 386, 430 },
	{ 431, 462 },
	{ 463, 482 },
	{ 483, 564 },
	{ 565, 605 },
	{ 606, 686 },
	{ 687, 714 },
	{ 715, 769 }
}

local v3 = {
	Color3.new(1, 1, 1),
	Color3.new(1, 0, 0),
	Color3.new(1, 0.4, 0.7),
	Color3.new(0, 1, 0),
	Color3.new(0, 0, 1),
	Color3.new(1, 1, 0),
	Color3.new(0, 1, 1),
	Color3.new(1, 0, 1)
}

local function effectIndexFromValue(p, list)
	if p == 0 then
		return 0
	end

	local count = #list
	local v4 = math.floor(p * count / 256) + 1
	local v5 = v4 < 1 and 1 or v4
	return if count < v5 then count else v5
end

local function getEffectRange(p, p2)
	if p == 0 then
		return nil
	end

	local v4 = p2[p]

	if v4 then
		return v4[1], v4[2]
	end

	return nil
end

local function speedToParams(p) -- 1 equivalent call inferred from this helper
	if p == 0 then
		return 0, 1, 1
	end

	if p <= 64 then
		return 0.5 - (p - 1) / 63 * (7 / 15), 1, 1
	end

	if p <= 127 then
		return 0.5 - (p - 65) / 62 * (7 / 15), 1, 2
	end

	if p <= 191 then
		return 0.5 - (p - 128) / 63 * (7 / 15), -1, 1
	end

	return 0.5 - (p - 192) / 63 * (7 / 15), -1, 2
end

local function setEffectPosition(mainEffect, current, framesPerRow) -- 2 equivalent calls inferred from this helper
	if not (mainEffect and current) then
		return
	end

	local v4 = framesPerRow or 18
	local v5 = current - 1

	local v6 = v5 % v4
	local v7 = math.floor(v5 / v4)

	local v8 = -v6
	local v9 = -v7

	local udim = UDim2.new(v8, 0, v9, 0)

	if mainEffect.Position ~= udim then
		mainEffect.Position = udim
	end
end

local function setdimmer(p, transparency, p2)
	if transparency == 0 then
		p.Enabled = false
		return
	end

	if p2 == true then
		p.MainEffect.Transparency = transparency
	else
		p.MainEffect.Transparency = 1
	end

	p.Enabled = true
end

local STROBE1000W = {}
STROBE1000W.FixtureChannel = 8

function STROBE1000W.Update(p, buf, p2)
	local screen = p.Instance.Screen.Screen
	local mainEffect = screen.MainEffect
	local v4 = v[p]

	if not (screen and mainEffect) then
		return
	end

	if not v4 then
		v4 = {
			ison = false,
			lastdim = 0,
			lasteffect = 0,
			lastspeed = 0,
			lastcoloreffect = 0,
			laststrobe = 0,
			strobeTimer = 0,
			strobeToggle = true
		}

		v[p] = v4
	end

	if not v4.fb then
		v4.fb = {
			effectIndex = 0,
			startFrame = 1,
			endFrame = 1,
			current = 1,
			timer = 0,
			direction = 1,
			step = 1,
			interval = 0,
			visible = false,
			framesPerRow = 18
		}
	end

	if p2 then
		if not v4.ison then
			v4.ison = true
			screen.Enabled = true
		end

		local v5 = p.Address - 1
		local lastdim = buffer.readu8(buf, v5 + 0) / 255
		local v6 = buffer.readu8(buf, v5 + 1)
		local v7 = buffer.readu8(buf, v5 + 5)
		local v8 = buffer.readu8(buf, v5 + 6)
		local v9 = buffer.readu8(buf, v5 + 7)
		local fb = v4.fb
		local effectIndex

		if v7 == 0 then
			effectIndex = 0
		else
			local count = #v2
			local v10 = math.floor(v7 * count / 256) + 1
			effectIndex = v10 < 1 and 1 or v10

			if count < effectIndex then
				effectIndex = count
			end
		end

		if effectIndex ~= fb.effectIndex then
			fb.effectIndex = effectIndex

			if effectIndex == 0 then
				fb.visible = false
				mainEffect.Visible = false
			else
				local v10, endFrame

				if effectIndex ~= 0 then
					local v11 = v2[effectIndex]

					if v11 then
						v10 = v11[1]
						endFrame = v11[2]
					end
				end

				fb.startFrame = v10
				fb.endFrame = endFrame
				fb.current = v10
				fb.timer = 0
				fb.visible = true
				mainEffect.Visible = true
				setEffectPosition(mainEffect, fb.current, fb.framesPerRow) -- inferred equivalent call
			end
		end

		local interval, direction, step = speedToParams(v8) -- inferred equivalent call
		fb.interval = interval
		fb.direction = direction
		fb.step = step

		if fb.visible and fb.interval > 0 then
			fb.timer += 1 / 44

			while fb.timer >= fb.interval do
				fb.timer -= fb.interval
				local current = fb.current + fb.direction * fb.step

				if fb.endFrame < current then
					current = fb.startFrame + (current - fb.endFrame - 1)
				elseif current < fb.startFrame then
					current = fb.endFrame - (fb.startFrame - current - 1)
				end

				if current == fb.current then
					continue
				end

				fb.current = current
				setEffectPosition(mainEffect, fb.current, fb.framesPerRow) -- inferred equivalent call
			end
		end

		if lastdim ~= v4.lastdim then
			v4.lastdim = lastdim

			if lastdim == 0 then
				screen.Enabled = false
			else
				screen.Enabled = true
				local imageTransparency = 1 - lastdim

				if mainEffect.ImageTransparency ~= imageTransparency then
					mainEffect.ImageTransparency = imageTransparency
				end
			end
		end

		v4.strobeTimer += 1 / 44

		if v6 > 0 and screen.Enabled then
			local v10

			if v6 < 230 then
				v10 = 1 - math.clamp((v6 - 20) / 209, 0, 1) * 0.95
			else
				v10 = math.random() * 0.2 + 0.05
			end

			if v10 <= v4.strobeTimer then
				v4.strobeTimer = 0
				v4.strobeToggle = not v4.strobeToggle
			end

			mainEffect.Visible = v4.strobeToggle and fb.visible
		else
			mainEffect.Visible = fb.visible
		end

		local v10 = math.floor(v9 * #v3 / 256) + 1
		local v11 = v10 < 1 and 1 or v10
		local lastcoloreffect = #v3 < v11 and #v3 or v11

		if lastcoloreffect ~= v4.lastcoloreffect then
			v4.lastcoloreffect = lastcoloreffect
			mainEffect.ImageColor3 = v3[lastcoloreffect]
		end
	elseif v4.ison then
		v4.ison = false
		screen.Enabled = false
	end
end

function STROBE1000W.CleanUp(p)
	v[p] = nil
end

return STROBE1000W