local TweenService = game:GetService("TweenService")

local parent = script.Parent
local Core = require(parent.Core)
local LampTypes = require(parent.LampTypes)
local PartTypes = require(parent.PartTypes)

local State = Core.State
local LampLogic = Core.LampLogic
local Tel = Core.Tel

local lod = { Cull = true, Interval = 1e999, Tween = false }
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local Car = {}
Car.__index = Car
Car.Controllers = setmetatable({}, { __mode = "k" })

function Car.new(folder, p, p2)
	local object = setmetatable({}, Car)
	object.Car = folder
	object.Cfg = Core.applyDefaults(p)
	object.TweenInfo = Core.tweenInfo(object.Cfg)
	object.TweenTime = object.TweenInfo.Time

	object.Entries = {}
	object.ByLamp = {}
	object.Animated = {}
	object.Anims = {}
	object.BlinkLamps = {}
	object.Warned = {}
	object.State = State.read(folder)
	object.Out = nil
	object.Lod = lod
	object.Active = false
	object.NextStep = 0
	object.LastStep = os.clock()
	object.StreamStamp = 0
	object.Dead = false

	object.Tel = {}
	object.Handlers = p2 and p2.Values
	object.Ctx = object:_makeCtx(p2)

	object.Tiers = table.clone(object.Cfg.LOD)
	table.sort(object.Tiers, function(a, b): boolean
		return a.Distance < b.Distance
	end)

	object.Conns = {
		folder.DescendantAdded:Connect(function(descendant)
			object:_register(descendant)
			object:_scheduleReapply()
		end),
		folder.DescendantRemoving:Connect(function(descendant)
			object:_unregister(descendant)
		end),
		folder:GetAttributeChangedSignal(Core.StateAttr):Connect(function()
			object.State = State.read(folder)
			object:Refresh()
		end),
		folder:GetAttributeChangedSignal(Core.DiscAttr):Connect(function()
			object:_applyDiscAttr()
		end),
		folder:GetAttributeChangedSignal(Core.ModeAttr):Connect(function()
			object:_applyMode()
		end),
		folder:GetAttributeChangedSignal(Core.SnapAttr):Connect(function()
			local streamStamp = object.StreamStamp
			task.delay(0.3, function()
				if not object.Dead and object.StreamStamp == streamStamp then
					object:ApplySnapshot()
				end
			end)
		end)
	}

	for _, descendant in folder:GetDescendants() do
		object:_register(descendant)
	end

	Car.Controllers[folder] = object
	object:ApplySnapshot()
	return object
end

function Car:_register(objectValue)
	if string.byte(objectValue.Name, 1) ~= 35 or self.Entries[objectValue] then
		return
	end

	local parsed, v, seq = Core.parse(objectValue.Name)

	if not parsed then
		return
	end

	local lampType = LampTypes[parsed]
	local partType = PartTypes[v]

	if lampType and partType then
		local v2 = {
			Inst = objectValue,
			Lamp = parsed,
			Type = partType,
			Seq = seq,
			Ready = false
		}
		self.Entries[objectValue] = v2
		local v3 = self.ByLamp[parsed]

		if not v3 then
			v3 = {}
			self.ByLamp[parsed] = v3
		end

		table.insert(v3, v2)

		if objectValue:IsA("ObjectValue") then
			v2.ValueConn = objectValue:GetPropertyChangedSignal("Value"):Connect(function()
				self:_bind(v2)
			end)
		end

		self:_bind(v2)
	elseif not self.Warned[objectValue.Name] then
		self.Warned[objectValue.Name] = true
		warn(("EpicLights // nama tidak dikenal: %s (lamp=%s, part=%s)"):format(objectValue.Name, parsed, v))
	end
end

function Car:_unregister(p)
	local entry = self.Entries[p]

	if not entry then
		return
	end

	self.Entries[p] = nil

	if entry.ValueConn then
		entry.ValueConn:Disconnect()
	end

	self:_unbind(entry)
	local v = self.ByLamp[entry.Lamp]
	local index = v and table.find(v, entry)

	if index then
		table.remove(v, index)
	end
