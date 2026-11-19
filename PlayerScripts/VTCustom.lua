local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local template = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("VideoTron"):WaitForChild("Template")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local videoTron = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("VideoTron")
local v = {}

local function ConvertSize2Fov(sizeImage) -- 2 equivalent calls inferred from this helper
	return (math.max(100 - sizeImage * 10, 0))
end

local function CreateSequenceAnimator(main, images, bufferCount, speed)
	local sequenceAnimator = {
		Images = images,
		Speed = speed,
		BufferCount = bufferCount,
		Buffers = {},
		CurrentFrame = 1,
		CurrentBufferIndex = 1,
		IsPlaying = false,
		TotalTime = 0
	}

	for i = 1, bufferCount do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Buffer_" .. i
		imageLabel.Size = UDim2.new(1, 0, 1, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ZIndex = i
		imageLabel.Parent = main

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 200)
		uiCorner.Parent = imageLabel

		if images[i] then
			imageLabel.Image = "rbxassetid://" .. images[i]
		end

		table.insert(sequenceAnimator.Buffers, imageLabel)
	end

	function sequenceAnimator:Play()
		if self.IsPlaying then
			return
		end

		self.IsPlaying = true
		self.CurrentFrame = 1
		self.TotalTime = 0
		self.CurrentBufferIndex = 1

		for i = 1, self.BufferCount do
			if self.Images[i] then
				self.Buffers[i].Image = "rbxassetid://" .. self.Images[i]
			end
		end
	end

	function sequenceAnimator:Stop()
		self.IsPlaying = false
	end

	function sequenceAnimator:Update(p)
		if not self.IsPlaying or self.Speed == 0 then
			return
		end

		local count = #self.Images

		if count == 0 then
			return
		end

		self.TotalTime += p
		local v2 = 1 / self.Speed

		if v2 <= self.TotalTime then
			self.TotalTime -= v2

			for i = 1, self.BufferCount do
				local zIndex = (i - self.CurrentBufferIndex + self.BufferCount - 1) % self.BufferCount + 1
				self.Buffers[i].ZIndex = zIndex
			end

			local v3 = self.CurrentBufferIndex - 1

			if v3 < 1 then
				v3 = self.BufferCount
			end

			local buf = self.Buffers[v3]

			local v4 = (self.CurrentFrame + self.BufferCount - 1) % count + 1

			if self.Images[v4] then
				buf.Image = "rbxassetid://" .. self.Images[v4]
			end

			self.CurrentFrame = self.CurrentFrame % count + 1
			self.CurrentBufferIndex = self.CurrentBufferIndex % self.BufferCount + 1
		end
	end

	function sequenceAnimator:Destroy()
		self:Stop()

		for _, buf in ipairs(self.Buffers) do
			buf:Destroy()
		end

		self.Buffers = {}
	end

	return sequenceAnimator
end

local function ParseTextureIDs(textureID)
	local textureIDs = {}

	if textureID then
		for k in string.gmatch(tostring(textureID), "([^,%s]+)") do
			table.insert(textureIDs, k)
		end
	end

	return textureIDs
end

