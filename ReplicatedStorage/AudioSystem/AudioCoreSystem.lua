local AudioCoreSystem = {}
local RunService = game:GetService("RunService")

AudioCoreSystem.UpdateRate = 0.05
AudioCoreSystem.BassWeight = 0.2
AudioCoreSystem.ProtectGap = 0.2
AudioCoreSystem.TooMuchRatio = 0.2

local v = 0

local function applyVisual(part, visible, value, value2) -- 5 equivalent calls inferred from this helper
	if not part then
		return
	end

	if not part:IsA("BasePart") then
		part.Visible = visible

		return
	end

	part.Material = visible and Enum.Material.Neon or Enum.Material.Plastic
	part.Transparency = visible and (value or 0) or value2 or 0.7
end

function AudioCoreSystem.SetIndicator(data, value)
	if not data then
		return
	end

	if data.PowerInd then
		for _, child in pairs(data.PowerInd.PowerInd:GetChildren()) do
			applyVisual(child, data.IsPowerOn, nil, 0.6) -- inferred equivalent call
		end
	end

	if data.protectValue and data.protectIND then
		local value2 = data.protectValue.Value
		applyVisual(data.protectIND, value2) -- inferred equivalent call
	end

	if data.steps and #data.steps > 0 then
		local v2 = #data.steps
		local v3 = math.floor(math.clamp(value or 0, 0, 1) * v2 + 0.5)

		for i, step in ipairs(data.steps) do
			applyVisual(step, i <= v3 and not data.protectValue.Value) -- inferred equivalent call
		end
	end
end

function AudioCoreSystem.Update(items, list, p, instance, p2, p3)
	v += p3

	if v < AudioCoreSystem.UpdateRate then
		return
	end

	v -= AudioCoreSystem.UpdateRate

	if not (instance and p2) then
		return
	end

	local v2 = math.clamp(
		instance:FindFirstChild("Mixer") and instance.Mixer:GetAttribute("MainFader") or instance:GetAttribute("MainFader") or 1 or 0,
		0,
		1
	)
	local audioIntensity = instance:GetAttribute("AudioIntensity")
	local x = audioIntensity.X
	local y = audioIntensity.Y
	local v3 = math.clamp(x, 0, 1)

	local total = 0
	local count = #list

	if count == 0 then
		p2.Volume = 0
		return
	end

	for _, item in ipairs(list) do
		if item and item.Value and item.Parent and item.Parent.Power then
			if item.Parent.Power.Value == true then
				total += math.clamp(item.Value, 0, 1)
			end
		else
			error("potensioval not found!")
		end
	end

	local v4 = total / count
	local v5 = v4 * v2 + v3 * AudioCoreSystem.BassWeight

	local _ = p + AudioCoreSystem.ProtectGap < v5

	if p > 1 then
		local v6

		if (p - v5) / p > AudioCoreSystem.TooMuchRatio then
			v6 = v5 < p * 0.9
		end
	end

	math.clamp(v5 / math.max(p, 1), 0, 1)
	p2.Volume = math.clamp(v4 * v2 * 3, 0, 3)

	for k, item in pairs(items) do
		if not (type(k) == "string" and type(item) == "table" and item._isAmplifier) then
			continue
		end

		if item.channelOutputs then
			for _, channelOutput in pairs(item.channelOutputs) do
				local v6

				if channelOutput.outputInstance then
					if channelOutput.outputInstance.Parent:GetAttribute("DominantTo") == "Low" then
						v6 = math.clamp(channelOutput.outputInstance.Value * v3 * 3 or 0, 0, 1)
					else
						v6 = math.clamp(channelOutput.outputInstance.Value * y * 3 or 0, 0, 1)
					end
				else
					v6 = 0
				end

				local v7 = not item.IsPowerOn and 0 or v6

				AudioCoreSystem.SetIndicator(channelOutput, v7)

				if channelOutput.activeIND then
					applyVisual(channelOutput.activeIND, item.IsPowerOn) -- inferred equivalent call
				end
			end
		end

		if not item.PowerInd then
			continue
		end

		for _, child in pairs(item.PowerInd:GetChildren()) do
			applyVisual(child, item.IsPowerOn, nil, 0.6) -- inferred equivalent call
		end
	end
end

function AudioCoreSystem.UpdateDistanceSeatToPlayer(p): number
	if not p then
		return 20
	end

	local character = game.Players.LocalPlayer and game.Players.LocalPlayer.Character

	if not (character and character.PrimaryPart) then
		return 20
	end

	local magnitude = (character.PrimaryPart.Position - p.Position).Magnitude

	if magnitude < 10 then
		return 40
	end

	if magnitude < 30 then
		return 30
	end

	return if magnitude < 60 then 20 else 10
end

