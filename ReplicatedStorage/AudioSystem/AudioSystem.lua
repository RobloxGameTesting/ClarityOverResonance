game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local AudioSystem = {}
AudioSystem.__index = AudioSystem

local allGroups = {}

local function generateGroupId(audioPlayer) -- 1 equivalent call inferred from this helper
	if typeof(audioPlayer) == "Instance" then
		return audioPlayer:GetDebugId()
	end

	return HttpService:GenerateGUID(false)
end

local function warnf(formatString, ...)
	warn("[AudioSystem] " .. string.format(formatString, ...))
end

local class = {}
class.__index = class

function class.new(mixerModel)
	local self = setmetatable({}, class)

	self.mixerModel = mixerModel
	self.output = 1

	if mixerModel then
		self:_bindOutputValue()
	end

	return self
end

function class:_bindOutputValue()
	local mainFader = self.mixerModel:GetAttribute("MainFader")

	if mainFader then
		self.output = math.clamp(mainFader, 0, 1)
		return
	end

	warnf("MixerLogic: MainFader not found, using unity gain (1)")
	self.output = 1
end

function class:Destroy()
	self.mixerModel = nil
end
function class:GetOutput()
	return self.output
end

local class2 = {}
class2.__index = class2

function class2.new(amplifiers)
	local self = setmetatable({}, class2)

	self.amplifiers = amplifiers
	self.outputList = {}
	self.channels = {}
	self.powerCapacity = 1
	self.energyDemand = 0
	self.powerUsage = 0
	self.isProtect = false
	self.unifiedSignal = 0
	self.rawIntensity = 0
	self._connections = {}

	self:_bind()
	return self
end

function class2:_recalculate()
	local total = 0
	local count = #self.outputList

	if count == 0 then
		self.energyDemand = 0
		self.powerUsage = 0
		self.isProtect = false
	else
		for _, channel in ipairs(self.channels) do
			total += math.clamp(channel.Value, 0, 1)
		end

		self.energyDemand = total / count * self.unifiedSignal + self.rawIntensity * 0.2
		self.isProtect = self.energyDemand > self.powerCapacity
		self.powerUsage = math.clamp(self.energyDemand / self.powerCapacity, 0, 1)
	end
end

function class2:_bind()
	if not self.amplifiers then
		return
	end

	local v, v2

	if self.amplifiers.Parent:FindFirstChild("Values") then
		v = self.amplifiers.Parent.Values:GetAttribute("PowerCapacity")
		v2 = self.amplifiers.Parent.Values:GetAttribute("WattNeeded")
	else
		v2 = 0
		v = 0
	end

	self.powerCapacity = v2 > 0 and v / v2 or 1
	self.channels = {}

	for _, child in ipairs(self.amplifiers:GetChildren()) do
		local values = child:FindFirstChild("Body") and child.Body:FindFirstChild("Values")
		local ind = child:FindFirstChild("Body") and child.Body:FindFirstChild("Ind")

		if not (values and ind) then
			continue
		end

		self.channels[child] = {}

		for _, model in ipairs(ind:GetChildren()) do
			if not model:IsA("Model") then
				continue
			end

			local child2 = values:FindFirstChild("Output" .. model.Name)

			local v3 = {
				Output = child2,
				active = values:FindFirstChild("Power"),
				protect = values:FindFirstChild("Protect"),
				activeIND = model:FindFirstChild("Active"),
				protectIND = model:FindFirstChild("Protect"),
				steps = {}
			}

			if child2 then
				table.insert(self.outputList, child2)
			end

			for _, child3 in ipairs(model:GetChildren()) do
				if child3.Name:match("^S%d+") then
					table.insert(v3.steps, child3)
				end
			end

			table.sort(v3.steps, function(a, b): boolean
				return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
			end)

			self.channels[child][model.Name] = v3
		end
	end
end
function class2:GetChannels()
	return self.channels
end

function class2:GetFinalVolume()
	return self.powerUsage
end

function class2:GetPowerUsage()
	return self.powerUsage
end

function class2:Update(unifiedSignal, rawIntensity)
	self.unifiedSignal = unifiedSignal
	self.rawIntensity = rawIntensity
	self:_recalculate()
end
function class2:Destroy()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._connections = {}
	self.channels = {}
end

local class3 = {}
class3.__index = class3

