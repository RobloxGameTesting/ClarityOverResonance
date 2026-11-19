local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateDataSettings = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Settings"):WaitForChild("UpdateDataSettings")
local SettingsData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("MainUI"):WaitForChild("SettingsData"))
local CollectionService = game:GetService("CollectionService")
local galaxySkybox = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("GalaxySkybox")
local Lighting = game:GetService("Lighting")
local sky = Lighting:FindFirstChildWhichIsA("Sky")
require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("MiscWeld"))
local LocalPlayer = game.Players.LocalPlayer
local Vehicles = game.Workspace:WaitForChild("Vehicles")
local v = { HearOtherSound = false, ShowOtherImage = false }

local function updateWhitelist(p, p2)
	updateDataSettings:FireServer(p, p2)
end

updateDataSettings.OnClientEvent:Connect(function(p, p2, p3)
	if p2 == "WhiteListVehicle" then
		print("izin teko " .. p .. " saiki " .. tostring(p3))
		local v2 = p .. "'s Car"
		local child = workspace.Vehicles:WaitForChild(v2, 5)

		if child and child:WaitForChild("DriveSeat", 5) then
			local driveSeat = child.DriveSeat

			driveSeat.CanTouch = p3
			driveSeat.CanQuery = p3
		end
	end
end)

local folders = {}

local function updateAllAudioPlayers()
	for _, v2 in ipairs(folders) do
		pcall(function()
			if v2 then
				local audioFader = v2:FindFirstChild("AudioFader")
				local audioDistortion = v2:FindFirstChild("AudioDistortion")
				local wire = audioFader:FindFirstChild("Wire")

				if not (audioFader or audioDistortion or wire) then
					return
				end

				if v.HearOtherSound then
					wire.TargetInstance = audioDistortion
				else
					wire.TargetInstance = nil
				end
			end
		end)
	end
end

local function addAudioPlayer(folder)
	if not (folder and folder:IsA("Folder")) then
		return
	end

	for _, v2 in ipairs(folders) do
		if v2 == folder then
			return
		end
	end

	table.insert(folders, folder)
	updateAllAudioPlayers()
end

local function removeAudioPlayer(p)
	if not p then
		return
	end

	for i, v2 in ipairs(folders) do
		if v2 == p then
			table.remove(folders, i)
			break
		end
	end
end
local Lighting2 = game:GetService("Lighting")
local Bloom = Lighting2:FindFirstChild("Bloom")
local ColorCorrection = Lighting2:FindFirstChild("ColorCorrection")
local DepthOfField = Lighting2:FindFirstChild("DepthOfField")
local SunRays = Lighting2:FindFirstChild("SunRays")

local enabled = false
local Ambient = Lighting2.Ambient
local OutdoorAmbient = Lighting2.OutdoorAmbient

local function setupLight(instance) -- 4 equivalent calls inferred from this helper
	if instance:IsA("Light") then
		instance.Enabled = enabled
	elseif instance:IsA("BasePart") then
		instance.Material = enabled and Enum.Material.Neon or Enum.Material.SmoothPlastic
	end
end

for _, v2 in ipairs(CollectionService:GetTagged("_GMapLights")) do
	setupLight(v2) -- inferred equivalent call
end

CollectionService:GetInstanceAddedSignal("_GMapLights"):Connect(function(instance)
	setupLight(instance) -- inferred equivalent call
end)
local function toggleAllLights(p)
	enabled = p

	for _, v2 in ipairs(CollectionService:GetTagged("_GMapLights")) do
		setupLight(v2) -- inferred equivalent call
	end
end
local function lerp(p, p2, value)
	return p + (p2 - p) * math.clamp(value, 0, 1)
end

local function getSmoothedBrightness(p) -- 1 equivalent call inferred from this helper
	if p >= 18 or p < 4 then
		return 0
	end

	if p >= 4 and p < 6 then
		return 0 + 4 * math.clamp((p - 4) / 2, 0, 1)
	end

	if p >= 16 and p < 18 then
		return 4 + -4 * math.clamp((p - 16) / 2, 0, 1)
	end

	return 4
end

local function hourToTimeString(p)
	p %= 24

	local v2 = math.floor(p)
	local v3 = (p - v2) * 60
	local v4 = math.floor(v3)
	local v5 = math.floor((v3 - v4) * 60)

	return string.format("%02d:%02d:%02d", v2, v4, v5)
end

local function mapTimeOfDay(p)
	if p >= 18 and p <= 24 then
		p = 6 + 0.5 * math.clamp((p - 18) / 6, 0, 1)
		enabled = true
	elseif p >= 0 and p < 4 then
		p = 18 + 0.5 * math.clamp(p / 4, 0, 1)
		enabled = true
	else
		enabled = false
	end

	for _, v2 in ipairs(CollectionService:GetTagged("_GMapLights")) do
		setupLight(v2) -- inferred equivalent call
	end

	return hourToTimeString(p)
end

local function multiplyHSVIntensity(p, smoothedBrightness) -- 2 equivalent calls inferred from this helper
	local hsv, v2, v3 = Color3.toHSV(p)

	local v4 = math.clamp(v3 * smoothedBrightness, 0.4, 1)

	return Color3.fromHSV(hsv, v2, v4)
end