end

function Car:_bind(state)
	self:_unbind(state)
	local objectValue = state.Inst

	if objectValue:IsA("ObjectValue") then
		objectValue = objectValue.Value
	end

	if not objectValue then
		return
	end

	state.Source = objectValue
	state.Token = {}

	local function try(): boolean -- 1 equivalent call inferred from this helper
		if not state.Type.Bind(state, self) then
			return false
		end

		if state.WaitConn then
			state.WaitConn:Disconnect()
			state.WaitConn = nil
		end

		state.Ready = true
		self:_applyNow(state)
		return true
	end

	if not try() then -- inferred equivalent call
		state.WaitConn = objectValue.ChildAdded:Connect(try)
	end
end

function Car:_unbind(state)
	if state.WaitConn then
		state.WaitConn:Disconnect()
		state.WaitConn = nil
	end

	if state.Tween then
		state.Tween:Cancel()
		state.Tween = nil
	end

	if state.Source and state.Type.Unbind then
		state.Type.Unbind(state, self)
	end

	state.Ready = false
	state.Source = nil
	state.Target = nil
	state.Token = nil
	state.Level = nil
	state.Bright = nil
	state.On = nil
end

function Car:_applyEntry(state, data, p)
	if not state.Ready then
		return
	end

	local cfg = self.Cfg
	local level, bright

	if data then
		level = data.Level
		bright = data.Bright

		if data.Blink then
			local seq, v

			if cfg.SequentialIndicators then
				seq = state.Seq
				v = state.Inst:GetAttribute("SeqCount") or 1
			else
				v = 1
			end

			if LampLogic.blinkLit(p, cfg.IndicatorFlashRate, seq, v) then
				level = cfg.Levels.Full
				bright = cfg.IndicatorBrightness
			end
		end
	else
		level = 0
		bright = 0
	end

	if state.Level == level and state.Bright == bright then
		return
	end

	local v = state.Level == nil
	state.Level = level
	state.Bright = bright

	local kind = state.Type
	local on = level > 0

	if state.On ~= on then
		state.On = on

		if kind.OnToggle then
			kind.OnToggle(state, on, self)
		end
	end

	local v2, v3, v4 = kind.Apply(state, level, bright, cfg)
	local target = state.Target

	if state.Tween then
		state.Tween:Cancel()
		state.Tween = nil
	end

	if v3 then
		for k, v5 in v3 do
			target[k] = v5
		end
	end

	if v2 then
		if self.Lod.Tween and not v then
			local tween = TweenService:Create(target, self.TweenInfo, v2)
			state.Tween = tween

			if v4 then
				tween.Completed:Once(function(p2)
					if p2 == Enum.PlaybackState.Completed then
						for k, v5 in v4 do
							target[k] = v5
						end
					end
				end)
			end

			tween:Play()
			return
		end

		for k, v5 in v2 do
			target[k] = v5
		end
	end

	if v4 then
		for k, v5 in v4 do
			target[k] = v5
		end
	end
end

function Car:_applyNow(p)
	if self.Lod.Cull then
		return
	end

	local out = self.Out
	self:_applyEntry(p, out and out[p.Lamp], workspace:GetServerTimeNow())
end

function Car:_updateActive()
	self.Active = #self.BlinkLamps > 0 or next(self.Animated) ~= nil or next(self.Anims) ~= nil
end

function Car:SetAnimated(p, p2)
	self.Animated[p] = p2 or nil
	self:_updateActive()
end

function Car:Refresh()
	if self.Lod.Cull then
		return
	end

	local out = LampLogic.compute(self.State, self.Cfg)
	self.Out = out

	table.clear(self.BlinkLamps)

	for k, v in out do
		if v.Blink then
			table.insert(self.BlinkLamps, k)
		end
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v in self.ByLamp do
		local v2 = out[k]

		for _, v3 in v do
			self:_applyEntry(v3, v2, serverTimeNow)
		end
	end

	self:_updateActive()
