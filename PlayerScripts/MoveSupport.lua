local RemoteEvent = workspace.MovingHeadBeam.RemoteEvent
wait(3)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		RemoteEvent:FireServer("Move", "Up")
	elseif input.KeyCode == Enum.KeyCode.H then
		RemoteEvent:FireServer("Move", "Down")
	elseif input.KeyCode == Enum.KeyCode.T then
		RemoteEvent:FireServer("Move", "Left")
	elseif input.KeyCode == Enum.KeyCode.G then
		RemoteEvent:FireServer("Move", "Right")
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.H then
		RemoteEvent:FireServer("Move", "Stop1")
	elseif input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.T then
		RemoteEvent:FireServer("Move", "Stop2")
	end
end)