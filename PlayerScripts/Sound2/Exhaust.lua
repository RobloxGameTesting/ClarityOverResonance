local smoke = game.Workspace.Sound2.PortableGenerator:WaitForChild("Exhaust"):WaitForChild("Smoke")
local AmplitudeMsc = script.Parent.Values:WaitForChild("AmplitudeMsc")
local MainPower = workspace.Sound2["Electrical Panel 1 PHASE"].Values:WaitForChild("MainPower")

AmplitudeMsc.Changed:Connect(function(p)
	if MainPower.Value ~= true then
		smoke.Enabled = false

		return
	end

	smoke.Enabled = true
	local rate = p * 100
	local v = p * 20 + 4

	smoke.Rate = rate
	smoke.Speed = NumberRange.new(v, v)
end)