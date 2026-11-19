require(script.Types)

local Iris = {}

local Internal = require(script.Internal)
local internal = Internal(Iris)

Iris.Disabled = false

Iris.Args = {}

Iris.Events = {}

function Iris.Init(parentInstance, callback, flag: boolean)
	assert(internal._shutdown == false, "Iris.Init() cannot be called once shutdown.")
	assert(internal._started == false or flag == true, "Iris.Init() can only be called once.")

	if internal._started then
		return Iris
	end

	if parentInstance == nil then
		local Players = game:GetService("Players")
		parentInstance = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	if callback == nil then
		local RunService = game:GetService("RunService")
		callback = RunService.Heartbeat
	end

	internal.parentInstance = parentInstance
	internal._started = true

	internal._generateRootInstance()
	internal._generateSelectionImageObject()

	for _, initFunction in internal._initFunctions do
		initFunction()
	end

	task.spawn(function()
		if typeof(callback) == "function" then
			while internal._started do
				local v = callback()
				internal._cycle(v)
			end
		elseif callback ~= nil and callback ~= false then
			internal._eventConnection = callback:Connect(function(...)
				internal._cycle(...)
			end)
		end
	end)

	return Iris
end

function Iris.Shutdown()
	internal._started = false
	internal._shutdown = true

	if internal._eventConnection then
		internal._eventConnection:Disconnect()
	end

	internal._eventConnection = nil

	if internal._rootWidget then
		if internal._rootWidget.Instance then
			internal._widgets.Root.Discard(internal._rootWidget)
		end

		internal._rootInstance = nil
	end

	if internal.SelectionImageObject then
		internal.SelectionImageObject:Destroy()
	end

	for _, connection in internal._connections do
		connection:Disconnect()
	end
end

function Iris:Connect(callback)
	if internal._started == false then
		warn("Iris:Connect() was called before calling Iris.Init(); always initialise Iris first.")
	end

	local v = #internal._connectedFunctions + 1
	internal._connectedFunctions[v] = callback
	return function()
		internal._connectedFunctions[v] = nil
	end
end

function Iris:Append()
	local parentWidget = internal._GetParentWidget()
	local parent

	if internal._config.Parent then
		parent = internal._config.Parent
	else
		parent = internal._widgets[parentWidget.type].ChildAdded(parentWidget, {
			type = "userInstance"
		})
	end

	self.Parent = parent
end

function Iris.End()
	if internal._stackIndex == 1 then
		error("Too many calls to Iris.End().", 2)
	end

	internal._IDStack[internal._stackIndex] = nil
	internal._stackIndex -= 1
end

function Iris.ForceRefresh()
	internal._globalRefreshRequested = true
end

function Iris.UpdateGlobalConfig(items)
	for k, item in items do
		internal._rootConfig[k] = item
	end

	Iris.ForceRefresh()
end

function Iris.PushConfig(p)
	local state = Iris.State(-1)

	if state.value == -1 then
		state:set(p)
	elseif internal._deepCompare(state:get(), p) == false then
		state:set(p)
		internal._refreshStack[internal._refreshLevel] = true
		internal._refreshCounter += 1
	end

	internal._refreshLevel += 1

	internal._config = setmetatable(p, { __index = internal._config })
end

function Iris.PopConfig()
	internal._refreshLevel -= 1

	if internal._refreshStack[internal._refreshLevel] == true then
		internal._refreshCounter -= 1
		internal._refreshStack[internal._refreshLevel] = nil
	end

	internal._config = getmetatable(internal._config).__index
end

Iris.TemplateConfig = require(script.config)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.colorDark)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.sizeDefault)
Iris.UpdateGlobalConfig(Iris.TemplateConfig.utilityDefault)
internal._globalRefreshRequested = false

function Iris.PushId(value)
	assert(typeof(value) == "string", "The ID argument to Iris.PushId() to be a string.")

	internal._newID = true
	table.insert(internal._pushedIds, value)
end

function Iris.PopId()
	if #internal._pushedIds == 0 then
		return
	end

	table.remove(internal._pushedIds)
end

function Iris.SetNextWidgetID(nextWidgetId)
	internal._nextWidgetId = nextWidgetId
end

function Iris.State(p)
	local id = internal._getID(2)

	if internal._states[id] then
		return internal._states[id]
	end

	internal._states[id] = {
		ID = id,
		value = p,
		lastChangeTick = Iris.Internal._cycleTick,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}

	setmetatable(internal._states[id], internal.StateClass)
	return internal._states[id]
end

function Iris.WeakState(p)
	local id = internal._getID(2)

	if internal._states[id] then
		if next(internal._states[id].ConnectedWidgets) ~= nil then
			return internal._states[id]
		end

		internal._states[id] = nil
	end

	internal._states[id] = {
		ID = id,
		value = p,
		lastChangeTick = Iris.Internal._cycleTick,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}

	setmetatable(internal._states[id], internal.StateClass)
	return internal._states[id]
end

function Iris.VariableState(p, callback)
	local id = internal._getID(2)
	local state = internal._states[id]

	if state then
		if p ~= state.value then
			state:set(p)
		end

		return state
	else
		local v = {
			ID = id,
			value = p,
			lastChangeTick = Iris.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		}

		setmetatable(v, internal.StateClass)
		internal._states[id] = v

		v:onChange(callback)

		return v
	end
end

function Iris:TableState(p, callback)
	local v = self[p]
	local id = internal._getID(2)
	local state = internal._states[id]

	if state then
		if v ~= state.value then
			state:set(v)
		end

		return state
	else
		local v2 = {
			ID = id,
			value = v,
			lastChangeTick = Iris.Internal._cycleTick,
			ConnectedWidgets = {},
			ConnectedFunctions = {}
		}

		setmetatable(v2, internal.StateClass)
		internal._states[id] = v2

		v2:onChange(function()
			if callback == nil then
				self[p] = v2.value
			elseif callback(v2.value) then
				self[p] = v2.value
			end
		end)
		return v2
	end
end

function Iris.ComputedState(object, callback)
	local id = internal._getID(2)

	if internal._states[id] then
		return internal._states[id]
	end

	internal._states[id] = {
		ID = id,
		value = callback(object.value),
		lastChangeTick = Iris.Internal._cycleTick,
		ConnectedWidgets = {},
		ConnectedFunctions = {}
	}

	object:onChange(function(p)
		internal._states[id]:set(callback(p))
	end)
	setmetatable(internal._states[id], internal.StateClass)
	return internal._states[id]
end

local demoWindow = require(script.demoWindow)
Iris.ShowDemoWindow = demoWindow(Iris)

local widgets = require(script.widgets)
widgets(internal)
local API = require(script.API)
API(Iris)

return Iris