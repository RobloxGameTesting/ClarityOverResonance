wait(3)
local UserInputService = game:GetService("UserInputService")
local Motor = game.Workspace.MovingHeadBeam.Base.Motor
local c1 = Motor.C1

local v = 0
local total = 0

local function updateRotation(dt) -- 1 equivalent call inferred from this helper
	total += (v - total) * dt * 8
	local v2 = math.rad(total * dt)

	Motor.C1 *= CFrame.Angles(0, v2, 0)
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		v = 200
	elseif input.KeyCode == Enum.KeyCode.H then
		v = -200
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.H then
		v = 0
	end
end)

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
	updateRotation(dt) -- inferred equivalent call
end)