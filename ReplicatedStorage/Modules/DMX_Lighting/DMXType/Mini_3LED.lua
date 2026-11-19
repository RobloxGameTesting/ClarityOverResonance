local v = {}

local function setled(light, surfaceAppearance, p) -- 3 equivalent calls inferred from this helper
	light.Brightness = p / 10
	surfaceAppearance.EmissiveStrength = p * 30
end

local Mini3LED = {}
Mini3LED.FixtureChannel = 1

function Mini3LED.Update(p, buf, p2)
	local boundingBox = p.Instance.Parent.BoundingBox
	local light = boundingBox.Light
	local surfaceAppearance = boundingBox.SurfaceAppearance

	if not (light and surfaceAppearance) then
		return
	end

	local v2 = v[p]

	if not v2 then
		v2 = { ison = false, lastdim = 0 }

		v[p] = v2
	end

	if p2 then
		if not v2.ison then
			setled(light, surfaceAppearance, v2.lastdim) -- inferred equivalent call
			v2.ison = true
		end

		local lastdim = buffer.readu8(buf, p.Address - 1 + 0) / 255

		if v2.lastdim ~= lastdim then
			v2.lastdim = lastdim
			setled(light, surfaceAppearance, lastdim) -- inferred equivalent call
		end
	elseif v2.ison then
		v2.ison = false
		setled(light, surfaceAppearance, 0) -- inferred equivalent call
	end
end

function Mini3LED.CleanUp(p)
	v[p] = nil
end

return Mini3LED