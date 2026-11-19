local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Drag = require(script.Drag)

local Color = {}
Color.__index = Color

function toPolar(data)
	return math.atan2(data.y, data.x), data.Magnitude
end

function radToDeg(p)
	return (p + 3.141592653589793) / 6.283185307179586 * 360
end

function template(p, items)
	local result = (not p or typeof(p) ~= "table" or not p) and {} or p

	for k, item in pairs(items) do
		if result[k] == nil then
			result[k] = item
		end
	end

	return result
end

function rotateVector(p, p2)
	local v = math.rad(p2)
	local x = p.X
	local y = p.Y

	return Vector2.new(x * math.cos(v) - y * math.sin(v), x * math.sin(v) + y * math.cos(v))
end

function roundToHundredths(p)
	return math.ceil(p * 100) / 100
end

function Color.New(gui, mouse, p)
	local params = template(p, {
		Position = UDim2.fromScale(0.195, 0.315),
		Draggable = true,
		RoundedCorners = true,
		PrimaryColor = Color3.fromRGB(26, 26, 36),
		SecondaryColor = Color3.fromRGB(36, 36, 46),
		TopbarColor = Color3.fromRGB(21, 21, 31),
		TextColor = Color3.fromRGB(255, 255, 255)
	})

	local object = setmetatable(
		{ Gui = gui, Mouse = mouse, Color = Color3.fromRGB(255, 255, 255), Params = params },
		Color
	)

	object:Create()

	object._wheelDownFunc = nil
	object._wheelUpFunc_uis = nil

	local function _resetWheelFunc() -- 3 equivalent calls inferred from this helper
		if object._wheelDownFunc then
			object._wheelDownFunc:Disconnect()
			object._wheelDownFunc = nil
		end

		if object._wheelUpFunc_uis then
			object._wheelUpFunc_uis:Disconnect()
			object._wheelUpFunc_uis = nil
		end
	end

	object.Instance.Wheel.Button.MouseButton1Down:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = false
		_resetWheelFunc() -- inferred equivalent call
		object._wheelDownFunc = RunService.Heartbeat:Connect(function()
			local mouseToWheelPos = object:GetMouseToWheelPos()
			object.Instance.Wheel.Image.Select.Position = UDim2.fromOffset(mouseToWheelPos.X, mouseToWheelPos.Y)

			object:SetColorFromPos(mouseToWheelPos)
		end)

		object._wheelUpFunc_uis = UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				_resetWheelFunc() -- inferred equivalent call
			end
		end)
	end)

	object.Instance.Wheel.Button.MouseButton1Up:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = true
		_resetWheelFunc() -- inferred equivalent call
	end)

	object._valueDownFunc = nil
	object._valueUpFunc_uis = nil

	local function _resetValueFunc() -- 3 equivalent calls inferred from this helper
		if object._valueDownFunc then
			object._valueDownFunc:Disconnect()
			object._valueDownFunc = nil
		end

		if object._valueUpFunc_uis then
			object._valueUpFunc_uis:Disconnect()
			object._valueUpFunc_uis = nil
		end
	end

	object.Instance.Right.Value.Button.MouseButton1Down:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = false
		_resetValueFunc() -- inferred equivalent call
		object._valueDownFunc = RunService.Heartbeat:Connect(function()
			local mouseToValuePos = object:GetMouseToValuePos()
			object.Instance.Right.Value.Select.Position = UDim2.new(0, 0, mouseToValuePos, 0)

			local hsv, v, _ = object.Color:ToHSV()
			object.Color = Color3.fromHSV(object.CurrentHue or hsv, object.CurrentSaturation or v, 1 - mouseToValuePos)

			object:UpdateColor()
		end)

		object._valueUpFunc_uis = UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				_resetValueFunc() -- inferred equivalent call
			end
		end)
	end)

	object.Instance.Right.Value.Button.MouseButton1Up:Connect(function()
		object.Instance.Parent.Topbar.Button.Visible = true
		_resetValueFunc() -- inferred equivalent call
	end)

	object:UpdateColor()

	object.Instance.Bottom.Buttons.Confirm.MouseButton1Down:Connect(function()
		object.Instance.Parent.FinishedEvent:Fire(object.Color)
		object:Destroy()
	end)

	object.Instance.Bottom.Buttons.Cancel.MouseButton1Down:Connect(function()
		object.Instance.Parent.CanceledEvent:Fire()
		object:Destroy()
	end)

	for _, frame in pairs(object.Instance.Parent.Properties.RGB:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Frame.TextBox.FocusLost:Connect(function()
				if not tonumber(frame.Frame.TextBox.Text) then
					frame.Frame.TextBox.Text = "0"
				end

				local text = tonumber(object.Instance.Parent.Properties.RGB.R.Frame.TextBox.Text) or 0
				local text2 = tonumber(object.Instance.Parent.Properties.RGB.G.Frame.TextBox.Text) or 0
				local text3 = tonumber(object.Instance.Parent.Properties.RGB.B.Frame.TextBox.Text) or 0
				local v = math.clamp(text, 0, 255)
				local v2 = math.clamp(text2, 0, 255)
				local v3 = math.clamp(text3, 0, 255)

				object:SetColor(Color3.fromRGB(v, v2, v3))
			end)
		end
	end

	for _, frame in pairs(object.Instance.Parent.Properties.HSV:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Frame.TextBox.FocusLost:Connect(function()
				if not tonumber(frame.Frame.TextBox.Text) then
					frame.Frame.TextBox.Text = "0"
				end

				local text = tonumber(object.Instance.Parent.Properties.HSV.H.Frame.TextBox.Text) or 0
				local text2 = tonumber(object.Instance.Parent.Properties.HSV.S.Frame.TextBox.Text) or 0
				local text3 = tonumber(object.Instance.Parent.Properties.HSV.V.Frame.TextBox.Text) or 0
				local v = math.clamp(text, 0, 360)
				local v2 = math.clamp(text2, 0, 1)
				local v3 = math.clamp(text3, 0, 1)

				object:SetColor(Color3.fromHSV(v / 360, v2, v3))
			end)
		end
	end

	object.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.FocusLost:Connect(function()
		local v = object.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text
		local success, _ = pcall(function()
			v = Color3.fromHex(v)
		end)

		if not success then
			v = Color3.fromRGB(255, 255, 255)
		end

		object.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text = v:ToHex()
		object:SetColor(v)
	end)

	return object
end

function Color:Create()
	local clone = script.ColorWindow:Clone()
	clone.Position = self.Params.Position
	clone.Parent = self.Gui
	clone.Visible = true

	self.Instance = clone.Content

	for _, descendant in pairs(clone:GetDescendants()) do
		if not self.Params.RoundedCorners and descendant:IsA("UICorner") and descendant.Parent.Name ~= "Select" then
			descendant:Destroy()
		end

		if not (descendant:IsA("TextLabel") or descendant:IsA("TextBox") or descendant:IsA("ImageButton")) then
			continue
		end

		descendant[(descendant:IsA("TextLabel") or descendant:IsA("TextBox")) and "TextColor3" or "ImageColor3"] = self.Params.TextColor
	end

	clone.BackgroundColor3 = self.Params.PrimaryColor
	clone.Properties.BackgroundColor3 = self.Params.PrimaryColor

	clone.Properties.Line.BackgroundColor3 = self.Params.SecondaryColor
	clone.Content.Bottom.Hex.Frame.BackgroundColor3 = self.Params.SecondaryColor

	for _, v in pairs({ clone.Properties.HSV, clone.Properties.RGB }) do
		for _, frame in pairs(v:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Frame.BackgroundColor3 = self.Params.SecondaryColor
			end
		end
	end

	clone.Topbar.BackgroundColor3 = self.Params.TopbarColor
	clone.Topbar.Frame.BackgroundColor3 = self.Params.TopbarColor

	self.Finished = clone.FinishedEvent.Event
	self.Canceled = clone.CanceledEvent.Event
	self.Updated = clone.UpdateEvent.Event

	if self.Params.Draggable and not UserInputService.TouchEnabled then
		self.Drag = Drag.New(self.Instance.Parent)

		local button = self.Instance.Parent.Topbar.Button
		button.MouseButton1Down:Connect(function()
			self.Drag:Start()
		end)

		button.MouseButton1Up:Connect(function()
			self.Drag:Stop()
		end)

		self._dragStopFunc = UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and self.Drag.Active
			then
				self.Drag:Stop()
			end
		end)
	end
end

function Color:Destroy()
	if self.Instance and self.Instance.Parent then
		self.Instance.Parent:Destroy()
	end

	if self._dragStopFunc then
		self._dragStopFunc:Disconnect()
		self._dragStopFunc = nil
	end

	if self._valueDownFunc then
		self._valueDownFunc:Disconnect()
		self._valueDownFunc = nil
	end

	if self._valueUpFunc_uis then
		self._valueUpFunc_uis:Disconnect()
		self._valueUpFunc_uis = nil
	end
end

function Color:GetMouseToWheelPos()
	local vector2 = Vector2.new(self.Mouse.X, self.Mouse.Y)
	local absolutePosition = self.Instance.Wheel.Image.AbsolutePosition
	local absoluteSize = self.Instance.Wheel.Image.AbsoluteSize

	local v = vector2 - absolutePosition
	local v2 = absolutePosition + absoluteSize / 2
	local v3 = absoluteSize.X / 2

	local v4 = v2 - vector2

	if v3 < v4.Magnitude then
		return absoluteSize / 2 - v4.Unit * v3
	end

	return v
end

function Color:GetMouseToValuePos()
	local vector2 = Vector2.new(self.Mouse.X, self.Mouse.Y)
	local absolutePosition = self.Instance.Right.Value.AbsolutePosition
	local absoluteSize = self.Instance.Right.Value.AbsoluteSize

	return (math.clamp((vector2.Y - absolutePosition.Y) / absoluteSize.Y, 0, 1))
end

function Color:UpdateColor()
	self.Instance.Parent.UpdateEvent:Fire(self.Color)
	self.Instance.Bottom.Color.Frame.BackgroundColor3 = self.Color

	self.Instance.Parent.Properties.RGB.R.Frame.TextBox.Text = math.floor(self.Color.R * 255 + 0.5)
	self.Instance.Parent.Properties.RGB.G.Frame.TextBox.Text = math.floor(self.Color.G * 255 + 0.5)
	self.Instance.Parent.Properties.RGB.B.Frame.TextBox.Text = math.floor(self.Color.B * 255 + 0.5)

	local hsv, v, v2 = self.Color:ToHSV()
	self.Instance.Parent.Properties.HSV.H.Frame.TextBox.Text = math.floor(hsv * 360 + 0.5)
	self.Instance.Parent.Properties.HSV.S.Frame.TextBox.Text = roundToHundredths(v)
	self.Instance.Parent.Properties.HSV.V.Frame.TextBox.Text = roundToHundredths(v2)

	local hex = self.Color:ToHex()
	self.Instance.Parent.Content.Bottom.Hex.Frame.TextBox.Text = string.format("#%s", string.lower(hex))
end

function Color:SetColorFromPos(vector2: Vector2)
	local absoluteSize = self.Instance.Wheel.Image.AbsoluteSize
	local v = absoluteSize / 2 - vector2
	local v2 = absoluteSize.X / 2

	math.min(v.Magnitude, v2)

	local v3, v4 = toPolar(v * Vector2.new(-1, 1))
	local v5 = radToDeg(v3) / 360
	local v6 = v4 / v2
	local v7 = math.clamp(v5, 0, 1)
	local v8 = math.clamp(v6, 0, 1)

	local _, _, v9 = self.Color:ToHSV()
	self.Color = Color3.fromHSV(v7, v8, v9)

	self:UpdateColor()
	self:SetValueGradient(v7, v8)
end

function Color:SetValueGradient(currentHue: number, currentSaturation: number)
	self.CurrentSaturation = currentSaturation
	self.CurrentHue = currentHue

	local color = Color3.fromHSV(currentHue, currentSaturation, 1)
	self.Instance.Right.Value.UIGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
	})
end

function Color:SetColor(color: Color3)
	local hsv, v, v2 = color:ToHSV()
	self.Color = color

	local absoluteSize = self.Instance.Wheel.Image.AbsoluteSize
	local _ = absoluteSize / 2
	local _ = absoluteSize.X / 2

	local vector2 = Vector2.new(0.5, 0.5)

	local vector2_2 = Vector2.new(-1, 0)
	local v3 = rotateVector(vector2_2, hsv * -360)
	local v4 = vector2 - rotateVector(v3, 180) * v * 0.5
	self.Instance.Wheel.Image.Select.Position = UDim2.fromScale(v4.X, v4.Y)
	self.Instance.Right.Value.Select.Position = UDim2.new(0, 0, 1 - v2, 0)

	self:UpdateColor()
	self:SetValueGradient(hsv, v)
end

return Color