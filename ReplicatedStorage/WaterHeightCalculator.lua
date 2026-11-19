local WaterHeightCalculator = {}

local RunService = game:GetService("RunService")
local Terrain = game.Workspace:WaitForChild("Terrain")

local function getWavelength() -- 1 equivalent call inferred from this helper
	return math.sqrt(Terrain.WaterWaveSize) * 85
end

local v = time() * Terrain.WaterWaveSpeed
RunService.Stepped:Connect(function(_, dt)
	v += dt * Terrain.WaterWaveSpeed
end)

function WaterHeightCalculator.calcWaterHeightOffset(p, p2)
	if Terrain.WaterWaveSize > 0.02 then
		local wavelength = getWavelength() -- inferred equivalent call
		return math.cos(6.283185307179586 * (p + v) / wavelength) * math.sin(2 * p2 * 3.141592653589793 / wavelength) * (Terrain.WaterWaveSize * 1.94)
	end

	return 0
end

local connection = true
connection = RunService.Stepped:Connect(function()
	connection:Disconnect()
	connection = nil
end)

repeat
	wait()
until not connection

return WaterHeightCalculator