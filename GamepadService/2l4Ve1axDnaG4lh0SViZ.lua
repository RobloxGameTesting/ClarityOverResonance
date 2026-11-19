local Remote = script.Parent:WaitForChild("Remote")

local value = Remote.Value

while not value do
	Remote.Changed:Wait()
	value = Remote.Value
end

local textBox = script.Parent.Parent.Parent:WaitForChild("BoundingBox"):WaitForChild("SurfaceGui"):WaitForChild("Frame"):WaitForChild("TextBox")

textBox.FocusLost:Connect(function()
	value:FireServer(textBox.Text, "Truck")
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