local Serializer = require(script.Parent:WaitForChild("Serializer"))
local SandboxScanner = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SandBoxModels = ReplicatedStorage:WaitForChild("SandBoxModels")
local NotificationModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("Notification"):WaitForChild("NotificationModule"))
local ConfigDataServ = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("ConfigDataServ"))
local SandBox = game.Workspace:WaitForChild("SandBox")

SandboxScanner.SYSTEM_ATTRIBUTES = {
	TypeBox = true,
	axissizeallow = true,
	maxsize = true,
	minsize = true,
	transparency = true,
	textureid = true,
	SubType = true,
	ScaleModLimit = true,
	InitTransparency = true,
	CountLimits = true,
	IsFixed = true
}

local function getVariationTargets(instance, k)
	local variationTargets = {}
	local set = {}
	local function addTarget(part) -- 1 equivalent call inferred from this helper
		if part and part:IsA("BasePart") and not set[part] then
			set[part] = true
			table.insert(variationTargets, part)
		end
	end

	local body = instance:FindFirstChild("Body")

	if not body then
		return variationTargets
	end

	for _, part in ipairs(body:GetChildren()) do
		if not (part:IsA("BasePart") and (not k or part.Name == k) and part and part:IsA("BasePart")) then
			continue
		end

		if set[part] then
			continue
		end

		set[part] = true
		table.insert(variationTargets, part)
	end

	local variations = body:FindFirstChild("Variations")

	if variations and variations:IsA("Model") then
		for _, descendant in ipairs(variations:GetDescendants()) do
			if descendant:IsA("ObjectValue") and (not k or descendant.Name == k) then
				addTarget(descendant.Value) -- inferred equivalent call
			elseif
				descendant:IsA("BasePart")
				and (not k or descendant.Name == k)
				and descendant
				and descendant:IsA("BasePart")
				and not set[descendant]
			then
				set[descendant] = true
				table.insert(variationTargets, descendant)
			end
		end
	end

	return variationTargets
end

local function getAllVariationTargets(instance)
	local allVariationTargets = {}
	local function addTarget(name, p) -- 3 equivalent calls inferred from this helper
		allVariationTargets[name] = allVariationTargets[name] or {}
		table.insert(allVariationTargets[name], p)
	end
	local body = instance:FindFirstChild("Body")

	if not body then
		return allVariationTargets
	end

	for _, part in ipairs(body:GetChildren()) do
		if part:IsA("BasePart") then
			addTarget(part.Name, part) -- inferred equivalent call
		end
	end

	local variations = body:FindFirstChild("Variations")

	if variations and variations:IsA("Model") then
		for _, descendant in ipairs(variations:GetDescendants()) do
			if descendant:IsA("ObjectValue") and descendant.Value and descendant.Value:IsA("BasePart") then
				addTarget(descendant.Name, descendant.Value) -- inferred equivalent call
			elseif descendant:IsA("BasePart") then
				addTarget(descendant.Name, descendant) -- inferred equivalent call
			end
		end
	end

	return allVariationTargets
end

function SandboxScanner.GetModelData(model)
	if not (model:IsA("Model") and model.PrimaryPart) then
		return nil
	end

	local v = {}
	local primaryPart = model.PrimaryPart

	if primaryPart:GetAttribute("Vehicles") == "Vehicles" then
		v.Vehicles = true
	end

	v.TipeModel = primaryPart:GetAttribute("TypeBox") or "Unknown"
	v.CFrame = Serializer.CFrameToTable(primaryPart.CFrame)

	local child = SandBoxModels:FindFirstChild(v.TipeModel)
	local set = {}
	local color2 = {}

	for k, list in pairs(getAllVariationTargets(model)) do
		for _, item in ipairs(list) do
			local color = item:GetAttribute("Color")

			if typeof(color) == "Color3" then
				local v2 = child and getVariationTargets(child, k)[1]

				if not v2 or v2:GetAttribute("Color") ~= color then
					color2[k] = Serializer.ColorToTable(color)
				end
			end

			if item:GetAttribute("Variation") == true then
				set[k] = true
			end
		end
	end

	if next(color2) ~= nil then
		v.color = color2
	end

	if next(set) ~= nil then
		v.variations = set
	end

	local attributes = primaryPart:GetAttributes()
	local properties = {}

	for k, attribute in pairs(attributes) do
		if SandboxScanner.SYSTEM_ATTRIBUTES[k] then
			continue
		end

		if typeof(attribute) == "Color3" then
			properties[k] = Serializer.ColorToTable(attribute)
		elseif typeof(attribute) == "Vector3" then
			properties[k] = Serializer.VecToTable(attribute)
		else
			properties[k] = attribute
		end
	end

	if primaryPart:GetAttribute("axissizeallow") ~= nil then
		properties.Size = Serializer.VecToTable(primaryPart.Size)

		if v.TipeModel == "Banner" then
			properties.TextureID = primaryPart.TextureID
		end
	end

	v.properties = properties

	if primaryPart:GetAttribute("SubType") ~= "Vehicles" then
		return { model = v }
	end

	v.vehicles = true
	return { vehicles = v }
end

function SandboxScanner.ScanAll(instance)
	local modelDatas = {}

	for _, model in ipairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local modelData = SandboxScanner.GetModelData(model)

		if modelData then
			table.insert(modelDatas, modelData)
		end
	end

	return modelDatas
end

function SandboxScanner.ClearAll()
	for _, model in ipairs(SandBox:GetChildren()) do
		if model:IsA("Model") then
			model:Destroy()
		end
	end
end

