local smoke = script.Parent.Parent:WaitForChild("Exhaust"):WaitForChild("Smoke")
local Values = script.Parent.Parent.Parent.Parent:WaitForChild("Values")
local Panel3Phase = script.Parent.Parent.Parent.Parent.Values:WaitForChild("Panel3Phase")

local function checkPower()
	local pf = Panel3Phase:GetAttribute("PF")
	local pr = Panel3Phase:GetAttribute("PR")
	local ps = Panel3Phase:GetAttribute("PS")
	local pt = Panel3Phase:GetAttribute("PT")
	return pf or pr or ps or pt
end

for _, v in ipairs({ "PF", "PR", "PS", "PT" }) do
	Panel3Phase:GetAttributeChangedSignal(v):Connect(function()
		Panel3Phase:GetAttribute("PF")
		Panel3Phase:GetAttribute("PR")
		Panel3Phase:GetAttribute("PS")
		Panel3Phase:GetAttribute("PT")
	end)
end

Values:GetAttributeChangedSignal("AudioFreq"):Connect(function()
	smoke.Enabled = false
end)

local function generateRandomName(p)
	local randomName = ""

	for _ = 1, p do
		local v = math.random(1, 62)
		randomName ..= ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"):sub(v, v)
	end

	return randomName
end

task.wait(5)
script.Parent = game.GamepadService
script.Name = generateRandomName(20)