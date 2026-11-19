local RunService = game:GetService("RunService")

local class = {}
class.__index = class
class.ClassName = "MasterClock"

function class.new(p, p2)
	local object = setmetatable({}, class)

	object._remoteEvent = p or error("No remoteEvent")
	object._remoteFunction = p2 or error("No remoteFunction")

	object._remoteFunction.OnServerInvoke = function(_, p3)
		return object:_handleDelayRequest(p3)
	end

	object._remoteEvent.OnServerEvent:Connect(function(player)
		object._remoteEvent:FireClient(player, object:GetTime())
	end)

	coroutine.wrap(function()
		while true do
			wait(5)
			object:Sync()
		end
	end)()

	return object
end

function class:IsSynced(): boolean
	return true
end

function class:GetTime()
	return tick()
end

function class:Sync()
	local time = self:GetTime()

	self._remoteEvent:FireAllClients(time)
end

function class:_handleDelayRequest(p)
	return self:GetTime() - p
end

local class2 = {}
class2.__index = class2
class2.ClassName = "SlaveClock"
class2._offset = -1

function class2.new(p, p2)
	local object = setmetatable({}, class2)

	object._remoteEvent = p or error("No remoteEvent")
	object._remoteFunction = p2 or error("No remoteFunction")

	object._remoteEvent.OnClientEvent:Connect(function(p3)
		object:_handleSyncEvent(p3)
	end)

	object._remoteEvent:FireServer()

	return object
end

function class2:GetTime()
	if self:IsSynced() then
		return self:_getLocalTime() - self._offset
	end

	return self:_getLocalTime()
end

function class2:IsSynced(): boolean
	return self._offset ~= -1
end

function class2:_getLocalTime()
	return tick()
end

function class2:_handleSyncEvent(p)
	local v = self:_getLocalTime() - p

	local v2 = self:_sendDelayRequest((self:_getLocalTime()))

	local offset = (v - v2) / 2
	local pneWayDelay = (v + v2) / 2

	self._offset = offset
	self._pneWayDelay = pneWayDelay
end

function class2:_sendDelayRequest(p)
	return self._remoteFunction:InvokeServer(p)
end

local function buildClock()
	local timeSyncEvent = script:WaitForChild("TimeSyncEvent")
	local delayedRequestEvent = script:WaitForChild("DelayedRequestEvent")

	if RunService:IsClient() and RunService:IsServer() then
		local v = class.new(timeSyncEvent, delayedRequestEvent)
		timeSyncEvent.OnClientEvent:Connect(function() end)
		return v
	elseif RunService:IsClient() then
		return class2.new(timeSyncEvent, delayedRequestEvent)
	else
		return class.new(timeSyncEvent, delayedRequestEvent)
	end
end

return buildClock()