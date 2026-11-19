local SettingsData = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("MainUI"):WaitForChild("SettingsData"))
local CollectionService = game:GetService("CollectionService")
local Camera = game.Workspace:WaitForChild("Camera")
local audioListener = Instance.new("AudioListener", Camera)
local audioDeviceOutput = Instance.new("AudioDeviceOutput", audioListener)
local audioFader = Instance.new("AudioFader", audioListener)
local wire = Instance.new("Wire", audioListener)
local wire2 = Instance.new("Wire", audioListener)
wire.SourceInstance = audioListener
wire.TargetInstance = audioFader

wire2.SourceInstance = audioFader
wire2.TargetInstance = audioDeviceOutput
local audioAnalyzer = Instance.new("AudioAnalyzer", audioListener)
local wire3 = Instance.new("Wire", audioListener)
wire3.SourceInstance = audioListener
wire3.TargetInstance = audioAnalyzer

local audioAnalyzers = {}
local RunService = game:GetService("RunService")
local heartbeatConnection = nil
local v = 23.4

local v2 = 0

local v3 = 0.1
local v4 = false
local v5 = false
local function indexToHz(p) -- 4 equivalent calls inferred from this helper
	return p * v
end

local function weightFunc(p) -- 3 equivalent calls inferred from this helper
	if p <= 65 then
		return math.log(p - 20 + 1) / 3.828641396489095
	end

	return (math.exp(-0.01 * (p - 65)))
end

local total = 0
local Blur = game.Lighting:WaitForChild("Blur")
local v6 = {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil
}
v6[1], v6[2], v6[3], v6[4], v6[5], v6[6], v6[7], v6[8], v6[9] = 1, 0, 0, 0, 1, 0, 0, 0, 1
local cframe = nil

local function CalculateDistortion(p, p2, p3)
	total += p3
	local v7 = math.clamp(0 + v3 * p * math.sin(6.283185307179586 * p2 * 2 * total), -1, 1)
	Blur.Size = math.min(15, p * p2 * v3 * 2)

	if v4 then
		v6 = {
			1,
			0,
			v7,
			0,
			1,
			0,
			0,
			0,
			1
		}
	else
		v6 = {
			1,
			0,
			0,
			0,
			1,
			v7,
			0,
			0,
			1
		}
	end
end
local function UpdateAnalyzer(dt)
	local spectrum = audioAnalyzer:GetSpectrum()
	local total2 = 0
	local count = 0
	local v7 = 0
	local v8 = 0

	for i, v9 in ipairs(spectrum) do
		local v10 = indexToHz(i) -- inferred equivalent call

		if not (v10 >= 20 and v10 <= 200) then
			continue
		end

		local v11 = v9 * weightFunc(v10) -- inferred equivalent call

		total2 += v11
		count += 1

		if not (v7 < v11) then
			continue
		end

		v8 = i
		v7 = v11
	end

	local v9

	if v8 > 0 then
		local v10 = 0
		local v11

		if v8 > 1 then
			local v12 = indexToHz(v8 - 1) -- inferred equivalent call
			v11 = spectrum[v8 - 1] * weightFunc(v12) -- inferred equivalent call
		else
			v11 = 0
		end

		if v8 < #spectrum then
			local v12 = indexToHz(v8 + 1) -- inferred equivalent call
			v10 = spectrum[v8 + 1] * weightFunc(v12) -- inferred equivalent call
		end

		local v12 = v11 - v7 * 2 + v10

		local v13 = v12 == 0 and 0 or (v11 - v10) * 0.5 / v12

		v9 = indexToHz(v8 + v13) -- inferred equivalent call

		local _ = v7 - (v11 - v10) * 0.25 * v13
	else
		v9 = 0
	end

	local v10 = count > 0 and total2 / count or 0

	if v10 - v2 > 0.3 then
		v10 *= 2
	end

	v2 = v10

	audioAnalyzer:SetAttribute("AudioIntensity", Vector2.new(v10 * 2, v9))
	CalculateDistortion(v10 * 2, v9, dt)
end
local function setDistortionState(p)
	if v5 == p then
		return
	end

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if p then
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			UpdateAnalyzer(dt)
		end)
	else
		v6 = {
			1,
			0,
			0,
			0,
			1,
			0,
			0,
			0,
			1
		}
		Blur.Size = 0
	end

	v5 = p
end
SettingsData.Changed:Connect(function(p, p2, p3)
	if p == "Audio" then
		if p2 == "Camera Distortion" then
			setDistortionState(p3)
		elseif p2 == "Main Volume" then
			audioFader.Volume = p3 * 3
		elseif p2 == "Distortion Intensity" then
			v3 = p3
		elseif p2 == "Swap Distortion Orientation" then
			v4 = p3
		elseif p2 == "AudioAnalyzer Camera Quality" then
			if p3 == 0 then
				audioAnalyzer.WindowSize = Enum.AudioWindowSize.Small
				v = 50
			elseif p3 == 0.5 then
				audioAnalyzer.WindowSize = Enum.AudioWindowSize.Medium
				v = 23.4
			elseif p3 == 1 then
				audioAnalyzer.WindowSize = Enum.AudioWindowSize.Large
				v = 8
			end
		elseif p2 == "AudioAnalyzer System Quality" then
			for _, v7 in ipairs(audioAnalyzers) do
				if not v7:IsDescendantOf(workspace) then
					continue
				end

				local windowSize = p3 == 0 and Enum.AudioWindowSize.Small or p3 == 0.5 and Enum.AudioWindowSize.Medium

				if not windowSize then
					if p3 == 1 then
						windowSize = Enum.AudioWindowSize.Large
					else
						windowSize = false
					end
				end

				v7.WindowSize = windowSize
			end
		end
	end
end)
local function preDistortCamera()
	if cframe then
		workspace.CurrentCamera.CFrame = cframe
	end
end

local function applyDistortCamera()
	local currentCamera = workspace.CurrentCamera
	cframe = currentCamera.CFrame
	currentCamera.CFrame *= CFrame.new(0, 0, 0, unpack(v6))
end
local function addAudioAQ(audioAnalyzer2) -- 2 equivalent calls inferred from this helper
	if not audioAnalyzer2:IsA("AudioAnalyzer") then
		return
	end

	for _, v7 in ipairs(audioAnalyzers) do
		if v7 == audioAnalyzer2 then
			return
		end
	end

	table.insert(audioAnalyzers, audioAnalyzer2)
end
local function RemoveAudioAQ(p)
	for i, v7 in ipairs(audioAnalyzers) do
		if v7 == p then
			table.remove(audioAnalyzers, i)
			break
		end
	end
end
CollectionService:GetInstanceAddedSignal("AudioAnalyzerQuality"):Connect(function(audioAnalyzer2)
	addAudioAQ(audioAnalyzer2) -- inferred equivalent call
end)
CollectionService:GetInstanceRemovedSignal("AudioAnalyzerQuality"):Connect(function(p)
	RemoveAudioAQ(p)
end)

for _, v7 in ipairs(CollectionService:GetTagged("VTCustom")) do
	addAudioAQ(v7) -- inferred equivalent call
end

RunService:BindToRenderStep("PreDistort", 199, preDistortCamera)
RunService:BindToRenderStep("DistortCamera", 201, applyDistortCamera)