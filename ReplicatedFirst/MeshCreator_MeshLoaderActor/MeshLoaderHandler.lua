local RunService = game:GetService("RunService")
local MeshLoader = require(script.Parent.MeshLoader)

function OnMeshAdded(part)
	if part:IsA("MeshPart") then
		LoadMesh(part)
	end
end

function OnMeshSaveFileAdded(p)
	if p.Name == "MeshSaveFile" then
		LoadMeshFromMeshSaveFile(p)
	end
end

function LoadMesh(instance)
	if instance:FindFirstChildOfClass("EditableMesh") then
		instance:FindFirstChildOfClass("EditableMesh"):Destroy()
	end

	MeshLoader.new(instance, MeshLoader.LoadMeshSaveFile(instance))

	instance.ChildAdded:Connect(OnMeshSaveFileAdded)
end

function LoadMeshFromMeshSaveFile(p)
	local parent = p.Parent

	if parent:FindFirstChildOfClass("EditableMesh") then
		parent:FindFirstChildOfClass("EditableMesh"):Destroy()
	end

	MeshLoader.new(parent, MeshLoader.LoadMeshSaveFile(parent))
end

if RunService:IsRunning() and not plugin then
	workspace.DescendantAdded:Connect(OnMeshAdded)
elseif RunService:IsEdit() and plugin then
	for _, descendant in workspace:GetDescendants() do
		OnMeshAdded(descendant)
	end

	workspace.DescendantAdded:Connect(OnMeshAdded)
end