function SandboxScanner.LoadSandBox(items, parent)
	SandboxScanner.ClearAll()

	for _, item in pairs(items) do
		local _vehicles = item.vehicles

		local model = item.model or item.vehicles

		if not (model and model.TipeModel) then
			continue
		end

		local child = SandBoxModels:FindFirstChild(model.TipeModel)

		if child then
			local clone = child:Clone()
			clone:SetPrimaryPartCFrame(Serializer.tableToCFrame(model.CFrame))
			local body = clone:FindFirstChild("Body")

			if body then
				if model.variations then
					for _, list in pairs(getAllVariationTargets(clone)) do
						for _, item2 in ipairs(list) do
							if item2:GetAttribute("Variation") == nil then
								continue
							end

							item2.Transparency = 1
							item2:SetAttribute("Variation", false)
						end
					end

					for k, _ in pairs(model.variations) do
						for _, v in ipairs(getVariationTargets(clone, k)) do
							v:SetAttribute("Variation", true)

							if v:GetAttribute("InitTransparency") == nil or not v:FindFirstChildWhichIsA("Decal") then
								v.Transparency = 0
							else
								v.Transparency = v:GetAttribute("InitTransparency")
								local grill = v:FindFirstChild("Grill")

								if grill then
									grill.Transparency = 0
								end
							end
						end
					end
				end

				if model.color then
					for k, v in pairs(model.color) do
						if not (k ~= "CFrame" and k ~= "TipeModel") then
							continue
						end

						for _, v2 in ipairs(getVariationTargets(clone, k)) do
							if type(v) == "table" then
								Serializer.applyColor(v2, v)
							end
						end
					end
				end

				if model.number then
					local values = body:FindFirstChild("Values")

					if values then
						for childName, v in pairs(model.number) do
							if not (childName ~= "CFrame" and childName ~= "TipeModel" and values:FindFirstChild(childName) and typeof(v) == "number") then
								continue
							end

							Serializer.applyNumberValue(body, childName, v)
						end
					end
				end
			end

			if model.properties then
				for k, property in pairs(model.properties) do
					if typeof(property) == "number" then
						clone.BoundingBox:SetAttribute(k, property)
					end

					if k == "Size" then
						Serializer.setProp(clone.PrimaryPart, "Size", property)
					end

					if k == "Color" then
						Serializer.applyColor(clone.PrimaryPart, property)
					end

					if k == "TextureID" then
						Serializer.setProp(clone.PrimaryPart, "TextureID", property)
					end

					if k == "Transparency" then
						Serializer.setProp(clone.PrimaryPart, "Transparency", property)
					end

					if k ~= "ScaleFac" then
						continue
					end

					local scaleModLimit = clone.BoundingBox:GetAttribute("ScaleModLimit")
					local scaleFac = child.PrimaryPart:GetAttribute("ScaleFac")
					local v

					if scaleModLimit then
						v = math.clamp(property, scaleModLimit.X, scaleModLimit.Y)
					else
						v = math.clamp(property, 4, 21)
					end

					clone:ScaleTo(1 + (v - scaleFac) * ConfigDataServ.SENSITIVITYSCALE)
					clone.PrimaryPart:SetAttribute("ScaleFac", v)
				end
			end

			clone.Parent = parent
		else
			NotificationModule.notify("Not Found", "Some models or items didn't found in the system.")
		end
	end
end

function SandboxScanner.loadoutdatedmodel(p, p2, parent)
	local dmod = p2.dmod

	if type(dmod) ~= "table" then
		warn("Invalid or missing modelsData (dmod) for slot", p)
		return
	end

	SandboxScanner.ClearAll()

	local combinedModel = Instance.new("Model")
	combinedModel.Name = "CombinedModel"
	combinedModel.Parent = parent

	for i, v in ipairs(dmod) do
		local model = v.model

		if model and model.TipeModel then
			local child = SandBoxModels:FindFirstChild(model.TipeModel)

			if child then
				local clone = child:Clone()
				clone:SetPrimaryPartCFrame(Serializer.tableToCFrame(model.CFrame))

				local body = clone:FindFirstChild("Body")

				if body then
					if model.color then
						for childName, v2 in pairs(model.color) do
							if not (childName ~= "CFrame" and childName ~= "TipeModel") then
								continue
							end

							local child2 = body:FindFirstChild(childName)

							if child2 and type(v2) == "table" then
								Serializer.applyColor(child2, v2)
							end
						end
					end

					if model.number then
						local values = body:FindFirstChild("Values")

						if values then
							for childName, v2 in pairs(model.number) do
								if not (childName ~= "CFrame" and childName ~= "TipeModel" and values:FindFirstChild(childName) and typeof(v2) == "number") then
									continue
								end

								Serializer.applyNumberValue(body, childName, v2)
							end
						end
					end
				end

				clone.Parent = combinedModel
			else
				warn(("obj '%s' not found for entry %d"):format(model.TipeModel, i))
			end
		else
			warn(("Entry %d missing TipeModel or model data"):format(i))
		end
	end

	local hitBoxAllowed = workspace.SBProperties.Hitbox.HitBoxAllowed

	local _, _ = combinedModel:GetBoundingBox()

	local cframe = CFrame.Angles(0, 1.5707963267948966, 0)

	combinedModel:PivotTo(hitBoxAllowed.CFrame * CFrame.new(Vector3.new(0, -12, 0)) * cframe)

	for _, child in pairs(combinedModel:GetChildren()) do
		child.Parent = combinedModel.Parent
	end

	combinedModel:Destroy()
end
return SandboxScanner