local smoke = game.Workspace.Sound1.PortableGenerator15:WaitForChild("Exhaust"):WaitForChild("Smoke")
local smoke2 = game.Workspace.Sound1.PortableGenerator:WaitForChild("Exhaust"):WaitForChild("Smoke")
local AmplitudeMsc = script.Parent.Values:WaitForChild("AmplitudeMsc")
local MainPower = workspace.Sound1["Electrical Panel 1 PHASE"].Values:WaitForChild("MainPower")

AmplitudeMsc.Changed:Connect(function(p)
	if MainPower.Value == true then
		smoke.Enabled = true
		smoke2.Enabled = true
		local rate = p * 100
		local v = p * 30 + 2

		smoke.Rate = rate
		smoke.Speed = NumberRange.new(v, v)
		smoke2.Rate = rate
		smoke2.Speed = NumberRange.new(v, v)
	else
		smoke.Enabled = false
		smoke2.Enabled = false
	end
end)