local function addvtcustom(part)
	task.wait(1)
	local vt = template:Clone()
	vt.Parent = videoTron
	vt.Adornee = part
	vt.Enabled = true
	vt.Name = "VT"

	local main = vt:WaitForChild("Main")
	local viewportFrame = main:WaitForChild("Main"):WaitForChild("ViewportFrame")
	local rtpt = viewportFrame:WaitForChild("RTPT")
	local camera = Instance.new("Camera", viewportFrame)
	viewportFrame.CurrentCamera = camera
	camera.CFrame = CFrame.new(0, 0, 2)
	local MIMAGE1 = rtpt:WaitForChild("MIMAGE1")
	local MIMAGE2 = rtpt:WaitForChild("MIMAGE2")

	camera.CFrame = CFrame.new(Vector3.new(0, 0, 2)) * CFrame.Angles(0, 0, (math.rad((part:GetAttribute("Rotation")))))
	camera.FieldOfView = ConvertSize2Fov(part:GetAttribute("SizeImage")) -- inferred equivalent call

	local sequenceAnimator = nil
	local isUsingSequence = false
	local _ = {}

	local v2 = {}

	local function SetupSingleMode(p) -- 2 equivalent calls inferred from this helper
		if sequenceAnimator then
			sequenceAnimator:Destroy()
			sequenceAnimator = nil
			v2.SequenceAnimator = nil
		end

		MIMAGE1.Texture = "rbxassetid://" .. p
		MIMAGE2.Texture = "rbxassetid://" .. p

		viewportFrame.Visible = true

		isUsingSequence = false
		_ = { p }
	end

	local function SetupSequenceMode(images) -- 2 equivalent calls inferred from this helper
		if sequenceAnimator then
			sequenceAnimator:Destroy()
			sequenceAnimator = nil
		end

		viewportFrame.Visible = false

		sequenceAnimator = CreateSequenceAnimator(main, images, 30, math.clamp(part:GetAttribute("Speed"), 0, 45))
		sequenceAnimator:Play()
		v2.SequenceAnimator = sequenceAnimator

		isUsingSequence = true
		_ = images
	end

	local textureID = part:GetAttribute("TextureID")

	if textureID then
		local images = ParseTextureIDs(textureID)

		if #images > 1 then
			SetupSequenceMode(images) -- inferred equivalent call
		else
			SetupSingleMode(images[1]) -- inferred equivalent call
		end
	end

	local edgeThick = part:GetAttributes().EdgeThick or 0
	main.Main.UIStroke.Thickness = edgeThick * 0.01

	local attributeChangedConnection = part.AttributeChanged:Connect(function(p)
		if p == "TextureID" then
			local textureID2 = part:GetAttribute("TextureID")

			if textureID2 then
				local images = ParseTextureIDs(textureID2)
				print(images)

				if #images > 1 then
					SetupSequenceMode(images) -- inferred equivalent call
				else
					SetupSingleMode(images[1]) -- inferred equivalent call
				end
			end
		elseif p == "Rotation" then
			camera.CFrame = CFrame.new(Vector3.new(0, 0, 2)) * CFrame.Angles(
				0,
				0,
				(math.rad((part:GetAttribute("Rotation"))))
			)
		elseif p == "SizeImage" then
			camera.FieldOfView = ConvertSize2Fov(part:GetAttribute("SizeImage")) -- inferred equivalent call
		elseif p == "EdgeThick" then
			main.Main.UIStroke.Thickness = part:GetAttribute("EdgeThick") * 0.01
		elseif p == "Speed" and sequenceAnimator then
			sequenceAnimator.Speed = math.clamp(part:GetAttribute("Speed"), 0, 45)
			sequenceAnimator.TotalTime = 0
		end
	end)

	v2.BB = part
	v2.VT = vt
	v2.Conn = attributeChangedConnection
	v2.SequenceAnimator = sequenceAnimator
	v2.IsUsingSequence = isUsingSequence
	v2.Main = main
	v2.ViewportFrame = viewportFrame
	v2.RTPT = rtpt
	v2.MIMAGE1 = MIMAGE1
	v2.MIMAGE2 = MIMAGE2
	v2.Camera = camera
	v[part] = v2
end

CollectionService:GetInstanceAddedSignal("VTCustom"):Connect(function(part)
	if part:IsA("BasePart") then
		addvtcustom(part)
	end
end)

for _, part in ipairs(CollectionService:GetTagged("VTCustom")) do
	if part:IsA("BasePart") then
		addvtcustom(part)
	end
end

CollectionService:GetInstanceRemovedSignal("VTCustom"):Connect(function(p)
	local v2 = v[p]

	if v2 then
		if v2.VT then
			v2.VT:Destroy()
		end

		if v2.Conn then
			v2.Conn:Disconnect()
		end

		if v2.SequenceAnimator then
			v2.SequenceAnimator:Destroy()
		end

		v[p] = nil
	end
end)

RunService.RenderStepped:Connect(function(dt)
	for k, v2 in pairs(v) do
		local success, result = pcall(function()
			if k:IsDescendantOf(game.ReplicatedStorage) then
				if v2.VT.Enabled then
					v2.VT.Enabled = false
				end
			else
				local main = v2.Main

				if not (main and v2.ViewportFrame) then
					return
				end

				local rtpt = v2.RTPT

				if not rtpt then
					return
				end

				local attributes = k:GetAttributes()
				local typeRot = attributes.TypeRot
				local speedRot = attributes.SpeedRot or 0
				local shake = attributes.Shake or 0
				local edgeSpeed = attributes.EdgeSpeed or 0

				if edgeSpeed ~= 0 then
					main.Main.UIStroke.UIGradient.Rotation = (main.Main.UIStroke.UIGradient.Rotation + dt * 60 * edgeSpeed) % 360
				end

				if shake and shake ~= 0 then
					local v3 = math.sin(tick() * shake) * 0.025
					local v4 = math.cos(tick() * shake) * 0.025
					main.Position = UDim2.new(v3, 0, v4, 0)
				else
					main.Position = UDim2.new(0, 0, 0, 0)
				end

				if v2.SequenceAnimator and v2.SequenceAnimator.IsPlaying then
					v2.SequenceAnimator:Update(dt)
				elseif typeRot == 1 and speedRot ~= 0 then
					rtpt.CFrame *= CFrame.Angles(0, math.rad(speedRot * dt * 60), 0)
				elseif typeRot == 2 and speedRot ~= 0 then
					rtpt.Rotation = Vector3.new(0, math.deg(math.sin(tick() * speedRot) * 0.3490658503988659), 0)
				else
					rtpt.Rotation = Vector3.new(0, 0, 0)
				end
			end
		end)

		if not success then
			warn("VTList error soal e", k, result)
		end
	end
end)