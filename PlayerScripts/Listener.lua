local Camera = game.Workspace:WaitForChild("Camera")
local audioListener = Instance.new("AudioListener", Camera)
local audioDeviceOutput = Instance.new("AudioDeviceOutput", audioListener)

local wire = Instance.new("Wire", audioDeviceOutput)
local audioAnalyzer = Instance.new("AudioAnalyzer", audioListener)
local wire2 = Instance.new("Wire", audioListener)

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