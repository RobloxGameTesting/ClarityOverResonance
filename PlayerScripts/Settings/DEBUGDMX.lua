local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("Debug"):WaitForChild("Iris")).Init()
local v2 = nil
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

game.Workspace.Vehicles.ChildAdded:Connect(function(child)
	local v3 = string.match(child.Name, "^(.-)'s Car$")
	local data = LocalPlayer.Name == v3 and child:WaitForChild("Data", 30)

	if data then
		v2 = data
	end
end)

v:Connect(function()
	local state = v.State(Vector2.new(300, 700))

	v.Window({ "DMX DEBUG TEST" }, { size = state })
	local v3 = {}

	for i = 1, 512 do
		v3[i] = v.State(0)
	end

	v.Tree()

	for i = 1, 512 do
		if not v.SliderNum({
			"Channel " .. i,
			1,
			0,
			255
		}, { number = v3[i] }).numberChanged() then
			continue
		end

		local value = v3[i].value

		local buf = buffer.create(3)
		buffer.writeu16(buf, 0, i)
		buffer.writeu8(buf, 2, value)

		if v2 then
			v2:FireServer(buf)
		end
	end

	v.End()
	v.End()
end)