local SettingsData = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("MainUI"):WaitForChild("SettingsData"))
local MiscWeld = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("MiscWeld"))
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local total = 0
local v = false

local v2 = {
	DynamicSpeaker = { InitCFrame = CFrame.new(0, 0.785, -0.018), Axis = 3, IntensityMult = 1 },
	S21FX5000 = { InitCFrame = CFrame.new(0, -0.316, 0), Axis = 2, IntensityMult = 0.84 },
	Default = { InitCFrame = CFrame.new(0, 0, 0), Axis = 3, IntensityMult = 1 }
}

local v3 = {}

local function GetNameSpeaker(p) -- 1 equivalent call inferred from this helper
	return p.Parent.Parent.Name
end

local function InitSpeaker(bone)
	local object = MiscWeld.FindObject("SoundPath", bone)

	if not object then
		return
	end

	if not v3[object] then
		local values = object:FindFirstChild("Values")

		if not values then
			return
		end

		v3[object] = {
			SoundPath = object,
			Values = values,
			IsOn = values:GetAttribute("UnivIsOn") or false,
			SpeakerModel = object.SpeakerModel,
			SpeakerGroups = {},
			Conn = nil
		}

		v3[object].Conn = values:GetAttributeChangedSignal("UnivIsOn"):Connect(function()
			if v3[object] then
				v3[object].IsOn = values:GetAttribute("UnivIsOn")
			end
		end)
	end

	local name = GetNameSpeaker(bone) -- inferred equivalent call

	if not v3[object].SpeakerGroups[name] then
		v3[object].SpeakerGroups[name] = {}
	end

	table.insert(v3[object].SpeakerGroups[name], bone)
end

SettingsData.Changed:Connect(function(p, p2, p3)
	if p == "Audio" and p2 == "Speaker Animation" then
		v = p3
	end
end)

RunService.Heartbeat:Connect(function(dt)
	if not v then
		return
	end

	total += dt

	if total > 1000 then
		total = 0
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local position = currentCamera.CFrame.Position

	for _, v4 in pairs(v3) do
		if not v4.IsOn then
			continue
		end

		local boundingBox, _ = v4.SpeakerModel:GetBoundingBox()

		if (position - boundingBox.Position).Magnitude > 50 then
			continue
		end

		local audioIntensity = v4.Values:GetAttribute("AudioIntensity")
		local audioFreq = v4.Values:GetAttribute("AudioFreq")

		if not (audioIntensity and audioFreq) then
			continue
		end

		local v5 = audioIntensity.X * 0.2 * math.sin(6.283185307179586 * audioFreq.X * total)

		for k, list in pairs(v4.SpeakerGroups) do
			local v6 = v2[k] or v2.Default

			local v7 = v5 * v6.IntensityMult
			local vector3

			if v6.Axis == 1 then
				vector3 = Vector3.new(v7, 0, 0)
			elseif v6.Axis == 2 then
				vector3 = Vector3.new(0, v7, 0)
			else
				vector3 = Vector3.new(0, 0, v7)
			end

			local cframe = v6.InitCFrame * CFrame.new(vector3)

			for _, item in ipairs(list) do
				if item and item.Parent then
					item.CFrame = cframe
				end
			end
		end
	end
end)

CollectionService:GetInstanceRemovedSignal("Players_SoundPath"):Connect(function(p)
	if v3[p] then
		if v3[p].Conn then
			v3[p].Conn:Disconnect()
		end

		v3[p] = nil
	end
end)

local function ProcessInstancesProgressively(list)
	for _, bone in ipairs(list) do
		if not (bone:IsA("Bone") and bone.Name == "Leaf") then
			continue
		end

		InitSpeaker(bone)
		task.wait(0.1)
	end
end

local tagged = CollectionService:GetTagged("Speaker_Bone")
task.spawn(ProcessInstancesProgressively, tagged)

CollectionService:GetInstanceAddedSignal("Speaker_Bone"):Connect(function(bone)
	task.defer(function()
		if bone:IsA("Bone") and bone.Name == "Leaf" then
			InitSpeaker(bone)
		end
	end)
end)