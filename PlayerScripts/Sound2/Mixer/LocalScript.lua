local MainPower = workspace.Sound2["Electrical Panel 1 PHASE"].Values:WaitForChild("MainPower")

local AmplitudeMsc = script.Parent.Parent.Values.AmplitudeMsc
local ind = workspace.Sound2["Mixer Audio 6 Channel"].IND
local l = ind.L
local r = ind.R
local powerIND = ind:WaitForChild("PowerIND")
wait(3)

local Neon = Enum.Material.Neon
local SmoothPlastic = Enum.Material.SmoothPlastic

local v = { l.PL4, l.PL3, l.PL2, l.PL1, l.PL }

local v2 = { r.PR4, r.PR3, r.PR2, r.PR1, r.PR }

local function updateIndicators(list, value)
	local v3 = math.ceil(value * #list)

	for i = 1, #list do
		if i <= v3 then
			list[i].Material = Neon
		else
			list[i].Material = SmoothPlastic
		end
	end
end

local function updatePowerIndicator() -- 1 equivalent call inferred from this helper
	if MainPower.Value then
		powerIND.Material = Neon
	else
		powerIND.Material = SmoothPlastic
	end
end

MainPower.Changed:Connect(updatePowerIndicator)

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
	if MainPower.Value then
		updateIndicators(v, AmplitudeMsc.Value)
		updateIndicators(v2, AmplitudeMsc.Value)
	else
		for _, v3 in ipairs(v) do
			v3.Material = SmoothPlastic
		end

		for _, v3 in ipairs(v2) do
			v3.Material = SmoothPlastic
		end
	end
end)
updatePowerIndicator() -- inferred equivalent call