function AudioCoreSystem.SetupAudio(instance, p, instance2, _)
	if not (instance and p and instance2) then
		return
	end

	local sigmaPowerWatt = instance2:GetAttribute("SigmaPowerWatt") or 1
	local wattNeeded = instance2:GetAttribute("WattNeeded") or 1
	local v2 = sigmaPowerWatt > 0 and wattNeeded > 0 and wattNeeded / sigmaPowerWatt or 1
	local count = 0
	local result = {}

	local connections = {}
	local children = {}

	for _, model in ipairs(instance:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		count += 1
		local v3 = model.Name .. "_" .. count
		result[v3] = { _isAmplifier = true, Conn = {}, channelOutputs = {} }

		local body = model:FindFirstChild("Body")

		if not body then
			continue
		end

		local values = body:FindFirstChild("Values")
		local ind = body:FindFirstChild("Ind")

		if values then
			local power = values:FindFirstChild("Power")
			local protect = values:FindFirstChild("Protect")

			if power then
				result[v3].IsPowerOn = power.Value
				table.insert(connections, power:GetPropertyChangedSignal("Value"):Connect(function()
					result[v3].IsPowerOn = power.Value
				end))
			else
				result[v3].IsPowerOn = false
			end

			if protect then
				result[v3].Protect = protect
			end
		end

		if not ind then
			continue
		end

		local powerInd = ind:FindFirstChild("PowerInd")

		if powerInd then
			result[v3].PowerInd = powerInd
		end

		if ind:FindFirstChild("Indicator") and ind.Indicator:FindFirstChild("Frame") then
			result[v3]._isGuiIND = true

			for _, frame in ipairs(ind.Indicator.Frame:GetChildren()) do
				if not (frame:IsA("Frame") and string.sub(frame.Name, 1, 2) == "CH") then
					continue
				end

				local name = frame.Name
				local v4 = {
					_isChannel = true,
					steps = {},
					protectIND = nil,
					protectValue = nil,
					activeValue = nil,
					activeIND = nil,
					outputInstance = nil
				}

				if values then
					local child = values:FindFirstChild("Output" .. name)

					if child then
						v4.outputInstance = child
						table.insert(children, child)

						table.insert(connections, child:GetPropertyChangedSignal("Value"):Connect(function(_) end))
					end

					local protectValue = values:FindFirstChild("Protect" .. name) or values:FindFirstChild("Protect")

					if protectValue then
						v4.protectValue = protectValue
						table.insert(
							connections,
							protectValue:GetPropertyChangedSignal("Value"):Connect(function(_) end)
						)
					end

					local activeValue = values:FindFirstChild("Active" .. name) or values:FindFirstChild("Active")

					if activeValue then
						v4.activeValue = activeValue
						table.insert(
							connections,
							activeValue:GetPropertyChangedSignal("Value"):Connect(function(_) end)
						)
					end
				end

				for _, uiListLayout in ipairs(frame:GetChildren()) do
					if uiListLayout:IsA("UIListLayout") then
						continue
					end

					if uiListLayout.Name:match("^S%d+") then
						table.insert(v4.steps, uiListLayout)
					elseif uiListLayout.Name == "Protect" then
						v4.protectIND = uiListLayout
					elseif uiListLayout.Name == "Active" or uiListLayout.Name == "ActiveInd" then
						v4.activeIND = uiListLayout
					end
				end

				table.sort(v4.steps, function(a, b): boolean
					return (tonumber(a.Name:match("%d+")) or 0) < (tonumber(b.Name:match("%d+")) or 0)
				end)

				result[v3].channelOutputs[name] = v4
			end
		else
			result[v3]._isGuiIND = false

			for _, model2 in ipairs(ind:GetChildren()) do
				if not (model2:IsA("Model") and string.sub(model2.Name, 1, 2) == "CH") then
					continue
				end

				local name = model2.Name
				local v4 = {
					_isChannel = true,
					steps = {},
					protectIND = nil,
					protectValue = nil,
					activeValue = nil,
					activeIND = nil,
					outputInstance = nil
				}

				if values then
					local child = values:FindFirstChild("Output" .. name)

					if child then
						v4.outputInstance = child
						table.insert(children, child)

						table.insert(connections, child:GetPropertyChangedSignal("Value"):Connect(function(_) end))
					end

					local protectValue = values:FindFirstChild("Protect" .. name) or values:FindFirstChild("Protect")

					if protectValue then
						v4.protectValue = protectValue
						table.insert(
							connections,
							protectValue:GetPropertyChangedSignal("Value"):Connect(function(_) end)
						)
					end

					local activeValue = values:FindFirstChild("Active" .. name) or values:FindFirstChild("Active")

					if activeValue then
						v4.activeValue = activeValue
						table.insert(
							connections,
							activeValue:GetPropertyChangedSignal("Value"):Connect(function(_) end)
						)
					end
				end

				for _, child in ipairs(model2:GetChildren()) do
					if child.Name:match("^S%d+") then
						table.insert(v4.steps, child)
					elseif child.Name == "Protect" then
						v4.protectIND = child
					elseif child.Name == "Active" or child.Name == "ActiveInd" then
						v4.activeIND = child
					end
				end

				table.sort(v4.steps, function(a, b): boolean
					return (tonumber(a.Name:match("%d+")) or 0) < (tonumber(b.Name:match("%d+")) or 0)
				end)

				result[v3].channelOutputs[name] = v4
			end
		end
	end

	result._connections = connections

	result._renderConn = RunService.RenderStepped:Connect(function(dt)
		AudioCoreSystem.Update(result, children, v2, instance2, p, dt)
	end)

	return result, children
end

function AudioCoreSystem:Cleanup()
	if not self then
		return
	end

	if self._renderConn then
		self._renderConn:Disconnect()
		self._renderConn = nil
	end

	if self._connections then
		for _, connection in ipairs(self._connections) do
			if connection and connection.Disconnect then
				connection:Disconnect()
			end
		end

		self._connections = nil
	end
end

return AudioCoreSystem