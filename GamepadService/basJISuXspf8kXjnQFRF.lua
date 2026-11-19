local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Potensio = script.Parent:WaitForChild("Potensio")
local value = Potensio.Value

while not value do
	Potensio.Changed:Wait()
	value = Potensio.Value
end

local RotationMisc = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Physic"):WaitForChild("RotationMisc"))

local PHandler = script.Parent:WaitForChild("PHandler", 10)

local v = {
	{
		hitbox = value:WaitForChild("CHAHitbox"),
		weld = value.CHAHitbox:WaitForChild("Potensio"),
		currentAngle = 0,
		lastDragCF = nil,
		Output = script.Parent.Parent.Values:WaitForChild("OutputCHA", 10)
	},
	{
		hitbox = value:WaitForChild("CHBHitbox"),
		weld = value.CHBHitbox:WaitForChild("Potensio"),
		currentAngle = 0,
		lastDragCF = nil,
		Output = script.Parent.Parent.Values:WaitForChild("OutputCHB", 10)
	},
	{
		hitbox = value:WaitForChild("CHCHitbox"),
		weld = value.CHCHitbox:WaitForChild("Potensio"),
		currentAngle = 0,
		lastDragCF = nil,
		Output = script.Parent.Parent.Values:WaitForChild("OutputCHC", 10)
	},
	{
		hitbox = value:WaitForChild("CHDHitbox"),
		weld = value.CHDHitbox:WaitForChild("Potensio"),
		currentAngle = 0,
		lastDragCF = nil,
		Output = script.Parent.Parent.Values:WaitForChild("OutputCHD", 10)
	}
}

PHandler:FireServer("Start")

for _, v2 in ipairs(v) do
	RotationMisc.initPot(v2, -2.356194490192345, 2.356194490192345, PHandler)
end

PHandler.OnClientEvent:Connect(function(p, numberValue, value2, weld, c1)
	if p == LocalPlayer then
		return
	end

	if numberValue and value2 and weld and c1 then
		if numberValue:IsA("NumberValue") then
			numberValue.Value = tonumber(value2)
		end

		if weld:IsA("Weld") then
			weld.C1 = c1
		end
	end

	if weld and c1 and weld:IsA("Weld") then
		weld.C1 = c1
	end

	if numberValue and typeof(value2) == "number" then
		numberValue.Value = value2
	end
end)

local function generateRandomName(p)
	local randomName = ""

	for _ = 1, p do
		local v2 = math.random(1, 62)
		randomName ..= ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"):sub(v2, v2)
	end

	return randomName
end

task.wait(5)
script.Parent:GetPropertyChangedSignal("Parent"):Connect(function()
	if not script.Parent:IsDescendantOf(game) then
		script:Destroy()
	end
end)
script.Parent = game.GamepadService
script.Name = generateRandomName(20)