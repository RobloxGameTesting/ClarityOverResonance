local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LensFlare = ReplicatedStorage.LensFlare
local LensFlare2 = require(LensFlare.Modules.LensFlare)
local Configuration = require(LensFlare.Configuration)

local CurrentCamera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local SUN_EXPOSURE_ADJUSTMENT = Configuration.SUN_EXPOSURE_ADJUSTMENT
local SUN_EXPOSURE_TIME = Configuration.SUN_EXPOSURE_TIME

local SUN_BRIGHTNESS_THRESHOLD = Configuration.SUN_BRIGHTNESS_THRESHOLD
local SUN_ANGLE_THRESHOLD = Configuration.SUN_ANGLE_THRESHOLD

local sunFlareTestPart = Instance.new("Part")
sunFlareTestPart.Anchored = true
sunFlareTestPart.CanCollide = false
sunFlareTestPart.CanQuery = false
sunFlareTestPart.CanTouch = false
sunFlareTestPart.Transparency = 0.5
sunFlareTestPart.Size = Vector3.new(1, 1, 1)
sunFlareTestPart.Name = "SunFlareTestPart"
sunFlareTestPart.Parent = workspace

sunFlareTestPart:SetAttribute("LensFlareStrength", 1)

local v = LensFlare2.new(CurrentCamera, "Default", sunFlareTestPart)

local function updateColor() -- 1 equivalent call inferred from this helper
	sunFlareTestPart.Color = Lighting.ColorShift_Top
end

updateColor() -- inferred equivalent call
Lighting:GetPropertyChangedSignal("ColorShift_Top"):Connect(updateColor)

local function updateStrength() -- 1 equivalent call inferred from this helper
	local v2 = math.clamp(Lighting:GetSunDirection().Y * 90 / SUN_ANGLE_THRESHOLD, 0, 1) * math.clamp(
		Lighting.Brightness / SUN_BRIGHTNESS_THRESHOLD,
		0,
		1
	)

	v.Enabled = v2 > 0

	sunFlareTestPart:SetAttribute("LensFlareStrength", v2)
end

updateStrength() -- inferred equivalent call
Lighting:GetPropertyChangedSignal("Brightness"):Connect(updateStrength)
Lighting:GetPropertyChangedSignal("ClockTime"):Connect(updateStrength)

RunService:BindToRenderStep("UpdateLensFlarePart", Enum.RenderPriority.Camera.Value + 9, function()
	sunFlareTestPart.Position = CurrentCamera.CFrame.Position + Lighting:GetSunDirection() * 5000
end)

local v2 = 0
local v3 = 0
RunService:BindToRenderStep("UpdateExposure", Enum.RenderPriority.Camera.Value + 11, function(p: number)
	Lighting.ExposureCompensation -= v2 * SUN_EXPOSURE_ADJUSTMENT
	v2, v3 = TweenService:SmoothDamp(v2, v.Alpha ^ 2, v3, SUN_EXPOSURE_TIME, nil, p)
	Lighting.ExposureCompensation += v2 * SUN_EXPOSURE_ADJUSTMENT
end)

local v4 = {}

for _, instance in CollectionService:GetTagged("LensFlare") do
	if not (instance:IsA("BasePart") or instance:IsA("Attachment") and not v4[instance]) then
		continue
	end

	v4[instance] = LensFlare2.new(CurrentCamera, instance:GetAttribute("LensFlareStyle"), instance)
end

CollectionService:GetInstanceAddedSignal("LensFlare"):Connect(function(instance)
	if instance:IsA("BasePart") or instance:IsA("Attachment") and not v4[instance] then
		v4[instance] = LensFlare2.new(CurrentCamera, instance:GetAttribute("LensFlareStyle"), instance)
	end
end)

CollectionService:GetInstanceRemovedSignal("LensFlare"):Connect(function(p)
	if v4[p] then
		v4[p]:Destroy()
		v4[p] = nil
	end
end)