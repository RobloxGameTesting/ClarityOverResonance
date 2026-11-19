local wavyCameraFX = game.ReplicatedStorage:WaitForChild("WavyCameraFX")
wavyCameraFX.Parent = game.Workspace

local CurrentCamera = game.Workspace.CurrentCamera
local WavyCameraFX = game.Workspace:WaitForChild("WavyCameraFX")

CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
	WavyCameraFX.CFrame = CurrentCamera.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
end)