local MiscWeld = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("MiscWeld"))
local parent = script.Parent.Parent
local RunService = game:GetService("RunService")
wait(3)

local object = MiscWeld.FindObject("SoundPath", script)
local audioAnalyzer = object:WaitForChild("AudioSystem"):WaitForChild("AudioAnalyzer")
parent:WaitForChild("Values")
local values = object:WaitForChild("Values")
local panel3Phase = values:WaitForChild("Panel3Phase")
local audioFader = object:WaitForChild("AudioSystem"):WaitForChild("AudioFader")

local hz = panel3Phase:GetAttribute("Hz")

local v = hz
local v2 = hz

local v3 = 0

local v4 = 23.4
local function weightFunc(p) -- 1 equivalent call inferred from this helper
	if p <= 65 then
		return math.log(p - 20 + 1) / 3.828641396489095
	end

	return (math.exp(-0.01 * (p - 65)))
end

local function indexToHz(i) -- 1 equivalent call inferred from this helper
	return i * v4
end

audioAnalyzer:GetPropertyChangedSignal("WindowSize"):Connect(function()
	if audioAnalyzer.WindowSize == Enum.AudioWindowSize.Large then
		v4 = 8
	elseif audioAnalyzer.WindowSize == Enum.AudioWindowSize.Medium then
		v4 = 23.4
	elseif audioAnalyzer.WindowSize == Enum.AudioWindowSize.Small then
		v4 = 50
	end
end)

RunService.Heartbeat:Connect(function(dt)
	local spectrum = audioAnalyzer:GetSpectrum(128)
	local total = 0
	local count = 0
	local v5 = 0
	local total2 = 0
	local count2 = 0
	local total3 = 0
	local count3 = 0
	local v6 = 0

	for i, v7 in ipairs(spectrum) do
		local v8 = indexToHz(i) -- inferred equivalent call

		if v8 >= 20 and v8 <= 200 then
			local v9 = v7 * weightFunc(v8) -- inferred equivalent call

			total += v9
			count += 1

			if v5 < v9 then
				v6 = v8
				v5 = v9
			end
		elseif v8 >= 400 and v8 <= 10000 then
			total2 += v7
			count2 += 1
		elseif v8 >= 10000 and v8 <= 20000 then
			total3 += v7
			count3 += 1
		end
	end

	local v7 = count > 0 and total / count or 0
	local v8 = count2 > 0 and total2 / count2 or 0
	local v9 = count3 > 0 and total3 / count3 or 0

	if v7 - v3 > 0.3 then
		v7 *= 2
	end

	v3 = v7

	values:SetAttribute("AudioIntensity", (Vector3.new(v7 * 3, v8 * 35, v9)))
	values:SetAttribute("AudioFreq", (Vector3.new(v6, 0, 0)))
	panel3Phase:SetAttribute("AF", v7)
	panel3Phase:SetAttribute("AR", v7 * 90 * audioFader.Volume)
	panel3Phase:SetAttribute("AS", v7 * 84 * audioFader.Volume)
	panel3Phase:SetAttribute("AT", v8 * 150 * audioFader.Volume)

	local v10 = v7 * 12
	v = math.max(hz - v10, 40)

	if math.abs(v2 - v) > 0.01 then
		v2 += (v - v2) * dt * 1.5
		panel3Phase:SetAttribute("Hz", v2)
	end
end)

task.wait(5)
script.Parent = game.GamepadService
script.Parent:GetPropertyChangedSignal("Parent"):Connect(function()
	if not script.Parent:IsDescendantOf(game) then
		script:Destroy()
	end
end)
script.Name = MiscWeld.generateRandomName(20)