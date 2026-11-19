local v = {}

local function SetLEDDim(p, p2) -- 9 equivalent calls inferred from this helper
	if p2 == 0 then
		p.Mesh.VertexColor = Vector3.new(1, 1, 1)
		p.Light.Brightness = 0
		p.Light.Enabled = false
	else
		local v2 = 1 + p2 * 20
		p.Mesh.VertexColor = Vector3.new(v2, v2, v2)
		p.Light.Brightness = p2 * 2
		p.Light.Enabled = true
	end
end
local function SetRingDimm(p, p2)
	local v2 = 1 + p2 * 3
	p.Mesh.VertexColor = Vector3.new(v2, v2, v2)
end

local function SetOff(lights)
	for _, child in pairs(lights.Cob:GetChildren()) do
		SetLEDDim(child, 0) -- inferred equivalent call
	end

	for _, child in pairs(lights.Ring:GetChildren()) do
		child.Mesh.VertexColor = Vector3.new(1, 1, 1)
	end
end

local Blinder4X100 = {}
Blinder4X100.FixtureChannel = 4

function Blinder4X100.Update(p, buf, p2)
	local instance = p.Instance
	local cob = instance.Lights.Cob
	local _ring = instance.Lights.Ring
	local v2 = v[p]

	if not v2 then
		v2 = {
			ison = false,
			lastdim1 = 0,
			lastdim2 = 0,
			lastdim3 = 0,
			lastdim4 = 0,
			lastcolorring1 = 0,
			lastcolorring2 = 0,
			lastcolorring3 = 0,
			lastcolorring4 = 0
		}

		v[p] = v2
	end

	if p2 == false then
		if v2.ison then
			v2.ison = false
			SetOff(instance.Lights)
		end
	else
		if not v2.ison then
			v2.ison = true
			local LED1 = cob.LED1
			local lastdim1 = v2.lastdim1

			if lastdim1 == 0 then
				SetLEDDim(LED1, 0) -- inferred equivalent call
			else
				local v3 = 1 + lastdim1 * 20
				LED1.Mesh.VertexColor = Vector3.new(v3, v3, v3)
				LED1.Light.Brightness = lastdim1 * 2
				LED1.Light.Enabled = true
			end

			local LED2 = cob.LED2
			local lastdim2 = v2.lastdim2

			if lastdim2 == 0 then
				SetLEDDim(LED2, 0) -- inferred equivalent call
			else
				local v3 = 1 + lastdim2 * 20
				LED2.Mesh.VertexColor = Vector3.new(v3, v3, v3)
				LED2.Light.Brightness = lastdim2 * 2
				LED2.Light.Enabled = true
			end

			local LED3 = cob.LED3
			local lastdim3 = v2.lastdim3

			if lastdim3 == 0 then
				SetLEDDim(LED3, 0) -- inferred equivalent call
			else
				local v3 = 1 + lastdim3 * 20
				LED3.Mesh.VertexColor = Vector3.new(v3, v3, v3)
				LED3.Light.Brightness = lastdim3 * 2
				LED3.Light.Enabled = true
			end

			local LED4 = cob.LED4
			local lastdim4 = v2.lastdim4

			if lastdim4 == 0 then
				SetLEDDim(LED4, 0) -- inferred equivalent call
			else
				local v3 = 1 + lastdim4 * 20
				LED4.Mesh.VertexColor = Vector3.new(v3, v3, v3)
				LED4.Light.Brightness = lastdim4 * 2
				LED4.Light.Enabled = true
			end
		end

		local v3 = p.Address - 1
		local lastdim = buffer.readu8(buf, v3 + 0) / 255
		local lastdim2 = buffer.readu8(buf, v3 + 1) / 255
		local lastdim3 = buffer.readu8(buf, v3 + 2) / 255
		local lastdim4 = buffer.readu8(buf, v3 + 3) / 255
		buffer.readu8(buf, v3 + 4)
		buffer.readu8(buf, v3 + 5)
		buffer.readu8(buf, v3 + 6)
		buffer.readu8(buf, v3 + 7)
		local _parent = instance.Parent

		if lastdim ~= v2.lastdim1 then
			v2.lastdim1 = lastdim
			local LED1 = cob.LED1

			if lastdim == 0 then
				SetLEDDim(LED1, 0) -- inferred equivalent call
			else
				local v4 = 1 + lastdim * 20
				LED1.Mesh.VertexColor = Vector3.new(v4, v4, v4)
				LED1.Light.Brightness = lastdim * 2
				LED1.Light.Enabled = true
			end
		end

		if lastdim2 ~= v2.lastdim2 then
			v2.lastdim2 = lastdim2
			local LED2 = cob.LED2

			if lastdim2 == 0 then
				SetLEDDim(LED2, 0) -- inferred equivalent call
			else
				local v4 = 1 + lastdim2 * 20
				LED2.Mesh.VertexColor = Vector3.new(v4, v4, v4)
				LED2.Light.Brightness = lastdim2 * 2
				LED2.Light.Enabled = true
			end
		end

		if lastdim3 ~= v2.lastdim3 then
			v2.lastdim3 = lastdim3
			local LED3 = cob.LED3

			if lastdim3 == 0 then
				SetLEDDim(LED3, 0) -- inferred equivalent call
			else
				local v4 = 1 + lastdim3 * 20
				LED3.Mesh.VertexColor = Vector3.new(v4, v4, v4)
				LED3.Light.Brightness = lastdim3 * 2
				LED3.Light.Enabled = true
			end
		end

		if lastdim4 ~= v2.lastdim4 then
			v2.lastdim4 = lastdim4
			local LED4 = cob.LED4

			if lastdim4 == 0 then
				SetLEDDim(LED4, 0) -- inferred equivalent call
			else
				local v4 = 1 + lastdim4 * 20
				LED4.Mesh.VertexColor = Vector3.new(v4, v4, v4)
				LED4.Light.Brightness = lastdim4 * 2
				LED4.Light.Enabled = true
			end
		end
	end
end

function Blinder4X100.CleanUp(p)
	v[p] = nil
end

return Blinder4X100