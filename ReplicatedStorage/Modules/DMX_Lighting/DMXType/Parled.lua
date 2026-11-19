local v = {}

local function SetLED(light, p, p2, p3, p4, p5) -- 2 equivalent calls inferred from this helper
	if p == 0 then
		light.Mesh.VertexColor = Vector3.new(1, 1, 1)
		light.Light.Brightness = 0
		light.Light.Enabled = false
		light.Light.Color = Color3.fromRGB(0, 0, 0)
	else
		local v2 = 1 + p * 5

		local lerped = Vector3.new(p2, p3, p4):Lerp(Vector3.new(1, 1, 1), p5)

		light.Mesh.VertexColor = lerped * v2
		light.Light.Brightness = p * 2
		light.Light.Enabled = true

		local color = Color3.new(lerped.X, lerped.Y, lerped.Z)
		light.Light.Color = color
	end
end

local Parled = {}
Parled.FixtureChannel = 6

function Parled.Update(p, buf, p2)
	local light = p.Instance.Light
	local v2 = v[p]

	if not v2 then
		v2 = {
			ison = false,
			lastdim = 0,
			lastred = 0,
			lastgreen = 0,
			lastblue = 0,
			lastwhite = 0,
			laststrobe = 0,
			strobeTimer = 0,
			strobeToggle = true
		}

		v[p] = v2
	end

	if p2 then
		if not v2.ison then
			v2.ison = true
			SetLED(light, v2.lastdim, v2.lastred, v2.lastgreen, v2.lastblue, v2.lastwhite)
		end

		local v3 = p.Address - 1
		local lastdim = buffer.readu8(buf, v3 + 0) / 255
		local lastred = buffer.readu8(buf, v3 + 1) / 255
		local lastgreen = buffer.readu8(buf, v3 + 2) / 255
		local lastblue = buffer.readu8(buf, v3 + 3) / 255
		local lastwhite = buffer.readu8(buf, v3 + 4) / 255
		local v4 = buffer.readu8(buf, v3 + 5)

		v2.lastdim = lastdim
		v2.lastred = lastred
		v2.lastgreen = lastgreen
		v2.lastblue = lastblue
		v2.lastwhite = lastwhite

		if v4 <= 0 then
			SetLED(light, lastdim, lastred, lastgreen, lastblue, lastwhite)
			return
		end

		v2.strobeTimer += 1 / 60
		local v5

		if v4 < 230 then
			v5 = 1 - math.clamp((v4 - 20) / 209, 0, 1) * 0.95
		else
			v5 = math.random() * 0.2 + 0.05
		end

		if v5 <= v2.strobeTimer then
			v2.strobeTimer = 0
			v2.strobeToggle = not v2.strobeToggle
		end

		if v2.strobeToggle then
			SetLED(light, lastdim, lastred, lastgreen, lastblue, lastwhite)
			return
		end

		SetLED(light, 0) -- inferred equivalent call
	elseif v2.ison then
		v2.ison = false
		SetLED(light, 0) -- inferred equivalent call
	end
end

function Parled.CleanUp(p)
	v[p] = nil
end

return Parled