end

function Car:_makeCtx(p)
	local car = self.Car
	local v = {}
	local object = setmetatable({}, { __mode = "k" })
	local v2 = {}
	local object2 = setmetatable({}, { __mode = "k" })
	self.TelTweens = object2

	local ctx = {
		Car = car,
		Cfg = self.Cfg,
		State = {},
		Fresh = false,
		Config = p and p.Config
	}

	function ctx.Instant(): boolean
		return not self.Lod.Tween
	end

	function ctx.Get(value)
		local v3 = v[value]

		if v3 and v3.Parent then
			return v3
		end

		local child = car

		for childName in string.gmatch(value, "[^%.]+") do
			child = child:FindFirstChild(childName)

			if not child then
				v[value] = nil
				return nil
			end
		end

		v[value] = child
		return child
	end

	function ctx.Rotate(instance, p2)
		if type(instance) == "string" then
			instance = ctx.Get(instance)
		end

		if not instance then
			return
		end

		local v3

		if instance:IsA("JointInstance") then
			v3 = "C0"
		elseif instance:IsA("Bone") or instance:IsA("Attachment") then
			v3 = "CFrame"
		else
			return
		end

		local v4 = object[instance]

		if not v4 then
			v4 = instance[v3]
			object[instance] = v4
		end

		instance[v3] = v4 * p2
	end

	function ctx.Map(p2, data)
		if data.maxinput == data.mininput then
			return data.minoutput
		end

		return data.minoutput + (p2 - data.mininput) * (data.maxoutput - data.minoutput) / (data.maxinput - data.mininput)
	end

	function ctx.Animate(p2, p3)
		self.Anims[p2] = p3
		self:_updateActive()
	end

	function ctx.Stop(p2)
		self.Anims[p2] = nil
		self:_updateActive()
	end

	function ctx.Smooth(p2, p3, rate, apply)
		local v3 = v2[p2]

		if not v3 then
			v3 = {}
			v2[p2] = v3
		end

		v3.apply = apply

		if v3.cur == nil or ctx.Fresh or (rate or 0) <= 0 or ctx.Instant() then
			v3.cur = p3
			v3.target = p3
			self.Anims["s:" .. p2] = nil
			apply(p3)
		else
			v3.target = p3
			v3.rate = rate

			if not v3.step then
				function v3.step(p4)
					v3.cur += (v3.target - v3.cur) * (1 - math.exp(-v3.rate * p4))
					local selected = math.abs(v3.target - v3.cur) < 0.001

					if selected then
						v3.cur = v3.target
					end

					v3.apply(v3.cur)
					return selected
				end
			end

			self.Anims["s:" .. p2] = v3.step
			self:_updateActive()
		end
	end

	function ctx.Gauge(p2, p3, data)
		p3 = data.maxinput and ctx.Map(p3, data) or p3
		local axis = data.axis or Vector3.new(0, 0, 1)
		ctx.Smooth(p2, p3, data.rate or 0, function(p4)
			ctx.Rotate(data.joint, CFrame.fromAxisAngle(axis, p4))
		end)
	end

	function ctx:Tween(goal, p2)
		if not self then
			return
		end

		local v3 = object2[self]

		if v3 then
			v3:Cancel()
			object2[self] = nil
		end

		if ctx.Fresh or ctx.Instant() then
			for k, v4 in goal do
				self[k] = v4
			end
		else
			local tween = TweenService:Create(self, p2 or tweenInfo, goal)
			object2[self] = tween
			tween:Play()
		end
	end

	function ctx.Glow(p2, emissiveStrength)
		local v3 = ctx.Get(p2)
		local surfaceAppearance = v3 and v3:FindFirstChildWhichIsA("SurfaceAppearance")

		if surfaceAppearance then
			ctx.Tween(surfaceAppearance, { EmissiveStrength = emissiveStrength })
		end
	end

	return ctx
end

