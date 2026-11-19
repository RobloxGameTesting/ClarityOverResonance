wait(5)
local audioAnalyzer = game.Workspace.Sound1["Mixer Audio 6 Channel"].Channel.Channel1:WaitForChild("Audio"):WaitForChild("AudioAnalyzer")
local electricalPanel1PHASE = game.Workspace.Sound1:WaitForChild("Electrical Panel 1 PHASE")
local ampereValue = electricalPanel1PHASE.Values:WaitForChild("AmpereValue")
local hzValue = electricalPanel1PHASE.Values:WaitForChild("HzValue")
local voltValue = electricalPanel1PHASE.Values:WaitForChild("VoltValue")
local RunService = game:GetService("RunService")
local value = hzValue.Value
local value2 = voltValue.Value

RunService.Heartbeat:Connect(function()
	local spectrum = audioAnalyzer:GetSpectrum(2)
	local v = 0
	local v2 = nil

	for i, v3 in ipairs(spectrum) do
		if not (v < v3) then
			continue
		end

		v2 = i
		v = v3
	end

	if not v2 then
		ampereValue.Value = 0

		return
	end

	script.Parent.Values.AmplitudeMsc.Value = v
	ampereValue.Value = v * script.Sensitivity.Value
	hzValue.Value = value - v * 12
	voltValue.Value = value2 - v * 3
end)