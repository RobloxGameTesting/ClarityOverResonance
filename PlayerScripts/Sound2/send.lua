local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateTextBox = ReplicatedStorage:WaitForChild("UpdateTextBox")
local textBox = workspace.Sound2.SongPicker:WaitForChild("Screen"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("TextBox")

textBox.FocusLost:Connect(function(p)
	if p then
		UpdateTextBox:FireServer(textBox.Text, "Sound2")
	end
end)