local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local EpicLights = ReplicatedStorage:WaitForChild("EpicLights")
local Core = require(EpicLights:WaitForChild("Core"))
local Car = require(EpicLights:WaitForChild("Car"))

local v = {}

local function add(instance) -- 1 equivalent call inferred from this helper
	if v[instance] ~= nil then
		return
	end

	v[instance] = false
	task.spawn(function()
		local v2 = os.clock() + 15
		local attribute = instance:GetAttribute(Core.RemoteAttr)

		while not attribute and os.clock() < v2 do
			task.wait(0.25)
			attribute = instance:GetAttribute(Core.RemoteAttr)
		end

		local child = attribute and instance:WaitForChild(attribute, 15)
		local configuration = child and child:WaitForChild("Configuration", 15)

		if v[instance] ~= false then
			return
		end

		if configuration then
			local processor = child:FindFirstChild("Processor")
			local success, result = pcall(function()
				local new = Car.new
				local module = require(configuration)
				return new(instance, module, processor and require(processor))
			end)

			if success then
				v[instance] = result
				return
			end

			v[instance] = nil
			warn("EpicLights // gagal membuat controller " .. instance:GetFullName() .. ": " .. tostring(result))
		else
			v[instance] = nil
			warn("EpicLights // Configuration tidak ditemukan untuk " .. instance:GetFullName())
		end
	end)
end

local function remove(p)
	local v2 = v[p]
	v[p] = nil

	if v2 then
		v2:Destroy()
	end
end

CollectionService:GetInstanceAddedSignal(Core.Tag):Connect(add)
CollectionService:GetInstanceRemovedSignal(Core.Tag):Connect(remove)

for _, v2 in CollectionService:GetTagged(Core.Tag) do
	add(v2) -- inferred equivalent call
end

task.spawn(function()
	EpicLights:WaitForChild(Core.StreamName).OnClientEvent:Connect(function(p, p2)
		local v2 = p and v[p]

		if v2 then
			v2:OnFrame(p2)
		end
	end)
end)

local v2 = 0
RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if now - v2 >= 0.25 then
		v2 = now
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			local position = currentCamera.CFrame.Position

			for _, v3 in v do
				if v3 then
					v3:UpdateLod(position)
				end
			end
		end
	end

	for _, v3 in v do
		if v3 and v3.Active then
			v3:Step(now)
		end
	end
end)