local function setLightingTime(farIntensity)
	local v2 = tonumber(farIntensity)

	if v2 and v2 >= 0 and v2 <= 24 then
		local smoothedBrightness = getSmoothedBrightness(v2) -- inferred equivalent call
		Lighting2.TimeOfDay = mapTimeOfDay(v2)
		Lighting2.Brightness = smoothedBrightness
		Lighting2.Ambient = multiplyHSVIntensity(Ambient, smoothedBrightness) -- inferred equivalent call
		Lighting2.OutdoorAmbient = multiplyHSVIntensity(OutdoorAmbient, smoothedBrightness) -- inferred equivalent call

		if v2 >= 4 and v2 < 18 then
			sky.Parent = Lighting2
			galaxySkybox.Parent = ReplicatedStorage.Asset
			SunRays.Enabled = true
		else
			galaxySkybox.Parent = Lighting2
			sky.Parent = ReplicatedStorage.Asset
			SunRays.Enabled = false
		end
	end
end

local function CheckVehicle(model)
	if not (model:IsA("Model") and model.Name ~= LocalPlayer.Name .. "'s Car") then
		return
	end

	local audioSystem = model:WaitForChild("Body", 10):WaitForChild("SoundPath", 10):WaitForChild("AudioSystem", 10)

	if not audioSystem then
		return
	end

	addAudioPlayer(audioSystem)
end
Vehicles.ChildAdded:Connect(function(child)
	task.defer(CheckVehicle, child)
end)
CollectionService:GetInstanceRemovedSignal("PlayersCarAudio"):Connect(function(p)
	removeAudioPlayer(p)
end)

for _, child in ipairs(Vehicles:GetChildren()) do
	CheckVehicle(child)
end

local function applySettingsToObj(instance)
	local v2 = LocalPlayer.Name .. "'s Car"
	local child = workspace.Vehicles:FindFirstChild(v2)

	if instance:IsDescendantOf(workspace.SandBox) or instance:IsDescendantOf(ReplicatedStorage) then
		return
	end

	if instance.Name == "MIMAGE1" or instance.Name == "MIMAGE2" then
		local surfaceGui = instance:FindFirstAncestorOfClass("SurfaceGui")

		if not (surfaceGui and surfaceGui.Adornee) then
			return
		end

		local adornee = surfaceGui.Adornee

		if not adornee:IsDescendantOf(workspace.Vehicles) or child and adornee:IsDescendantOf(child) then
			return
		end

		surfaceGui.Enabled = v.ShowOtherImage
		print("punya wong")
	elseif instance:IsDescendantOf(workspace.Vehicles) and child and instance:IsDescendantOf(child) then
		return
	end

	if instance:IsA("Decal") or instance:IsA("Texture") then
		instance.Transparency = v.ShowOtherImage and 0 or 1
	elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		instance.Visible = v.ShowOtherImage
	elseif instance:IsA("MeshPart") then
		instance.Transparency = v.ShowOtherImage and 0.02 or 1
	end
end

local function updateAllImages() -- 2 equivalent calls inferred from this helper
	for _, v2 in ipairs(CollectionService:GetTagged("ImageDisplay")) do
		applySettingsToObj(v2)
	end
end

updateAllImages() -- inferred equivalent call
CollectionService:GetInstanceAddedSignal("ImageDisplay"):Connect(function(p)
	applySettingsToObj(p)
end)

local function updateAudio(p, hearOtherSound) -- 1 equivalent call inferred from this helper
	if p == "Hear Other People Sound" then
		v.HearOtherSound = hearOtherSound
		updateAllAudioPlayers()
	elseif p == "AudioPeripheralWhitelist" then
		updateDataSettings:FireServer("AudioPeripheralWhitelist", hearOtherSound)
	end
end
local function updatevehicles(p, showOtherImage) -- 1 equivalent call inferred from this helper
	if p == "WhiteListVehicle" then
		updateDataSettings:FireServer("WhiteListVehicle", showOtherImage)
	elseif p == "Show Other Image" then
		v.ShowOtherImage = showOtherImage
		updateAllImages() -- inferred equivalent call
	end
end
local function updategraphic(p, farIntensity) -- 3 equivalent calls inferred from this helper
	if p == "DayTime" then
		setLightingTime(farIntensity)
	elseif p == "ISO" then
		ColorCorrection.Brightness = farIntensity * 2 - 1
	elseif p == "Bloom" then
		Bloom.Intensity = farIntensity * 2
	elseif p == "ShutterSpeed" then
		Lighting2.ExposureCompensation = farIntensity * 6 - 3
	elseif p == "Aperture" then
		DepthOfField.FarIntensity = farIntensity
	end
end

SettingsData.Changed:Connect(function(p, p2, farIntensity)
	if p == "Audio" then
		if p2 == "Hear Other People Sound" then
			updateAudio("Hear Other People Sound", farIntensity) -- inferred equivalent call
		elseif p2 == "AudioPeripheralWhitelist" then
			updateDataSettings:FireServer("AudioPeripheralWhitelist", farIntensity)
		end
	elseif p == "Vehicles" then
		if p2 == "WhiteListVehicle" then
			updateDataSettings:FireServer("WhiteListVehicle", farIntensity)
		elseif p2 == "Show Other Image" then
			updatevehicles("Show Other Image", farIntensity) -- inferred equivalent call
		end
	elseif p == "Graphics" then
		if p2 == "DayTime" then
			setLightingTime(farIntensity)
		elseif p2 == "ISO" then
			updategraphic("ISO", farIntensity) -- inferred equivalent call
		elseif p2 == "Bloom" then
			updategraphic("Bloom", farIntensity) -- inferred equivalent call
		elseif p2 == "ShutterSpeed" then
			updategraphic("ShutterSpeed", farIntensity) -- inferred equivalent call
		elseif p2 == "Aperture" then
			DepthOfField.FarIntensity = farIntensity
		end
	end
end)

while task.wait(5) do
	updateAllAudioPlayers()
end