local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local lensFlare = ReplicatedStorage.LensFlare
local assets = lensFlare.Assets
local Configuration = require(lensFlare.Configuration)

local NUMBER_OF_RAYCASTS = Configuration.NUMBER_OF_RAYCASTS
local RAYCAST_RADIUS = Configuration.RAYCAST_RADIUS
local TRANSPARENCY_THRESHOLD = Configuration.TRANSPARENCY_THRESHOLD
local vector2 = Vector2.new(1920, 1080)

local v = {
	ColorBlend = 0,
	Position = Vector3.new(1, 1, 1),
	PositionMult = 1,
	Rotates = false,
	SizeFade = NumberSequence.new(1),
	SquashFade = NumberSequence.new(0),
	TransparencyFade = NumberSequence.new(0)
}

local _ = { "Position" }

local v2 = table.create(NUMBER_OF_RAYCASTS)
local v3 = { LensFlareStrength = 1, LensFlareDistance = 0 }

local v4 = {
	"Size",
	"Squash",
	"Transparency",
	"LocalTransparencyModifier",
	"Color",
	"Rotation",
	"ZOffset",
	"Lifetime"
}

for i = 1, NUMBER_OF_RAYCASTS do
	local v5 = 6.283185307179586 * ((i - 1) / NUMBER_OF_RAYCASTS)
	v2[i] = { math.cos(v5) * RAYCAST_RADIUS, math.sin(v5) * RAYCAST_RADIUS }
end

local particleEmitter = Instance.new("ParticleEmitter")
local emit = particleEmitter.Emit
local clear = particleEmitter.Clear

local LensFlare = {}
LensFlare.__index = LensFlare

local function evalNumberSequence(sequence, p: number)
	if p == 0 then
		return sequence.Keypoints[1].Value
	elseif p == 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if keypoint.Time <= p and p < keypoint2.Time then
			local v5 = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)

			return keypoint.Value + (keypoint2.Value - keypoint.Value) * v5
		end
	end
end

