local Players = game:GetService("Players")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CurrentCamera = workspace.CurrentCamera
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer

local humanoid = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")

if not humanoid then
	warn("Humanoid tidak ditemukan dalam karakter!")
end

local v = {}
local v2 = false
local cframe = CurrentCamera.CFrame
local CameraType = CurrentCamera.CameraType
local cameraSubject = CurrentCamera.CameraSubject

local function tweenCamera(cframe2)
	TweenService:Create(CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = cframe2
	})

	CurrentCamera.CFrame = cframe2
end

local function setCanQuery(p, canQuery) -- 3 equivalent calls inferred from this helper
	local parent = p.Parent

	if parent and parent:IsA("BasePart") then
		parent.CanQuery = canQuery
	end
end

local v3 = nil

local function onTargetClicked(cam, hitbox)
	if v2 and v3 == cam then
		return
	end

	if v2 and v3 and v3 ~= cam then
		for _, v4 in pairs(v) do
			if v4.cam == v3 then
				setCanQuery(v4.hitbox, true) -- inferred equivalent call
			end
		end
	end

	if not v2 then
		cframe = CurrentCamera.CFrame
		CameraType = CurrentCamera.CameraType
		cameraSubject = humanoid
	end

	v2 = true
	v3 = cam
	setCanQuery(hitbox, false) -- inferred equivalent call
	CurrentCamera.CameraType = Enum.CameraType.Custom
	CurrentCamera.CameraSubject = cam
	tweenCamera(cam.CFrame)
end

local function onBackClicked()
	if not v2 then
		return
	end

	tweenCamera(cframe)
	CurrentCamera.CameraType = CameraType
	CurrentCamera.CameraSubject = cameraSubject

	for _, v4 in pairs(v) do
		setCanQuery(v4.hitbox, true) -- inferred equivalent call
	end

	v2 = false
	v3 = nil
end

humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
	if humanoid.Sit == false and humanoid.MoveDirection.Magnitude > 0 then
		onBackClicked()
	end
end)

local function addCamLocation(model)
	local cam = model:WaitForChild("Cam")
	local hitbox = model:WaitForChild("Hitbox")

	local clickDetector = cam and hitbox and hitbox:FindFirstChildWhichIsA("ClickDetector")

	if clickDetector then
		local v4 = { hitbox = clickDetector, cam = cam }

		table.insert(v, v4)

		clickDetector.MouseClick:Connect(function(_)
			onTargetClicked(v4.cam, v4.hitbox)
		end)
	end
end

CollectionService:GetInstanceAddedSignal("Cam_Location"):Connect(function(model)
	if model:IsA("Model") then
		addCamLocation(model)
	end
end)

CollectionService:GetInstanceRemovedSignal("Cam_Location"):Connect(function(p)
	for i = #v, 1, -1 do
		if v[i].model == p then
			table.remove(v, i)
		end
	end
end)

for _, model in pairs(workspace:GetDescendants()) do
	if model:IsA("Model") and model.Name == "Cam_Location" then
		addCamLocation(model)
	end
end