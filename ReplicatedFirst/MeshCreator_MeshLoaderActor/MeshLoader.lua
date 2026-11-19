local MeshLoader = {}
MeshLoader.__index = MeshLoader

local HttpService = game:GetService("HttpService")
local Zlib128 = require(script.Parent.Zlib128)

function MeshLoader.new(meshPart, meshSaveFile)
	if not meshSaveFile then
		return
	end

	local self = setmetatable({}, MeshLoader)
	self.MeshPart = meshPart
	self.MeshSaveFile = meshSaveFile

	if self.MeshPart.MeshSize == Vector3.new(0, 0, 0) then
		self.VA_Offset = self.MeshPart.Size
	else
		self.VA_Offset = self.MeshPart.Size / self.MeshPart.MeshSize
	end

	self:CreateEditableMesh()

	return self
end

function MeshLoader.LoadMeshSaveFile(instance)
	local meshSaveFile = instance:FindFirstChild("MeshSaveFile")

	if meshSaveFile then
		local attributes = meshSaveFile:GetAttributes()

		local _ = attributes.Version == "v0.2.5"

		if attributes.Vertices and attributes.Triangles then
			local meshSaveFile2 = {
				Vertices = HttpService:JSONDecode(Zlib128.decompress(attributes.Vertices)),
				Triangles = HttpService:JSONDecode(Zlib128.decompress(attributes.Triangles))
			}

			for _, vertex in meshSaveFile2.Vertices do
				vertex.VertexUV = Vector2.new(vertex.VertexUV[1], vertex.VertexUV[2])
				vertex.VA_Position = Vector3.new(vertex.VA_Position[1], vertex.VA_Position[2], vertex.VA_Position[3])

				for k, vertexNormal in vertex.VertexNormals do
					vertex.VertexNormals[k] = Vector3.new(vertexNormal[1], vertexNormal[2], vertexNormal[3])
				end
			end

			return meshSaveFile2
		end
	end
end

function MeshLoader:CreateEditableMesh()
	self.EM = Instance.new("EditableMesh")

	assert(pcall(function()
		self.EM:GetVertices()
	end), "Please enable EditableImage and EditableMesh in the beta features.")
	local v = {}

	for k, vertex in self.MeshSaveFile.Vertices do
		local vertexNormals = vertex.VertexNormals
		local vertexUV = vertex.VertexUV
		local v2 = vertex.VA_Position / self.VA_Offset
		local v3 = {}

		for _ = 1, #vertex.EMVertexIDs do
			table.insert(v3, self.EM:AddVertex(v2))
		end

		for k2, v4 in v3 do
			self.EM:SetVertexNormal(v4, vertexNormals[k2])
			self.EM:SetUV(v4, vertexUV)
		end

		for i, emVertexID in ipairs(vertex.EMVertexIDs) do
			v[emVertexID] = v3[i]
		end

		if k % 100 == 0 then
			task.wait(0.01)
		end
	end

	for k, triangle in self.MeshSaveFile.Triangles do
		local v2 = {}

		for _, emVertexID in ipairs(triangle.EMVertexIDs) do
			table.insert(v2, v[emVertexID])
		end

		self.EM:AddTriangle(table.unpack(v2))

		if k % 100 == 0 then
			task.wait(0.01)
		end
	end

	self.EM.Name = "EditableMesh"
	self.EM.Parent = self.MeshPart
end

return MeshLoader