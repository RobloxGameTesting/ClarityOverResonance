local electricalPanel1PHASE = game.Workspace.Sound1["Electrical Panel 1 PHASE"]
local ampereValue = electricalPanel1PHASE.Values:WaitForChild("AmpereValue")
local weld = electricalPanel1PHASE.AnalogMeter:WaitForChild("MA"):WaitForChild("Weld")
local c1 = weld.C1
local mainPower = electricalPanel1PHASE.Values:WaitForChild("MainPower")

local v = 0
local x = weld.C1.Rotation.X
local v2 = 0

local ampDigital = electricalPanel1PHASE.DigitalMeter:WaitForChild("AmpDigital")

local sd1 = ampDigital:WaitForChild("SD1")
local sd2 = ampDigital:WaitForChild("SD2")
local sd3 = ampDigital:WaitForChild("SD3")
local titik = ampDigital:WaitForChild("Titik")

local v3 = {
	[0] = { "D1", "D2", "D3", "D4", "D5", "D6" },
	[1] = { "D2", "D3" },
	[2] = { "D1", "D2", "D7", "D5", "D4" },
	[3] = { "D1", "D2", "D7", "D3", "D4" },
	[4] = { "D2", "D7", "D6", "D3" },
	[5] = { "D1", "D6", "D7", "D3", "D4" },
	[6] = { "D1", "D6", "D7", "D3", "D4", "D5" },
	[7] = { "D1", "D2", "D3" },
	[8] = { "D1", "D2", "D3", "D4", "D5", "D6", "D7" },
	[9] = { "D1", "D2", "D3", "D4", "D6", "D7" }
}

local function setSegmentDisplay(instance, p, p2)
	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		if p2 then
		end

		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.new(0, 0, 0)
	end

	local v4 = p2 and v3[p]

	if v4 then
		for _, childName in ipairs(v4) do
			local child = instance:FindFirstChild(childName)

			if not child then
				continue
			end

			child.Material = Enum.Material.Neon
			child.Color = Color3.new(1, 1, 1)
		end
	end
end

local function updateSSD(value)
	if mainPower.Value then
		local v4 = math.floor(value)
		local v5 = math.floor(value * 10 % 10 + 0.5)

		local v6 = math.floor(v4 / 10) % 10
		local v7 = v4 % 10

		setSegmentDisplay(sd1, v6, true)
		setSegmentDisplay(sd2, v7, true)
		setSegmentDisplay(sd3, v5, true)

		if titik then
			titik.Material = Enum.Material.Neon
			titik.Color = Color3.new(1, 1, 1)
		else
			titik.Material = Enum.Material.SmoothPlastic
			titik.Color = Color3.new(0, 0, 0)
		end
	else
		setSegmentDisplay(sd1, nil, false)
		setSegmentDisplay(sd2, nil, false)
		setSegmentDisplay(sd3, nil, false)

		if titik then
			titik.Material = Enum.Material.SmoothPlastic
			titik.Color = Color3.new(0, 0, 0)
		end
	end
end

local function calculateAngle(p) -- 2 equivalent calls inferred from this helper
	return (math.clamp(p / 10 * 20, 0, 90))
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(_)
	local v4 = v2 - x

	v += v4 * 0.3
	v = math.clamp(v, -12, 12)

	v *= 0.8

	x += v

	weld.C1 = c1 * CFrame.Angles(math.rad(x), 0, 0)
end)

ampereValue.Changed:Connect(function()
	updateSSD(ampereValue.Value)
end)

mainPower.Changed:Connect(function()
	updateSSD(ampereValue.Value)

	if not mainPower.Value then
		v2 = 0
	end

	if mainPower.Value then
		v2 = calculateAngle(ampereValue.Value) -- inferred equivalent call
	end
end)

local count = 0

ampereValue.Changed:Connect(function(p)
	count += 1

	if count > 450 then
		if mainPower.Value then
			v2 = calculateAngle(p) -- inferred equivalent call
		end

		count = 0
	end
end)