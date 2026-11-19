local electricalPanel1PHASE = game.Workspace.Sound2["Electrical Panel 1 PHASE"]
local voltValue = electricalPanel1PHASE.Values:WaitForChild("VoltValue")
local weld = electricalPanel1PHASE.AnalogMeter:WaitForChild("MV"):WaitForChild("Weld")
local c1 = weld.C1
local mainPower = electricalPanel1PHASE.Values:WaitForChild("MainPower")

local v = 0
local x = weld.C1.Rotation.X
local v2 = 0

local voltDigital = electricalPanel1PHASE.DigitalMeter:WaitForChild("VoltDigital")

local sd1 = voltDigital:WaitForChild("SD1")
local sd2 = voltDigital:WaitForChild("SD2")
local sd3 = voltDigital:WaitForChild("SD3")

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
		local v5 = math.floor(v4 / 100) % 10
		local v6 = math.floor(v4 / 10) % 10
		local v7 = v4 % 10

		setSegmentDisplay(sd1, v5, true)
		setSegmentDisplay(sd2, v6, true)
		setSegmentDisplay(sd3, v7, true)
	else
		setSegmentDisplay(sd1, nil, false)
		setSegmentDisplay(sd2, nil, false)
		setSegmentDisplay(sd3, nil, false)
	end
end

local function calculateAngle(p)
	local v4 = {
		{ voltage = 0, angle = 0 },
		{ voltage = 100, angle = 15 },
		{ voltage = 200, angle = 60 },
		{ voltage = 300, angle = 90 }
	}

	if p <= v4[1].voltage then
		return v4[1].angle
	end

	if v4[#v4].voltage <= p then
		return v4[#v4].angle
	end

	for i = 1, #v4 - 1 do
		local v5 = v4[i]
		local v6 = v4[i + 1]

		if v5.voltage <= p and p <= v6.voltage then
			local v7 = (p - v5.voltage) / (v6.voltage - v5.voltage)
			return v5.angle + v7 * (v6.angle - v5.angle)
		end
	end
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

voltValue.Changed:Connect(function()
	updateSSD(voltValue.Value)
end)

mainPower.Changed:Connect(function()
	updateSSD(voltValue.Value)

	if not mainPower.Value then
		v2 = 0
	end

	if mainPower.Value then
		v2 = calculateAngle(voltValue.Value)
	end
end)

voltValue.Changed:Connect(function(p)
	if mainPower.Value then
		v2 = calculateAngle(p)
	end
end)