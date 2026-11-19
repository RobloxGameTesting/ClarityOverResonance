local parent = script.Parent
local rgb = parent.Left1.RGB
local rgb2 = parent.Left2.RGB
local rgb3 = parent.Right1.RGB
local rgb4 = parent.Right2.RGB
rgb.OffsetStudsU = -0.56
rgb2.OffsetStudsU = 0.56
rgb3.OffsetStudsU = -0.56
rgb4.OffsetStudsU = 0.56

function Move()
	local RunService = game:GetService("RunService")
	RunService.Stepped:Connect(function()
		rgb.OffsetStudsU += 0.04
		rgb2.OffsetStudsU += -0.04

		rgb3.OffsetStudsU += 0.04
		rgb4.OffsetStudsU += -0.04
	end)
end
Move()