function LensFlare.new(p, childName: string, part)
	local child = assets:FindFirstChild(childName)
	assert(child, `LensFlare: No lens flare folder called {childName} under LensFlare.Assets`)

	local children = child:GetChildren()

	local object = setmetatable({}, LensFlare)

	local guid = HttpService:GenerateGUID(false)

	object._id = guid
	object.Enabled = true

	object.Camera = p
	object.Part = part

	object.Attachments = table.create(#children)
	object.FlareEmitters = table.create(#children)

	object.Alpha = 0
	object._forceRecompute = false

	local attributesByAttributeName = {}
	local connections = {}
	local attributeCache = {}
	local v5 = 1
	local propertyCache = {}

	for attributeName, v6 in v3 do
		attributesByAttributeName[attributeName] = part:GetAttribute(attributeName) or v6

		table.insert(connections, (part:GetAttributeChangedSignal(attributeName):Connect(function()
			local attribute = part:GetAttribute(attributeName) or v6
			attributesByAttributeName[attributeName] = attribute
			object._forceRecompute = true
		end)))
	end

	attributeCache[part] = attributesByAttributeName

	for _, emitter in children do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local attachment = Instance.new("Attachment")
		attachment.Name = `LensFlare_{childName}_{emitter.Name}`
		attachment.Parent = p

		object.Attachments[v5] = attachment

		propertyCache[attachment] = { attachment.Position }

		local instance = Instance.fromExisting(emitter)
		instance.ZOffset = 0
		instance.Enabled = false
		instance.Parent = attachment

		object.FlareEmitters[v5] = instance

		local hsv, v6 = (part:IsA("BasePart") and part.Color or Color3.new(1, 1, 1)):ToHSV()
		local attributes = {}

		for attributeName, v7 in v do
			attributes[attributeName] = instance:GetAttribute(attributeName) or v7
			local v8 = attributeName
			local v9 = v7
			table.insert(connections, (instance:GetAttributeChangedSignal(attributeName):Connect(function()
				local attribute = instance:GetAttribute(v8) or v9
				attributes[v8] = attribute
				object._forceRecompute = true

				if v8 == "ColorBlend" then
					attributes._color = ColorSequence.new(Color3.fromHSV(hsv, attribute, 1))
				end
			end)))
		end

		if attributes.ColorBlend and attributes.ColorBlend > 0 then
			attributes._color = ColorSequence.new(Color3.fromHSV(hsv, v6 * attributes.ColorBlend, 1))

			if part:IsA("BasePart") then
				table.insert(connections, part:GetPropertyChangedSignal("Color"):Connect(function()
					local hsv2, v7 = part.Color:ToHSV()

					attributes._color = ColorSequence.new(Color3.fromHSV(hsv2, v7 * attributes.ColorBlend, 1))

					object._forceRecompute = true
				end))
			end
		end

		local v7 = {}

		for _, v8 in v4 do
			v7[v8] = instance[v8]
		end

		attributeCache[instance] = attributes
		propertyCache[instance] = v7

		v5 += 1
	end

	object._attributeCache = attributeCache
	object._attributeConns = connections
	object._propertyCache = propertyCache

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { part, CollectionService:GetTagged("IgnoreLensFlare") }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true

	object.RaycastParams = raycastParams

	object._connections = {
		CollectionServiceConn = CollectionService:GetInstanceAddedSignal("IgnoreLensFlare"):Connect(function(p2)
			object.RaycastParams:AddToFilter(p2)
		end)
	}

	RunService:BindToRenderStep(`LensFlare_{guid}`, Enum.RenderPriority.Camera.Value + 10, function(p2: number)
		if not object.Enabled then
			return
		end

		object:Update(p2)
	end)

	return object
end

function LensFlare:Destroy()
	for _, connection in self._connections do
		connection:Disconnect()
	end

	for _, attributeConn in self._attributeConns do
		attributeConn:Disconnect()
	end

	RunService:UnbindFromRenderStep(`LensFlare_{self._id}`)

	for _, flareEmitter in self.FlareEmitters do
		flareEmitter:Destroy()
	end

	for _, attachment in self.Attachments do
		attachment:Destroy()
	end

	table.clear(self)
	setmetatable(self, nil)
end

function LensFlare:Update(p: number)
	debug.profilebegin(`LensFlareUpdate_{self._id}`)

	local camera = self.Camera
	local part = self.Part
	local worldPosition = part:IsA("Attachment") and part.WorldPosition or part.Position

	local v5 = worldPosition - camera.CFrame.Position
	local v6 = vector.magnitude(v5)

	local attributeCache = self._attributeCache
	local propertyCache = self._propertyCache

	local v7 = attributeCache[part]
	local lensFlareDistance = v7.LensFlareDistance
	local lensFlareStrength = v7.LensFlareStrength

	if
		lensFlareStrength and lensFlareStrength <= 0
		or lensFlareDistance and lensFlareDistance > 0 and lensFlareDistance < v6
	then
		return
	end

	local v8 = math.clamp(vector.angle(camera.CFrame.LookVector, v5) / math.rad(camera.DiagonalFieldOfView) * 2, 0, 1)

	if lensFlareDistance and lensFlareDistance > 0 then
		v8 += v6 / lensFlareDistance
	end

	if v8 >= 1 then
		return
	end

	local worldToViewportPoint = camera:WorldToViewportPoint(worldPosition)
	local origin = camera:ViewportPointToRay(worldToViewportPoint.X, worldToViewportPoint.Y, 1).Origin

	local position = camera.CFrame:ToObjectSpace(CFrame.new(origin)).Position

	local raycastParams = self.RaycastParams

	local magnitude = (camera.ViewportSize / vector2).Magnitude

	debug.profilebegin(`LensFlareUpdate_{self._id}_RaycastStep`)
	local count = 0

	for _, v9 in v2 do
		local v10 = v9[1] * magnitude
		local v11 = v9[2] * magnitude

		local viewportPointToRay = camera:ViewportPointToRay(
			worldToViewportPoint.X + v10,
			worldToViewportPoint.Y + v11,
			1
		)
		local raycastResult = workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * v6,
			raycastParams
		)

		if not raycastResult then
			continue
		end

		local instance = raycastResult.Instance

		if instance:IsA("BasePart") then
			if
				not (TRANSPARENCY_THRESHOLD < instance.Transparency)
				and not (TRANSPARENCY_THRESHOLD < instance.LocalTransparencyModifier)
			then
				count += 1
				continue
			end

			raycastParams:AddToFilter(instance)
		else
			count += 1
		end
	end

	debug.profileend()

	local v9 = count / NUMBER_OF_RAYCASTS

	local attachments = self.Attachments
	local flareEmitters = self.FlareEmitters

	local alpha2 = lensFlareStrength * (1 - v8) * (1 - v9)
	local alpha = self.Alpha

	if v9 < 1 and v8 < 1 then
		if alpha2 == alpha and not self._forceRecompute then
			for _, flareEmitter in flareEmitters do
				clear(flareEmitter)

				local v10 = propertyCache[flareEmitter]

				local lifetime = v10.Lifetime
				local numberRange = NumberRange.new(p * 3)

				if lifetime ~= numberRange then
					flareEmitter.Lifetime = numberRange
					v10.Lifetime = numberRange
				end

				emit(flareEmitter, 1)
			end

			return
		end

		for i = 1, #flareEmitters do
			local attachment = attachments[i]
			local flareEmitter = flareEmitters[i]

			clear(flareEmitter)

			local v10 = attributeCache[flareEmitter]
			local v11 = propertyCache[flareEmitter]

			local _colorBlend = v10.ColorBlend
			local color = v10._color
			local position2 = v10.Position
			local positionMult = v10.PositionMult
			local rotates = v10.Rotates
			local sizeFade = v10.SizeFade
			local squashFade = v10.SquashFade
			local transparencyFade = v10.TransparencyFade

			local v12 = position.X * position2.x * positionMult
			local v13 = position.Y * position2.y * positionMult
			vector.create(v12, v13, position.Z)
			attachment.Position = vector.create(v12, v13, position.Z)

			local numberSequence = NumberSequence.new(evalNumberSequence(sizeFade, v8))
			local numberSequence2 = NumberSequence.new(evalNumberSequence(squashFade, v8))
			local numberSequence3 = NumberSequence.new((math.lerp(evalNumberSequence(transparencyFade, v8), 1, v9)))
			local localTransparencyModifier = 1 - lensFlareStrength

			if numberSequence ~= v11.Size then
				flareEmitter.Size = numberSequence
				v11.Size = numberSequence
			end

			if numberSequence2 ~= v11.Squash then
				flareEmitter.Squash = numberSequence2
				v11.Squash = numberSequence2
			end

			if numberSequence3 ~= v11.Transparency then
				flareEmitter.Transparency = numberSequence3
				v11.Transparency = numberSequence3
			end

			if localTransparencyModifier ~= v11.LocalTransparencyModifier then
				flareEmitter.LocalTransparencyModifier = 1 - lensFlareStrength
				v11.LocalTransparencyModifier = localTransparencyModifier
			end

			if color and color ~= v11.Color then
				flareEmitter.Color = color
				v11.Color = color
			end

			if rotates then
				local numberRange = NumberRange.new((math.deg((math.atan2(position.Y, position.X)))))

				if numberRange ~= v11.Rotation then
					flareEmitter.Rotation = numberRange
					v11.Rotation = numberRange
				end
			end

			local zOffset = math.min(-attachment.Position.Z * 0.8, 0)

			if zOffset ~= v11.ZOffset then
				flareEmitter.ZOffset = zOffset
				v11.ZOffset = zOffset
			end

			local lifetime = v11.Lifetime
			local numberRange = NumberRange.new(p * 3)

			if lifetime ~= numberRange then
				flareEmitter.Lifetime = numberRange
				v11.Lifetime = numberRange
			end

			emit(flareEmitter, 1)
		end
	end

	self.Alpha = alpha2

	debug.profileend()
end

return LensFlare