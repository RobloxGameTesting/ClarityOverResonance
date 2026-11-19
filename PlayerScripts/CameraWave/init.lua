local Camera = game.Workspace:WaitForChild("Camera")
local audioListener = Instance.new("AudioListener", Camera)
local audioDeviceOutput = Instance.new("AudioDeviceOutput", audioListener)

local wire = Instance.new("Wire", audioDeviceOutput)
local audioAnalyzer = Instance.new("AudioAnalyzer", audioListener)
local wire2 = Instance.new("Wire", audioListener)
local amplitudeMusic = Instance.new("NumberValue", audioListener)
amplitudeMusic.Name = "AmplitudeMusic"
local frequencyPeak = Instance.new("NumberValue", audioListener)
frequencyPeak.Name = "FrequencyPeak"

wire.SourceInstance = audioListener
wire.TargetInstance = audioDeviceOutput

wire2.SourceInstance = audioListener
wire2.TargetInstance = audioAnalyzer

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

UserInputService.InputBegan:connect(function(p)
	if
		p.UserInputType == Enum.UserInputType.Keyboard
		and p.KeyCode == Enum.KeyCode.F9
		and LocalPlayer.UserId == not game.CreatorId
	then
		StarterGui:SetCore("DevConsoleVisible", false)
	end
end)
RunService.Heartbeat:Connect(function()
	if LocalPlayer.UserId == not game.CreatorId then
		StarterGui:SetCore("DevConsoleVisible", false)
	end
end)

local RunService2 = game:GetService("RunService")
local CurrentCamera = workspace.CurrentCamera

local WavyCameraFX = script:WaitForChild("WavyCameraFX")

local clones = {}

for _ = 1, 5 do
	local clone = WavyCameraFX:Clone()
	clone.Parent = CurrentCamera
	table.insert(clones, clone)
end

local function mapFrequencyToScale(value) -- 1 equivalent call inferred from this helper
	return 100 + -60 * ((math.clamp(value, 20, 100) - 20) / 80)
end

local v = 0
RunService2.RenderStepped:Connect(function(dt)
	local value = frequencyPeak.Value
	local value2 = amplitudeMusic.Value
	local v2 = mapFrequencyToScale(value) -- inferred equivalent call
	local v3 = 1 + value2 * 1

	if value2 > 0 then
		v = (v + 10 * dt) % 100
	end

	for i, part in ipairs(clones) do
		local v4 = i * 0 - v

		part.CFrame = CurrentCamera.CFrame * CFrame.new(0, v4, -10)

		if part:IsA("BasePart") then
			part.Size = Vector3.new(v3, v2, 1)
		elseif part:FindFirstChild("Handle") then
			part.Handle.Size = Vector3.new(v3, v2, 1)
		end
	end
end)