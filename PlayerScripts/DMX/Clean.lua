local Workspace = game:GetService("Workspace")
local Vehicles = Workspace:WaitForChild("Vehicles")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DMXManager = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DMX_Lighting"):WaitForChild("DMXManager"))
local function cleanup(model)
	if model:IsA("Model") then
		print("cleaning up", model)
		DMXManager.CleanUp(model.Name)
	end
end
Vehicles.ChildRemoved:Connect(cleanup)