function Car:_run(callback, p, p2, p3)
	local success, result = pcall(callback, self.Ctx, p2, p3)

	if not (success or self.Warned["t" .. p]) then
		self.Warned["t" .. p] = true
		warn(("EpicLights // Processor.%s error: %s"):format(p, (tostring(result))))
	end
end

function Car:Telemetry(items)
	local handlers = self.Handlers
	local tel = self.Tel

	for k, item in items do
		local v = tel[k]

		if v == item then
			continue
		end

		tel[k] = item
		local v2 = handlers and handlers[k]

		if not v2 or self.Lod.Cull then
			continue
		end

		self:_run(v2, k, item, v)
	end

	self:_updateActive()
end

function Car:ReapplyTelemetry()
	local handlers = self.Handlers

	if not handlers or self.Lod.Cull then
		return
	end

	local ctx = self.Ctx
	ctx.Fresh = true

	for k, handler in handlers do
		local v = self.Tel[k]

		if v ~= nil then
			self:_run(handler, k, v, nil)
		end
	end

	ctx.Fresh = false
	self:_updateActive()
end

function Car:_scheduleReapply()
	if self.Handlers and not self.Reapplying then
		self.Reapplying = true
		task.delay(0.25, function()
			self.Reapplying = false

			if not self.Dead then
				self:ReapplyTelemetry()
			end
		end)
	end
end

function Car:OnFrame(p)
	local Unpack, v, v2 = Tel.unpack(p)

	if not Unpack then
		return
	end

	self.StreamStamp += 1
	self:Telemetry(Tel.decode(Unpack, v, v2))
end

function Car:_applyDiscAttr()
	local attribute = self.Car:GetAttribute(Core.DiscAttr)

	if type(attribute) == "number" then
		self:Telemetry((Tel.decode(0, attribute, {})))
	end
end

function Car:_applyMode()
	local attribute = self.Car:GetAttribute(Core.ModeAttr)

	if type(attribute) == "string" then
		self:Telemetry({ TransmissionMode = attribute })
	end
end

function Car:ApplySnapshot()
	local attribute = self.Car:GetAttribute(Core.SnapAttr)

	if type(attribute) == "string" then
		local Unpack, v, v2 = Tel.unpack(Tel.fromHex(attribute))

		if Unpack then
			self:Telemetry(Tel.decode(Unpack, v, v2))
		end
	end

	self:_applyMode()
end

function Car:Step(lastStep)
	if self.Lod.Cull or lastStep < self.NextStep then
		return
	end

	local v = math.min(lastStep - self.LastStep, 1)
	self.LastStep = lastStep
	self.NextStep = lastStep + self.Lod.Interval

	if #self.BlinkLamps > 0 then
		local serverTimeNow = workspace:GetServerTimeNow()

		for _, blinkLamp in self.BlinkLamps do
			local v2 = self.ByLamp[blinkLamp]

			if not v2 then
				continue
			end

			local v3 = self.Out[blinkLamp]

			for _, v4 in v2 do
				self:_applyEntry(v4, v3, serverTimeNow)
			end
		end
	end

	for k in self.Animated do
		k.Type.Update(k, v, self)
	end

	for k, anim in self.Anims do
		if anim(v) then
			self.Anims[k] = nil
		end
	end

	self:_updateActive()
end

function Car:UpdateLod(p)
	local magnitude = (self.Car:GetPivot().Position - p).Magnitude
	local lod2 = lod

	for _, tier in self.Tiers do
		if magnitude <= tier.Distance then
			lod2 = tier
			break
		end
	end

	if lod2 == self.Lod then
		return
	end

	local cull = self.Lod.Cull
	self.Lod = lod2

	if cull and not lod2.Cull then
		self.LastStep = os.clock()
		self:Refresh()
		self:ReapplyTelemetry()
	end
end

function Car:Destroy()
	self.Dead = true
	Car.Controllers[self.Car] = nil

	for _, conn in self.Conns do
		conn:Disconnect()
	end

	for k in self.Entries do
		self:_unregister(k)
	end

	for _, telTween in self.TelTweens do
		telTween:Cancel()
	end

	table.clear(self.Anims)
end

return Car