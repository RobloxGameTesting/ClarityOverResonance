local AssetService = game:GetService("AssetService")
local Core = require(script.Parent.Core)

local function bindSelf(p): boolean
	if not p.Source:IsA("BasePart") then
		return false
	end

	p.Target = p.Source
	return true
end

local function bindChildClass(className) -- 2 equivalent calls inferred from this helper
	return function(p): boolean
		local firstChildWhichIsA = p.Source:FindFirstChildWhichIsA(className)

		if not firstChildWhichIsA then
			return false
		end

		p.Target = firstChildWhichIsA
		return true
	end
end

local function setupNeon(part, p)
	if not part:IsA("BasePart") then
		return
	end

	if part:IsA("MeshPart") then
		part.TextureID = ""
	end

	part.Material = Enum.Material.Neon
	part.Transparency = 1
	part.Color = p.PartColor
end

local PartTypes = {}

PartTypes.m = {
	Info = "MeshPart/Part: tween Transparency (material Neon).",
	Setup = setupNeon,
	Bind = bindSelf,
	Apply = function(_, p)
		return { Transparency = Core.levelToTransparency(p) }
	end
}

PartTypes.sa = {
	Info = "MeshPart berisi SurfaceAppearance: tween EmissiveStrength.",
	Bind = bindChildClass("SurfaceAppearance"), -- inferred equivalent call
	Apply = function(_, p, _, p2)
		return {
			EmissiveStrength = p * p2.EmissiveStrength
		}
	end
}

PartTypes.mat = {
	Info = "Part: Material jadi Neon saat menyala, SmoothPlastic saat mati.",
	Bind = bindSelf,
	Apply = function(_, p)
		return nil, {
			Material = p > 0.8 and Enum.Material.Neon or Enum.Material.SmoothPlastic
		}
	end
}

local function lightType(className, info)
	return {
		Info = info,
		Setup = function(parent, data)
			local v = parent:FindFirstChildWhichIsA(className)

			if not v then
				v = Instance.new(className)
				v.Parent = parent
			end

			v.Enabled = false
			v.Brightness = 0
			v.Color = data.LightColor
			v.Range = data.Lamp.Range or 16
			v.Shadows = data.Cfg.LightShadows

			if className == "SpotLight" then
				v.Angle = 180
				v.Face = Enum.NormalId.Front
			elseif className == "SurfaceLight" then
				v.Angle = 135
				v.Face = Enum.NormalId.Front
			end
		end,
		Bind = bindChildClass(className), -- inferred equivalent call
		Apply = function(_, _, brightness)
			if brightness > 0 then
				return { Brightness = brightness }, { Enabled = true }
			end

			return { Brightness = 0 }, nil, { Enabled = false }
		end
	}
end

PartTypes.sp = lightType("SpotLight", "Part pembawa SpotLight (dibuat otomatis jika belum ada).")
PartTypes.pl = lightType("PointLight", "Part pembawa PointLight (dibuat otomatis jika belum ada).")
PartTypes.sf = lightType("SurfaceLight", "Part pembawa SurfaceLight (dibuat otomatis jika belum ada).")

PartTypes.em = {
	Info = "MeshPart: UV scroll via EditableMesh + tween Transparency (DRL).",
	Setup = function(part)
		if part:IsA("BasePart") then
			part.Transparency = 1
		end

		if part:GetAttribute("UVSpeed") == nil then
			part:SetAttribute("UVSpeed", 1)
		end

		if part:GetAttribute("UVScaleX") == nil then
			part:SetAttribute("UVScaleX", 1)
		end
	end,
	Bind = function(state): boolean
		local source = state.Source

		if not source:IsA("MeshPart") then
			return false
		end

		state.Target = source

		if state.UV then
			return true
		end

		local token = state.Token
		task.spawn(function()
			local success, result = pcall(function()
				local editableMeshAsync = AssetService:CreateEditableMeshAsync(source.MeshContent)

				if state.Token ~= token then
					editableMeshAsync:Destroy()
					return
				end

				local meshPartAsync = AssetService:CreateMeshPartAsync(Content.fromObject(editableMeshAsync))
				source:ApplyMesh(meshPartAsync)
				meshPartAsync:Destroy()

				local uvs = editableMeshAsync:GetUVs()
				local count = #uvs
				local v = table.create(count)
				local v2 = table.create(count)

				for i = 1, count do
					local uv = editableMeshAsync:GetUV(uvs[i])
					local x = uv.X
					local y = uv.Y
					v[i] = x
					v2[i] = y
				end

				if state.Token == token then
					state.UV = {
						Mesh = editableMeshAsync,
						Ids = uvs,
						U = v,
						V = v2,
						N = count,
						Offset = 0
					}
				else
					editableMeshAsync:Destroy()
				end
			end)

			if not success then
				warn("EpicLights // gagal membuat EditableMesh untuk " .. source:GetFullName() .. ": " .. tostring(result))
			end
		end)
		return true
	end,
	Apply = function(_, p)
		return { Transparency = Core.levelToTransparency(p) }
	end,
	OnToggle = function(p, p2, object)
		if p2 then
			object:SetAnimated(p, true)
		else
			task.delay(object.TweenTime + 0.05, function()
				if not p.On and p.Ready then
					object:SetAnimated(p, false)
				end
			end)
		end
	end,
	Update = function(p, p2)
		local uv = p.UV
		local target = p.Target

		if not (uv and target) then
			return
		end

		local uvSpeed = target:GetAttribute("UVSpeed") or 1
		local uvScaleX = target:GetAttribute("UVScaleX") or 1
		local offset = (uv.Offset + uvSpeed * p2) % 1
		uv.Offset = offset

		local mesh = uv.Mesh
		local ids = uv.Ids
		local u = uv.U
		local v = uv.V

		for i = 1, uv.N do
			mesh:SetUV(ids[i], Vector2.new(u[i] * uvScaleX + offset, v[i]))
		end
	end,
	Unbind = function(p, object)
		object:SetAnimated(p, false)
		local uv = p.UV

		if uv then
			p.UV = nil
			pcall(uv.Mesh.Destroy, uv.Mesh)
		end
	end
}

return PartTypes