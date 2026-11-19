wait(3)
local UserInputService = game:GetService("UserInputService")
local Motor = game.Workspace.MovingHeadBeam.Support.HIngeHead2.Motor

local v = 0
local total = 0

local function updateRotation(dt) -- 1 equivalent call inferred from this helper
	total += (v - total) * dt * 8
	local v2 = math.rad(total * dt)

	Motor.C1 *= CFrame.Angles(0, 0, v2)
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.T then
		v = 200
	elseif input.KeyCode == Enum.KeyCode.G then
		v = -200
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.T or input.KeyCode == Enum.KeyCode.G then
		v = 0
	end
end)

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(dt)
	updateRotation(dt) -- inferred equivalent call
end)