function class3.new(amplifiers, powerLogic)
	local self = setmetatable({}, class3)

	self.amplifiers = amplifiers
	self.powerLogic = powerLogic
	self.channels = {}
	self._connections = {}
	self.outputList = {}

	return self
end

function class3:Update()
	local powerUsage = self.powerLogic:GetPowerUsage()
	self.channels = self.powerLogic:GetChannels()

	for _, channel in pairs(self.channels) do
		for _, v in pairs(channel) do
			if v.active and v.activeIND then
				local value = v.active.Value
				v.activeIND.Material = value and Enum.Material.Neon or Enum.Material.Plastic
				v.activeIND.Transparency = value and 0 or 0.6
			end

			if v.protect and v.protectIND then
				local value = v.protect.Value
				v.protectIND.Material = value and Enum.Material.Neon or Enum.Material.Plastic
				v.protectIND.Transparency = value and 0 or 0.7
			end

			local v2 = math.floor(powerUsage * #v.steps + 0.5)

			for i, step in ipairs(v.steps) do
				local v3

				if i <= v2 then
					v3 = v.active.Value and not v.protect.Value
				else
					v3 = false
				end

				step.Material = v3 and Enum.Material.Neon or Enum.Material.Plastic
				step.Transparency = v3 and 0 or 0.7
			end
		end
	end
end
function class3:Destroy()
	self.channels = {}
	self._connections = {}
end

local class4 = {}
class4.__index = class4

function class4.new(data)
	assert(typeof(data) == "table", "AudioGroupState.new params must be table")

	local object = setmetatable({}, class4)

	object.id = data.id
	object.audioPlayer = data.audioPlayer
	object.analyzer = data.analyzer
	object.mixerModel = data.mixerModel
	object.amplifiers = data.amplifiers
	object.speakers = data.speakers

	object.running = false
	object._accum = 0

	object.unifiedSignal = 0
	object.rawIntensity = 0
	object.effectiveIntensity = 0

	object.mixerLogic = class.new(object.mixerModel)
	object.powerLogic = class2.new(object.amplifiers)
	object.indicatorLogic = class3.new(object.amplifiers, object.powerLogic)

	return object
end

function class4:Start()
	if self.running then
		return
	end

	self.running = true

	self._conn = RunService.RenderStepped:Connect(function(dt)
		self:_update(dt)
	end)
end

function class4:Destroy()
	self.running = false

	if self._conn then
		self._conn:Disconnect()
		self._conn = nil
	end

	if self.mixerLogic then
		self.mixerLogic:Destroy()
	end

	if self.powerLogic then
		self.powerLogic:Destroy()
	end

	if self.indicatorLogic then
		self.indicatorLogic:Destroy()
	end
end

function class4:_update(p)
	self._accum += p

	if self._accum < 1 / 24 then
		return
	end

	self._accum -= 1 / 24
	local audioIntensity = self.analyzer:GetAttribute("AudioIntensity")
	self.rawIntensity = typeof(audioIntensity) == "number" and audioIntensity or 0

	self.unifiedSignal = self.mixerLogic:GetOutput()

	self.powerLogic:_recalculate(self.unifiedSignal, self.rawIntensity)

	if self.audioPlayer then
		self.audioPlayer.Volume = self.powerLogic:GetFinalVolume()
	end

	self.indicatorLogic:Update()
end

function AudioSystem.CreateGroup(data)
	assert(typeof(data) == "table", "CreateGroup params must be table")

	local id = data.GroupId or generateGroupId(data.AudioPlayer) -- inferred equivalent call

	if allGroups[id] then
		warnf("Group %s already exists", id)
		return allGroups[id]
	end

	if not (data.AudioPlayer and data.Analyzer and data.AmplifierModels) then
		return nil
	end

	local v = class4.new({
		id = id,
		audioPlayer = data.AudioPlayer,
		analyzer = data.Analyzer,
		mixerModel = data.MixerModel,
		amplifiers = data.AmplifierModels,
		speakers = data.SpeakerModels
	})

	allGroups[id] = v
	v:Start()

	return v
end

function AudioSystem.DestroyGroup(p)
	local v = allGroups[p]

	if not v then
		return
	end

	v:Destroy()
	allGroups[p] = nil
end

function AudioSystem.GetGroup(p)
	return allGroups[p]
end

function AudioSystem.GetAllGroups()
	return allGroups
end

return AudioSystem