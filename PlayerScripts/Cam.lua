local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("CollectionService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CameraController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("CameraController"))
local GUIReferences = require(ReplicatedStorage.Modules:WaitForChild("UI"):WaitForChild("MainUI"):WaitForChild("GUIReferences"))

local v = {}
local v2 = nil
local function setCanQuery(part, canQuery) -- 4 equivalent calls inferred from this helper
	local parent = part.Parent

	if parent and parent:IsA("BasePart") then
		parent.CanQuery = canQuery
	end

	if part:IsA("BasePart") then
		part.CanQuery = canQuery
	end
end
local v3 = 0
local cameraTypeChangedConnection = nil
local function onTargetClicked(p, part)
	if CameraController.GetActiveInfo() == false then
		v3 = workspace.CurrentCamera.FieldOfView
	end

	CameraController:Exit()

	if v2 then
		setCanQuery(v2, true) -- inferred equivalent call
	end

	v2 = part
	setCanQuery(part, false) -- inferred equivalent call
	CameraController:ActivateForPart(p)
	cameraTypeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(function()
		if workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
			setCanQuery(part, true) -- inferred equivalent call

			if CameraController and CameraController.SetFOV then
				CameraController:SetFOV(v3)
			end

			if cameraTypeChangedConnection then
				cameraTypeChangedConnection:Disconnect()
				cameraTypeChangedConnection = nil
			end
		end
	end)
end

local function addCamLocation(instance)
	local cam = instance:FindFirstChild("Cam")
	local hitbox = instance:FindFirstChild("Hitbox")

	local clickDetector = cam and hitbox and hitbox:FindFirstChildWhichIsA("ClickDetector")

	if clickDetector then
		table.insert(v, { model = instance, cam = cam, hitbox = clickDetector })
		clickDetector.MouseClick:Connect(function(p)
			if p == LocalPlayer then
				print("Clicked on client")
				onTargetClicked(cam, clickDetector)
			end
		end)
	end
end

local CollectionService = game:GetService("CollectionService")
game:GetService("RunService")
local Players2 = game:GetService("Players")
local localPlayer = Players2.LocalPlayer

local v4 = {}
local v5 = {}

local function isModelReady(instance)
	if not (instance and instance.Parent) then
		return false
	end

	local cam = instance:FindFirstChild("Cam", true)
	local hitbox = instance:FindFirstChild("Hitbox", true)

	if cam and hitbox then
		return cam, hitbox, (hitbox:FindFirstChildWhichIsA("ClickDetector", true))
	end

	return false
end

local function registerCamLocation(model, cam, hitbox, clickDetector)
	for _, v6 in ipairs(v4) do
		if v6.model == model then
			return
		end
	end

	table.insert(v4, { model = model, cam = cam, hitbox = hitbox, clickDetector = clickDetector })

	clickDetector.MouseClick:Connect(function(p)
		if p == localPlayer then
			onTargetClicked(cam, clickDetector)
		end
	end)
end

local function reEnableAllHitboxes()
	for _, v6 in ipairs(v4) do
		if v6.hitbox then
			setCanQuery(v6.hitbox, true) -- inferred equivalent call
		end
	end
end

local function clearPendingEntry(p) -- 5 equivalent calls inferred from this helper
	local v6 = v5[p]

	if v6 then
		if v6.conn then
			pcall(function()
				v6.conn:Disconnect()
			end)
		end

		v5[p] = nil
	end
end

local function addCamLocationSafe(model)
	if not (model and model.Parent) then
		return
	end

	local v6, hitbox, clickDetector

	if model and model.Parent then
		v6 = model:FindFirstChild("Cam", true)
		hitbox = model:FindFirstChild("Hitbox", true)

		if v6 and hitbox then
			clickDetector = hitbox:FindFirstChildWhichIsA("ClickDetector", true)
		else
			v6 = false
			hitbox = nil
		end
	else
		v6 = false
	end

	if v6 and hitbox and clickDetector then
		registerCamLocation(model, v6, hitbox, clickDetector)
		return
	end

	if v5[model] then
		v5[model].addedAt = tick()
		return
	end

	local descendantAddedConnection = model.DescendantAdded:Connect(function(_)
		local model2 = model
		local v7, hitbox2, clickDetector2

		if model2 and model2.Parent then
			v7 = model2:FindFirstChild("Cam", true)
			hitbox2 = model2:FindFirstChild("Hitbox", true)

			if v7 and hitbox2 then
				clickDetector2 = hitbox2:FindFirstChildWhichIsA("ClickDetector", true)
			else
				v7 = false
				hitbox2 = nil
			end
		else
			v7 = false
		end

		if v7 and hitbox2 and clickDetector2 then
			registerCamLocation(model, v7, hitbox2, clickDetector2)
			clearPendingEntry(model) -- inferred equivalent call
		end
	end)

	v5[model] = { addedAt = tick(), conn = descendantAddedConnection }
end

spawn(function()
	while true do
		wait(30)
		local now = tick()

		for k, v6 in pairs(v5) do
			if k and k.Parent then
				local v7, hitbox, clickDetector

				if k and k.Parent then
					v7 = k:FindFirstChild("Cam", true)
					hitbox = k:FindFirstChild("Hitbox", true)

					if v7 and hitbox then
						clickDetector = hitbox:FindFirstChildWhichIsA("ClickDetector", true)
					else
						v7 = false
						hitbox = nil
					end
				else
					v7 = false
				end

				if v7 and hitbox and clickDetector then
					registerCamLocation(k, v7, hitbox, clickDetector)
					clearPendingEntry(k) -- inferred equivalent call
				elseif now - v6.addedAt > 300 then
					clearPendingEntry(k) -- inferred equivalent call
				end
			else
				clearPendingEntry(k) -- inferred equivalent call
			end
		end
	end
end)

CollectionService:GetInstanceAddedSignal("Cam_Location"):Connect(function(model)
	if model:IsA("Model") then
		addCamLocationSafe(model)
	end
end)

for _, model in ipairs(CollectionService:GetTagged("Cam_Location")) do
	if model:IsA("Model") then
		addCamLocationSafe(model)
	end
end

CollectionService:GetInstanceRemovedSignal("Cam_Location"):Connect(function(p)
	for i = #v4, 1, -1 do
		if v4[i].model == p then
			table.remove(v4, i)
		end
	end

	clearPendingEntry(p) -- inferred equivalent call
end)

local function bindSafety(p) -- 1 equivalent call inferred from this helper
	if p then
	end
end

local function onCharacterAdded(character)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		character.ChildAdded:Connect(function(humanoid2)
			if humanoid2:IsA("Humanoid") then
				bindSafety(not humanoid2) -- inferred equivalent call
			end
		end)
	end

	task.wait(1)

	CameraController:Exit(humanoid)

	reEnableAllHitboxes()
end
CameraController.SetupCloseButton(GUIReferences)

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)