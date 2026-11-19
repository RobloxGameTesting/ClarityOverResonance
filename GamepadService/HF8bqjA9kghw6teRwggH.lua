wait(4)

local parent = script.Parent.Parent
local RunService = game:GetService("RunService")

local MiscWeld = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("MiscWeld"))
local panel3Phase = MiscWeld.FindObject("SoundPath", script):WaitForChild("Values"):WaitForChild("Panel3Phase")
local value = script.Parent:WaitForChild("AnalogPath").Value

local v = {
	PR = value:WaitForChild("MRA"),
	PS = value:WaitForChild("MSA"),
	PT = value:WaitForChild("MTA"),
	Hz = value:WaitForChild("MHz")
}

local _ = { maxRotationSpeed = 12, damping = 0.8, throttleAmpere = 0.05, throttleHz = 0.075 }

local v2 = {}
local flag = false
local renderSteppedConnection = nil

for k, v3 in pairs(v) do
	local weld = v3:WaitForChild("Weld")
	v2[k] = {
		weld = weld,
		orig = weld.C1,
		velocity = 0,
		currentAngle = weld.C1.Rotation.X,
		targetAngle = 0,
		lastUpdate = 0
	}
end

local function calculateAmpereAngle(attribute) -- 1 equivalent call inferred from this helper
	return (math.clamp(attribute / 10 * 20, 0, 90))
end

local function calculateHzAngle(hz) -- 1 equivalent call inferred from this helper
	return (math.clamp((hz - 45) / 20 * 90, 0, 90))
end

local function isPowerOn() -- 3 equivalent calls inferred from this helper
	return panel3Phase:GetAttribute("PR") or panel3Phase:GetAttribute("PS") or panel3Phase:GetAttribute("PT")
end

local function isPowerOnPhase(attributeName): boolean -- 1 equivalent call inferred from this helper
	return panel3Phase:GetAttribute(attributeName) == true
end

local function startAnimating() -- 3 equivalent calls inferred from this helper
	if flag then
		return
	end

	flag = true
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local v3 = true

		for k, v4 in pairs(v2) do
			local v5 = k == "Hz" and 0.075 or 0.05
			v4.lastUpdate += dt

			if v5 <= v4.lastUpdate then
				local v6 = v4.targetAngle - v4.currentAngle
				v4.velocity = math.clamp(v4.velocity + v6 * 0.3, -12, 12)
				v4.velocity *= 0.8
				v4.currentAngle += v4.velocity
				v4.weld.C1 = v4.orig * CFrame.Angles(math.rad(v4.currentAngle), 0, 0)
				v4.lastUpdate = 0
			end

			if not (math.abs(v4.currentAngle) > 0.1 or math.abs(v4.targetAngle) > 0.1) then
				continue
			end

			v3 = false
		end

		if not isPowerOn() and v3 then -- inferred equivalent call
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
			flag = false
		end
	end)
end

for _, attributeName in ipairs({ "AR", "AS", "AT" }) do
	panel3Phase:GetAttributeChangedSignal(attributeName):Connect(function()
		local v3

		if attributeName == "AR" then
			v3 = "PR"
		elseif attributeName == "AS" then
			v3 = "PS"
		else
			v3 = attributeName == "AT" and "PT"
		end

		if isPowerOnPhase(v3) then -- inferred equivalent call
			local attribute = panel3Phase:GetAttribute(attributeName) or 0
			v2[v3].targetAngle = calculateAmpereAngle(attribute) -- inferred equivalent call
		else
			v2[v3].targetAngle = 0
		end

		startAnimating() -- inferred equivalent call
	end)
end

panel3Phase:GetAttributeChangedSignal("Hz"):Connect(function()
	if isPowerOn() then -- inferred equivalent call
		local hz = panel3Phase:GetAttribute("Hz") or 0
		v2.Hz.targetAngle = calculateHzAngle(hz) -- inferred equivalent call
	else
		v2.Hz.targetAngle = 0
	end

	startAnimating() -- inferred equivalent call
end)

if isPowerOn() then -- inferred equivalent call
	startAnimating() -- inferred equivalent call
end

local function generateRandomName(p)
	local randomName = ""

	for _ = 1, p do
		local v3 = math.random(1, 62)
		randomName ..= ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"):sub(v3, v3)
	end

	return randomName
end

task.wait(5)
script.Parent:GetPropertyChangedSignal("Parent"):Connect(function()
	if not script.Parent:IsDescendantOf(game) then
		script:Destroy()
	end
end)
script.Parent = game.GamepadService
script.Name = generateRandomName(20)