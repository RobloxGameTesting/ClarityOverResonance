local Serializer = {}

function Serializer.CFrameToTable(cframe)
	return { cframe:GetComponents() }
end

function Serializer.ColorToTable(data)
	return { data.R, data.G, data.B }
end

function Serializer.tableToVec(list)
	return (Vector3.new(list[1], list[2], list[3]))
end

function Serializer.VecToTable(data)
	return { data.X, data.Y, data.Z }
end

function Serializer.tableToCFrame(list)
	return CFrame.new(unpack(list))
end

function Serializer.applyNumberValue(instance, childName, p)
	local values = instance:FindFirstChild("Values", true)

	if not values then
		warn("'Values' container tidak ditemukan.")

		return
	end

	local numberValue = values:FindFirstChild(childName)

	if numberValue and numberValue:IsA("NumberValue") then
		numberValue.Value = p
	else
		warn("NumberValue '" .. childName .. "' tidak ditemukan.")
	end
end

function Serializer.getScaleConstraints(instance)
	local axissizeallow = instance:GetAttribute("axissizeallow") or Vector3.new(1, 1, 1)
	local maxsize = instance:GetAttribute("maxsize") or Vector3.new(100, 100, 100)
	local minsize = instance:GetAttribute("minsize") or Vector3.new(1, 1, 1)

	return {
		x = axissizeallow.X > 0,
		y = axissizeallow.Y > 0,
		z = axissizeallow.Z > 0
	}, maxsize, minsize
end

function safeSet(p, p2, p3)
	pcall(function()
		p[p2] = p3
	end)
end
script:FindFirstChildWhichIsA("SurfaceGui")
local v = {
	TextureID = function(part, textureID)
		if part:FindFirstChildWhichIsA("SurfaceGui") or part:GetAttribute("TypeBox") == "SongPicker" then
			local imageLabel = part:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("ImageLabel")

			if imageLabel then
				imageLabel.Image = "rbxassetid://" .. string.match(textureID, "%d+")
			end

			part:SetAttribute("TextureID", (tonumber(string.match(textureID, "%d+"))))
		else
			if not part:IsA("MeshPart") then
				part:SetAttribute("TextureID", textureID)

				return
			end

			part.TextureID = "rbxassetid://" .. string.match(textureID, "%d+")
			part:SetAttribute("TextureID", (tonumber(string.match(textureID, "%d+"))))
		end
	end,
	Transparency = function(p, value)
		p.Transparency = math.clamp(value, 0, 1)
	end,
	Size = function(p, p2)
		p.Size = typeof(p2) == "Vector3" and p2 or Serializer.tableToVec(p2)
	end
}

function Serializer.setProp(p, p2, p3)
	local v2 = v[p2]

	if v2 then
		v2(p, p3)
	else
		safeSet(p, p2, p3)
	end
end

function Serializer.formatTimeForDisplay(_)
	local v2 = os.date("*t")

	return string.format("%02d:%02d:%02d, %02d %s %d", v2.hour, v2.min, v2.sec, v2.day, ({
		"Januari",
		"Februari",
		"Maret",
		"April",
		"Mei",
		"Juni",
		"Juli",
		"Agustus",
		"September",
		"Oktober",
		"November",
		"Desember"
	})[v2.month], v2.year)
end

function Serializer:applyColor(list)
	if not self or type(list) ~= "table" or #list ~= 3 then
		return
	end

	local v2, v3, v4 = unpack(list)
	local color = v2 <= 1 and v3 <= 1 and v4 <= 1 and Color3.new(v2, v3, v4) or Color3.fromRGB(v2, v3, v4)
	self:SetAttribute("Color", color)

	if not self:FindFirstChild("Paint") then
		self.Color = color

		return
	end

	self.Paint.Color = color
	self.Color = color
end

function Serializer.getmassdata(part)
	if not part:IsA("BasePart") then
		return 0
	end

	local size = part.Size
	return size.X * size.Y * size.Z * 0.021952000000000006 * ((part.CurrentPhysicalProperties or PhysicalProperties.new(part.Material)).Density * 1000)
end

function Serializer.createBoundingBox(size, instance)
	if not (instance and instance:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local spawnerBoundingBox = Instance.new("Part")
	spawnerBoundingBox.Name = "SpawnerBoundingBox"
	spawnerBoundingBox.Parent = workspace
	spawnerBoundingBox.Anchored = true
	spawnerBoundingBox.CanCollide = false
	spawnerBoundingBox.CastShadow = false
	spawnerBoundingBox.Size = size
	spawnerBoundingBox.Transparency = 0.5
	spawnerBoundingBox.Color = Color3.new(0, 0.5, 1)
	spawnerBoundingBox.Material = Enum.Material.SmoothPlastic

	return spawnerBoundingBox
end

return Serializer