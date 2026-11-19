local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")

local Communicate = script:WaitForChild("Communicate")
local localScript = script:FindFirstChildWhichIsA("LocalScript") or script:WaitForChild("EasyTweenClient")
local TickSyncer = require(ReplicatedStorage:WaitForChild("EasyClientTween"):WaitForChild("TickSyncer"))

Instance.new("BindableEvent")

local EasyClientTween = {}
EasyClientTween.__index = EasyClientTween

function EasyClientTween.new(p, p2, p3, p4)
	local v = {
		Settings = {
			Sync = p3 or true,
			PlacedAlready = p2 or false,
			CanBeCancelled = p or false,
			PrintErrors = p4 or true
		},
		CompletedEvent = Instance.new("BindableEvent"),
		Completed = nil,
		Cancelled = false,
		CancelEvent = nil
	}

	setmetatable(v, EasyClientTween)

	v.Completed = v.CompletedEvent.Event

	return v
end

function EasyClientTween:addClient(p)
	if not p.PlayerGui:FindFirstChild(localScript.Name) then
		local clone = localScript:Clone()
		clone.Parent = p.PlayerGui
		clone.Disabled = false
	end
end

function EasyClientTween:addClientToPlayers()
	for _, v in pairs(Players:GetPlayers()) do
		EasyClientTween:addClient(v)
	end
end

function EasyClientTween:TweenAllClients(p, p2, p3)
	if not (p3 and p) then
		return
	end

	local v = p2 or TweenInfo.new(1)

	local settings = self.Settings

	if not settings.PlacedAlready then
		EasyClientTween:addClientToPlayers()
	end

	if settings.CanBeCancelled then
		if self.CancelEvent then
			self.CancelEvent:FireAllClients(p)
		else
			self.CancelEvent = Instance.new("RemoteEvent")
		end
	end

	TickSyncer:Sync()
	Communicate:FireAllClients(p, v, p3, settings, tick(), self.CancelEvent)
end

function EasyClientTween:TweenClient(player, p, p2, p3)
	if not (p3 and p) then
		return
	end

	local v = p2 or { 1 }

	local settings = self.Settings

	if not settings.PlacedAlready then
		EasyClientTween:addClient(player)
	end

	if settings.CanBeCancelled then
		if self.CancelEvent then
			self.Cancelled = true
			self.CancelEvent:FireAllClients(p)
		else
			self.CancelEvent = Instance.new("RemoteEvent")
		end
	end

	TickSyncer:Sync()

	Communicate:FireClient(player, p, v, p3, settings, tick(), self.CancelEvent)

	if v[1] then
		coroutine.wrap(function()
			wait(v[1])

			if not self.Cancelled then
				self.CompletedEvent:Fire()
			end
		end)()
	end
end

function EasyClientTween:Destroy()
	local function destroy(instance) -- 2 equivalent calls inferred from this helper
		if instance then
			return instance:Destroy()
		end
	end

	destroy(self.CompletedEvent) -- inferred equivalent call
	destroy(self.CancelEvent) -- inferred equivalent call

	setmetatable(self, { __mode = "k" })
end

function EasyClientTween.Cancel(p, instance)
	assert(instance and typeof(instance) == "Instance", "argument 1, \"object\" must be an instance")

	if p.CancelEvent then
		p.CancelEvent:FireAllClients(instance)
	end
end

return EasyClientTween