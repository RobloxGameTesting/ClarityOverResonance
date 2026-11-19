require(script.Parent.Parent.Types)

return function(data, data2)
	local numberChanged = {
		Init = function(_) end,
		Get = function(p): boolean
			return p.lastNumberChangedTick == data._cycleTick
		end
	}

	local function getValueByIndex(data3, p: number, arguments)
		local typeName = typeof(data3)

		if typeName == "number" then
			return data3
		end

		if typeName == "Vector2" then
			if p == 1 then
				return data3.X
			elseif p == 2 then
				return data3.Y
			end
		elseif typeName == "Vector3" then
			if p == 1 then
				return data3.X
			elseif p == 2 then
				return data3.Y
			elseif p == 3 then
				return data3.Z
			end
		elseif typeName == "UDim" then
			if p == 1 then
				return data3.Scale
			elseif p == 2 then
				return data3.Offset
			end
		elseif typeName == "UDim2" then
			if p == 1 then
				return data3.X.Scale
			elseif p == 2 then
				return data3.X.Offset
			elseif p == 3 then
				return data3.Y.Scale
			elseif p == 4 then
				return data3.Y.Offset
			end
		elseif typeName == "Color3" then
			local v = arguments.UseHSV and { data3:ToHSV() } or { data3.R, data3.G, data3.B }

			if p == 1 then
				return v[1]
			elseif p == 2 then
				return v[2]
			elseif p == 3 then
				return v[3]
			end
		elseif typeName == "Rect" then
			if p == 1 then
				return data3.Min.X
			elseif p == 2 then
				return data3.Min.Y
			elseif p == 3 then
				return data3.Max.X
			elseif p == 4 then
				return data3.Max.Y
			end
		elseif typeName == "table" then
			return data3[p]
		end

		error(`Incorrect datatype or value: {data3} {typeof(data3)} {p}.`)
	end

	local function updateValueByIndex(value, p: number, p2: number, arguments)
		if typeof(value) == "number" then
			return p2
		end

		if typeof(value) == "Vector2" then
			if p == 1 then
				return (Vector2.new(p2, value.Y))
			elseif p == 2 then
				return (Vector2.new(value.X, p2))
			end
		elseif typeof(value) == "Vector3" then
			if p == 1 then
				return (Vector3.new(p2, value.Y, value.Z))
			elseif p == 2 then
				return (Vector3.new(value.X, p2, value.Z))
			elseif p == 3 then
				return (Vector3.new(value.X, value.Y, p2))
			end
		elseif typeof(value) == "UDim" then
			if p == 1 then
				return (UDim.new(p2, value.Offset))
			elseif p == 2 then
				return (UDim.new(value.Scale, p2))
			end
		elseif typeof(value) == "UDim2" then
			if p == 1 then
				return (UDim2.new(UDim.new(p2, value.X.Offset), value.Y))
			elseif p == 2 then
				return (UDim2.new(UDim.new(value.X.Scale, p2), value.Y))
			elseif p == 3 then
				return (UDim2.new(value.X, UDim.new(p2, value.Y.Offset)))
			elseif p == 4 then
				return (UDim2.new(value.X, UDim.new(value.Y.Scale, p2)))
			end
		elseif typeof(value) == "Rect" then
			if p == 1 then
				return (Rect.new(Vector2.new(p2, value.Min.Y), value.Max))
			elseif p == 2 then
				return (Rect.new(Vector2.new(value.Min.X, p2), value.Max))
			elseif p == 3 then
				return (Rect.new(value.Min, Vector2.new(p2, value.Max.Y)))
			elseif p == 4 then
				return (Rect.new(value.Min, Vector2.new(value.Max.X, p2)))
			end
		elseif typeof(value) == "Color3" then
			if arguments.UseHSV then
				local hsv, v, v2 = value:ToHSV()

				if p == 1 then
					return (Color3.fromHSV(p2, v, v2))
				elseif p == 2 then
					return (Color3.fromHSV(hsv, p2, v2))
				elseif p == 3 then
					return (Color3.fromHSV(hsv, v, p2))
				end
			end

			if p == 1 then
				return (Color3.new(p2, value.G, value.B))
			elseif p == 2 then
				return (Color3.new(value.R, p2, value.B))
			elseif p == 3 then
				return (Color3.new(value.R, value.G, p2))
			end
		end

		error(`Incorrect datatype or value {value} {typeof(value)} {p}.`)
	end

	local v = {
		Num = { 1 },
		Vector2 = { 1, 1 },
		Vector3 = { 1, 1, 1 },
		UDim = { 0.01, 1 },
		UDim2 = { 0.01, 1, 0.01, 1 },
		Color3 = { 1, 1, 1 },
		Color4 = { 1, 1, 1, 1 },
		Rect = { 1, 1, 1, 1 }
	}

	local v2 = {
		Num = { 0 },
		Vector2 = { 0, 0 },
		Vector3 = { 0, 0, 0 },
		UDim = { 0, 0 },
		UDim2 = { 0, 0, 0, 0 },
		Rect = { 0, 0, 0, 0 }
	}

	local v3 = {
		Num = { 100 },
		Vector2 = { 100, 100 },
		Vector3 = { 100, 100, 100 },
		UDim = { 1, 960 },
		UDim2 = { 1, 960, 1, 960 },
		Rect = { 960, 960, 960, 960 }
	}

	local v4 = {
		Num = { "" },
		Vector2 = { "X: ", "Y: " },
		Vector3 = { "X: ", "Y: ", "Z: " },
		UDim = { "", "" },
		UDim2 = { "", "", "", "" },
		Color3_RGB = { "R: ", "G: ", "B: " },
		Color3_HSV = { "H: ", "S: ", "V: " },
		Color4_RGB = { "R: ", "G: ", "B: ", "T: " },
		Color4_HSV = { "H: ", "S: ", "V: ", "T: " },
		Rect = { "X: ", "Y: ", "X: ", "Y: " }
	}

	local v5 = {
		Num = { 0 },
		Vector2 = { 0, 0 },
		Vector3 = { 0, 0, 0 },
		UDim = { 3, 0 },
		UDim2 = { 3, 0, 3, 0 },
		Color3 = { 0, 0, 0 },
		Color4 = { 0, 0, 0, 0 },
		Rect = { 0, 0, 0, 0 }
	}

	local function generateButtons(state, frame, p: number)
		local subButton = data2.abstractButton.Generate(state)
		subButton.Name = "SubButton"
		subButton.ZIndex = 5
		subButton.LayoutOrder = 5
		subButton.TextXAlignment = Enum.TextXAlignment.Center
		subButton.Text = "-"
		subButton.Size = UDim2.fromOffset(
			data._config.TextSize + 2 * data._config.FramePadding.Y,
			data._config.TextSize
		)
		subButton.Parent = frame

		data2.applyButtonClick(subButton, function()
			local v6 = data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
				or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			local v7 = (state.arguments.Increment and getValueByIndex(state.arguments.Increment, 1, state.arguments) or 1) * (v6 and 100 or 1)
			local v8 = state.state.number.value - v7

			if state.arguments.Min ~= nil then
				v8 = math.max(v8, getValueByIndex(state.arguments.Min, 1, state.arguments))
			end

			if state.arguments.Max ~= nil then
				v8 = math.min(v8, getValueByIndex(state.arguments.Max, 1, state.arguments))
			end

			state.state.number:set(v8)
			state.lastNumberChangedTick = data._cycleTick + 1
		end)

		local addButton = data2.abstractButton.Generate(state)
		addButton.Name = "AddButton"
		addButton.ZIndex = 6
		addButton.LayoutOrder = 6
		addButton.TextXAlignment = Enum.TextXAlignment.Center
		addButton.Text = "+"
		addButton.Size = UDim2.fromOffset(
			data._config.TextSize + 2 * data._config.FramePadding.Y,
			data._config.TextSize
		)
		addButton.Parent = frame

		data2.applyButtonClick(addButton, function()
			local v6 = data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
				or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			local v7 = (state.arguments.Increment and getValueByIndex(state.arguments.Increment, 1, state.arguments) or 1) * (v6 and 100 or 1)
			local v8 = state.state.number.value + v7

			if state.arguments.Min ~= nil then
				v8 = math.max(v8, getValueByIndex(state.arguments.Min, 1, state.arguments))
			end

			if state.arguments.Max ~= nil then
				v8 = math.min(v8, getValueByIndex(state.arguments.Max, 1, state.arguments))
			end

			state.state.number:set(v8)
			state.lastNumberChangedTick = data._cycleTick + 1
		end)

		return 2 * data._config.ItemInnerSpacing.X + p * 2
	end

	local function generateInputScalar(p: string, p2: number, p3)
		return {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Increment = 2,
				Min = 3,
				Max = 4,
				Format = 5
			},
			Events = {
				["numberChanged"] = numberChanged,
				hovered = data2.EVENTS.hover(function(p4)
					return p4.Instance
				end)
			},
			Generate = function(state)
				local frame = Instance.new("Frame")
				frame.Name = "Iris_Input" .. p
				frame.Size = UDim2.new(data._config.ItemWidth, UDim.new())
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = state.ZIndex
				frame.AutomaticSize = Enum.AutomaticSize.Y
				local uiListLayout = data2.UIListLayout(
					frame,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

				local v6 = data._config.TextSize + 2 * data._config.FramePadding.Y

				local v7 = p2 ~= 1 and 0 or generateButtons(state, frame, v6)

				local udim = UDim.new(
					data._config.ContentWidth.Scale / p2,
					(data._config.ContentWidth.Offset - data._config.ItemInnerSpacing.X * (p2 - 1) - v7) / p2
				)
				local udim2 = UDim.new(
					udim.Scale * (p2 - 1),
					udim.Offset * (p2 - 1) + data._config.ItemInnerSpacing.X * (p2 - 1) + v7
				)
				local v8 = data._config.ContentWidth - udim2

				for i = 1, p2 do
					local textBox = Instance.new("TextBox")
					textBox.Name = "InputField" .. tostring(i)
					textBox.LayoutOrder = i

					if i == p2 then
						textBox.Size = UDim2.new(v8, data._config.ContentHeight)
					else
						textBox.Size = UDim2.new(udim, data._config.ContentHeight)
					end

					textBox.AutomaticSize = Enum.AutomaticSize.Y
					textBox.BackgroundColor3 = data._config.FrameBgColor
					textBox.BackgroundTransparency = data._config.FrameBgTransparency
					textBox.ClearTextOnFocus = false
					textBox.TextTruncate = Enum.TextTruncate.AtEnd
					textBox.ClipsDescendants = true

					data2.applyFrameStyle(textBox)
					data2.applyTextStyle(textBox)
					data2.UISizeConstraint(textBox, Vector2.xAxis)

					textBox.Parent = frame

					textBox.FocusLost:Connect(function()
						local v9 = tonumber(textBox.Text:match("-?%d*%.?%d*"))

						if v9 ~= nil then
							if state.arguments.Min ~= nil then
								v9 = math.max(v9, getValueByIndex(state.arguments.Min, i, state.arguments))
							end

							if state.arguments.Max ~= nil then
								v9 = math.min(v9, getValueByIndex(state.arguments.Max, i, state.arguments))
							end

							if state.arguments.Increment then
								v9 = math.round(v9 / getValueByIndex(state.arguments.Increment, i, state.arguments)) * getValueByIndex(
									state.arguments.Increment,
									i,
									state.arguments
								)
							end

							state.state.number:set(updateValueByIndex(state.state.number.value, i, v9, state.arguments))
							state.lastNumberChangedTick = data._cycleTick + 1
						end

						local v10 = state.arguments.Format[i] or state.arguments.Format[1]

						if state.arguments.Prefix then
							v10 = state.arguments.Prefix[i] .. v10
						end

						textBox.Text = string.format(v10, getValueByIndex(state.state.number.value, i, state.arguments))

						state.state.editingText:set(0)
					end)

					textBox.Focused:Connect(function()
						textBox.CursorPosition = #textBox.Text + 1
						textBox.SelectionStart = 1

						state.state.editingText:set(i)
					end)
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.LayoutOrder = 7
				textLabel.AutomaticSize = Enum.AutomaticSize.XY

				data2.applyTextStyle(textLabel)

				textLabel.Parent = frame

				return frame
			end,
			Update = function(p4)
				local instance = p4.Instance
				instance.TextLabel.Text = p4.arguments.Text or `Input {p}`

				if p2 == 1 then
					instance.SubButton.Visible = not p4.arguments.NoButtons
					instance.AddButton.Visible = not p4.arguments.NoButtons
					local v6 = p4.arguments.NoButtons and 0
						or 2 * data._config.ItemInnerSpacing.X + 2 * (data._config.TextSize + 2 * data._config.FramePadding.Y)
					instance.InputField1.Size = UDim2.new(
						UDim.new(data._config.ContentWidth.Scale, data._config.ContentWidth.Offset - v6),
						data._config.ContentHeight
					)
				end

				if p4.arguments.Format and typeof(p4.arguments.Format) ~= "table" then
					p4.arguments.Format = { p4.arguments.Format }
				elseif not p4.arguments.Format then
					local format = {}

					for i = 1, p2 do
						local v6 = v5[p][i]

						if p4.arguments.Increment then
							local valueByIndex = getValueByIndex(p4.arguments.Increment, i, p4.arguments)
							v6 = math.max(v6, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v6)
						end

						if p4.arguments.Max then
							local valueByIndex = getValueByIndex(p4.arguments.Max, i, p4.arguments)
							v6 = math.max(v6, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v6)
						end

						if p4.arguments.Min then
							local valueByIndex = getValueByIndex(p4.arguments.Min, i, p4.arguments)
							v6 = math.max(v6, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v6)
						end

						if v6 > 0 then
							format[i] = `%.{v6}f`
						else
							format[i] = "%d"
						end
					end

					p4.arguments.Format = format
					p4.arguments.Prefix = v4[p]
				end
			end,
			Discard = function(p4)
				p4.Instance:Destroy()
				data2.discardState(p4)
			end,
			GenerateState = function(p4)
				if p4.state.number == nil then
					p4.state.number = data._widgetState(p4, "number", p3)
				end

				if p4.state.editingText == nil then
					p4.state.editingText = data._widgetState(p4, "editingText", 0)
				end
			end,
			UpdateState = function(data3)
				local instance = data3.Instance

				for i = 1, p2 do
					local child = instance:FindFirstChild("InputField" .. tostring(i))
					local v6 = data3.arguments.Format[i] or data3.arguments.Format[1]

					if data3.arguments.Prefix then
						v6 = data3.arguments.Prefix[i] .. v6
					end

					child.Text = string.format(v6, getValueByIndex(data3.state.number.value, i, data3.arguments))
				end
			end
		}
	end

	local v6 = 0
	local v7 = false
	local v8 = nil
	local v9 = 0
	local v10 = ""

	local function updateActiveDrag()
		local x = data2.getMouseLocation().X
		local v11 = x - v6
		v6 = x

		if not (v7 ~= false and v8 ~= nil) then
			return
		end

		local v12 = v8.state.number

		if v10 == "Color3" or v10 == "Color4" then
			local v13 = v8
			v12 = v13.state.color

			if v9 == 4 then
				v12 = v13.state.transparency
			end
		end

		local v13 = (v8.arguments.Increment and getValueByIndex(v8.arguments.Increment, v9, v8.arguments) or v[v10][v9]) * ((data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) and 10 or 1) * ((data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) and 0.1 or 1) * ((v10 == "Color3" or v10 == "Color4") and 5 or 1)

		local v14 = getValueByIndex(v12.value, v9, v8.arguments) + v11 * v13

		if v8.arguments.Min ~= nil then
			v14 = math.max(v14, getValueByIndex(v8.arguments.Min, v9, v8.arguments))
		end

		if v8.arguments.Max ~= nil then
			v14 = math.min(v14, getValueByIndex(v8.arguments.Max, v9, v8.arguments))
		end

		v12:set(updateValueByIndex(v12.value, v9, v14, v8.arguments))
		v8.lastNumberChangedTick = data._cycleTick + 1
	end

	local function DragMouseDown(state, p: string, i: number, p2: number, p3: number)
		local time = data2.getTime()
		local v11 = time - state.lastClickedTime < data._config.MouseDoubleClickTime
		local v12 = data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

		if
			v11 and (Vector2.new(p2, p3) - state.lastClickedPosition).Magnitude < data._config.MouseDoubleClickMaxDist
			or v12
		then
			state.state.editingText:set(i)
			return
		end

		state.lastClickedTime = time
		state.lastClickedPosition = Vector2.new(p2, p3)

		v7 = true
		v8 = state
		v9 = i
		v10 = p
		updateActiveDrag()
	end

	data2.registerEvent("InputChanged", function()
		if not data._started then
			return
		end

		updateActiveDrag()
	end)

	data2.registerEvent("InputEnded", function(p)
		if not data._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v7 then
			v7 = false
			v8 = nil
			v9 = 0
		end
	end)

	local function generateDragScalar(p: string, p2: number, p3)
		return {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Increment = 2,
				Min = 3,
				Max = 4,
				Format = 5
			},
			Events = {
				["numberChanged"] = numberChanged,
				hovered = data2.EVENTS.hover(function(p4)
					return p4.Instance
				end)
			},
			Generate = function(state)
				state.lastClickedTime = -1
				state.lastClickedPosition = Vector2.zero

				local frame = Instance.new("Frame")
				frame.Name = "Iris_Drag" .. p
				frame.Size = UDim2.new(data._config.ItemWidth, UDim.new())
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = state.ZIndex
				frame.AutomaticSize = Enum.AutomaticSize.Y
				local uiListLayout = data2.UIListLayout(
					frame,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

				local total = 0
				local v11 = data._config.TextSize + 2 * data._config.FramePadding.Y

				if p == "Color3" or p == "Color4" then
					total += data._config.ItemInnerSpacing.X + v11

					local colorBox = Instance.new("ImageLabel")
					colorBox.Name = "ColorBox"
					colorBox.BorderSizePixel = 0
					colorBox.Size = UDim2.fromOffset(v11, v11)
					colorBox.LayoutOrder = 5
					colorBox.Image = data2.ICONS.ALPHA_BACKGROUND_TEXTURE
					colorBox.ImageTransparency = 1

					data2.applyFrameStyle(colorBox, true)

					colorBox.Parent = frame
				end

				local udim = UDim.new(
					data._config.ContentWidth.Scale / p2,
					(data._config.ContentWidth.Offset - data._config.ItemInnerSpacing.X * (p2 - 1) - total) / p2
				)
				local udim2 = UDim.new(
					udim.Scale * (p2 - 1),
					udim.Offset * (p2 - 1) + data._config.ItemInnerSpacing.X * (p2 - 1) + total
				)
				local v12 = data._config.ContentWidth - udim2

				for i = 1, p2 do
					local textButton = Instance.new("TextButton")
					textButton.Name = "DragField" .. tostring(i)
					textButton.LayoutOrder = i

					if i == p2 then
						textButton.Size = UDim2.new(v12, data._config.ContentHeight)
					else
						textButton.Size = UDim2.new(udim, data._config.ContentHeight)
					end

					textButton.AutomaticSize = Enum.AutomaticSize.Y
					textButton.BackgroundColor3 = data._config.FrameBgColor
					textButton.BackgroundTransparency = data._config.FrameBgTransparency
					textButton.AutoButtonColor = false
					textButton.Text = ""
					textButton.ClipsDescendants = true

					data2.applyFrameStyle(textButton)
					data2.applyTextStyle(textButton)
					data2.UISizeConstraint(textButton, Vector2.xAxis)

					textButton.TextXAlignment = Enum.TextXAlignment.Center

					textButton.Parent = frame

					data2.applyInteractionHighlights("Background", textButton, textButton, {
						Color = data._config.FrameBgColor,
						Transparency = data._config.FrameBgTransparency,
						HoveredColor = data._config.FrameBgHoveredColor,
						HoveredTransparency = data._config.FrameBgHoveredTransparency,
						ActiveColor = data._config.FrameBgActiveColor,
						ActiveTransparency = data._config.FrameBgActiveTransparency
					})

					local inputField = Instance.new("TextBox")
					inputField.Name = "InputField"
					inputField.Size = UDim2.new(1, 0, 1, 0)
					inputField.BackgroundTransparency = 1
					inputField.ClearTextOnFocus = false
					inputField.TextTruncate = Enum.TextTruncate.AtEnd
					inputField.ClipsDescendants = true
					inputField.Visible = false

					data2.applyFrameStyle(inputField, true)
					data2.applyTextStyle(inputField)

					inputField.Parent = textButton

					inputField.FocusLost:Connect(function()
						local v13 = tonumber(inputField.Text:match("-?%d*%.?%d*"))
						local v14 = state.state.number
						local v15 = state

						if p == "Color4" and i == 4 then
							v14 = v15.state.transparency
						elseif p == "Color3" or p == "Color4" then
							v14 = v15.state.color
						end

						if v13 ~= nil then
							if p == "Color3" or p == "Color4" and not v15.arguments.UseFloats then
								v13 /= 255
							end

							if state.arguments.Min ~= nil then
								v13 = math.max(v13, getValueByIndex(state.arguments.Min, i, state.arguments))
							end

							if state.arguments.Max ~= nil then
								v13 = math.min(v13, getValueByIndex(state.arguments.Max, i, state.arguments))
							end

							if state.arguments.Increment then
								v13 = math.round(v13 / getValueByIndex(state.arguments.Increment, i, state.arguments)) * getValueByIndex(
									state.arguments.Increment,
									i,
									state.arguments
								)
							end

							v14:set(updateValueByIndex(v14.value, i, v13, state.arguments))
							state.lastNumberChangedTick = data._cycleTick + 1
						end

						local v16 = getValueByIndex(v14.value, i, state.arguments)

						if p == "Color3" or p == "Color4" and not v15.arguments.UseFloats then
							v16 = math.round(v16 * 255)
						end

						local v17 = state.arguments.Format[i] or state.arguments.Format[1]

						if state.arguments.Prefix then
							v17 = state.arguments.Prefix[i] .. v17
						end

						inputField.Text = string.format(v17, v16)

						state.state.editingText:set(0)
						inputField:ReleaseFocus(true)
					end)

					inputField.Focused:Connect(function()
						inputField.CursorPosition = #inputField.Text + 1
						inputField.SelectionStart = 1

						state.state.editingText:set(i)
					end)

					data2.applyButtonDown(textButton, function(p4: number, p5: number)
						DragMouseDown(state, p, i, p4, p5)
					end)
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.LayoutOrder = 6
				textLabel.AutomaticSize = Enum.AutomaticSize.XY

				data2.applyTextStyle(textLabel)

				textLabel.Parent = frame

				return frame
			end,
			Update = function(p4)
				p4.Instance.TextLabel.Text = p4.arguments.Text or `Drag {p}`

				if p4.arguments.Format and typeof(p4.arguments.Format) ~= "table" then
					p4.arguments.Format = { p4.arguments.Format }
				elseif not p4.arguments.Format then
					local format = {}

					for i = 1, p2 do
						local v11 = v5[p][i]

						if p4.arguments.Increment then
							local valueByIndex = getValueByIndex(p4.arguments.Increment, i, p4.arguments)
							v11 = math.max(v11, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v11)
						end

						if p4.arguments.Max then
							local valueByIndex = getValueByIndex(p4.arguments.Max, i, p4.arguments)
							v11 = math.max(v11, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v11)
						end

						if p4.arguments.Min then
							local valueByIndex = getValueByIndex(p4.arguments.Min, i, p4.arguments)
							v11 = math.max(v11, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v11)
						end

						if v11 > 0 then
							format[i] = `%.{v11}f`
						else
							format[i] = "%d"
						end
					end

					p4.arguments.Format = format
					p4.arguments.Prefix = v4[p]
				end
			end,
			Discard = function(p4)
				p4.Instance:Destroy()
				data2.discardState(p4)
			end,
			GenerateState = function(p4)
				if p4.state.number == nil then
					p4.state.number = data._widgetState(p4, "number", p3)
				end

				if p4.state.editingText == nil then
					p4.state.editingText = data._widgetState(p4, "editingText", false)
				end
			end,
			UpdateState = function(data3)
				local instance = data3.Instance

				for i = 1, p2 do
					local v11 = data3.state.number

					if p == "Color3" or p == "Color4" then
						v11 = data3.state.color

						if i == 4 then
							v11 = data3.state.transparency
						end
					end

					local child = instance:FindFirstChild("DragField" .. tostring(i))
					local inputField = child.InputField
					local v12 = getValueByIndex(v11.value, i, data3.arguments)

					if (p == "Color3" or p == "Color4") and not data3.arguments.UseFloats then
						v12 = math.round(v12 * 255)
					end

					local v13 = data3.arguments.Format[i] or data3.arguments.Format[1]

					if data3.arguments.Prefix then
						v13 = data3.arguments.Prefix[i] .. v13
					end

					child.Text = string.format(v13, v12)
					inputField.Text = tostring(v12)

					if data3.state.editingText.value == i then
						inputField.Visible = true
						inputField:CaptureFocus()
						child.TextTransparency = 1
					else
						inputField.Visible = false
						child.TextTransparency = data._config.TextTransparency
					end
				end

				if p == "Color3" or p == "Color4" then
					local colorBox = instance.ColorBox

					colorBox.BackgroundColor3 = data3.state.color.value

					if p == "Color4" then
						colorBox.ImageTransparency = 1 - data3.state.transparency.value
					end
				end
			end
		}
	end

	local function generateColorDragScalar(p: string, ...)
		local v11 = { ... }
		local v12 = generateDragScalar(p, p == "Color4" and 4 or 3, v11[1])

		return data2.extend(v12, {
			Args = { Text = 1, UseFloats = 2, UseHSV = 3, Format = 4 },
			Update = function(data3)
				data3.Instance.TextLabel.Text = data3.arguments.Text or `Drag {p}`

				if data3.arguments.Format and typeof(data3.arguments.Format) ~= "table" then
					data3.arguments.Format = { data3.arguments.Format }
				elseif not data3.arguments.Format then
					if data3.arguments.UseFloats then
						data3.arguments.Format = { "%.3f" }
					else
						data3.arguments.Format = { "%d" }
					end

					data3.arguments.Prefix = v4[p .. (data3.arguments.UseHSV and "_HSV" or "_RGB")]
				end

				data3.arguments.Min = { 0, 0, 0, 0 }
				data3.arguments.Max = { 1, 1, 1, 1 }
				data3.arguments.Increment = { 0.001, 0.001, 0.001, 0.001 }

				if data3.state then
					data3.state.color.lastChangeTick = data._cycleTick

					if p == "Color4" then
						data3.state.transparency.lastChangeTick = data._cycleTick
					end

					data._widgets[data3.type].UpdateState(data3)
				end
			end,
			GenerateState = function(p2)
				if p2.state.color == nil then
					p2.state.color = data._widgetState(p2, "color", v11[1])
				end

				if p == "Color4" and p2.state.transparency == nil then
					p2.state.transparency = data._widgetState(p2, "transparency", v11[2])
				end

				if p2.state.editingText == nil then
					p2.state.editingText = data._widgetState(p2, "editingText", false)
				end
			end
		})
	end

	local v11 = false
	local v12 = nil
	local v13 = 0
	local v14 = ""

	local function updateActiveSlider()
		if not (v11 ~= false and v12 ~= nil) then
			return
		end

		local child = v12.Instance:FindFirstChild("SliderField" .. tostring(v13))
		local grabBar = child.GrabBar

		local v15 = v12.arguments.Increment and getValueByIndex(v12.arguments.Increment, v13, v12.arguments)
			or v[v14][v13]
		local v16 = v12.arguments.Min and getValueByIndex(v12.arguments.Min, v13, v12.arguments) or v2[v14][v13]
		local v17 = v12.arguments.Max and getValueByIndex(v12.arguments.Max, v13, v12.arguments) or v3[v14][v13]

		local x = grabBar.AbsoluteSize.X
		local v18 = math.clamp(
			math.round((data2.getMouseLocation().X - (child.AbsolutePosition.X - data2.GuiOffset.X + x / 2)) / (child.AbsoluteSize.X - x) * math.floor((v17 - v16) / v15)) * v15 + v16,
			v16,
			v17
		)

		v12.state.number:set(updateValueByIndex(v12.state.number.value, v13, v18, v12.arguments))
		v12.lastNumberChangedTick = data._cycleTick + 1
	end

	local function SliderMouseDown(state, p: string, i: number)
		if
			data2.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or data2.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		then
			state.state.editingText:set(i)
			return
		end

		v11 = true
		v12 = state
		v13 = i
		v14 = p
		updateActiveSlider()
	end

	data2.registerEvent("InputChanged", function()
		if not data._started then
			return
		end

		updateActiveSlider()
	end)

	data2.registerEvent("InputEnded", function(p)
		if not data._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v11 then
			v11 = false
			v12 = nil
			v13 = 0
			v14 = ""
		end
	end)

	local function generateSliderScalar(p: string, p2: number, p3)
		return {
			hasState = true,
			hasChildren = false,
			Args = {
				Text = 1,
				Increment = 2,
				Min = 3,
				Max = 4,
				Format = 5
			},
			Events = {
				["numberChanged"] = numberChanged,
				hovered = data2.EVENTS.hover(function(p4)
					return p4.Instance
				end)
			},
			Generate = function(state)
				local frame = Instance.new("Frame")
				frame.Name = "Iris_Slider" .. p
				frame.Size = UDim2.new(data._config.ItemWidth, UDim.new())
				frame.BackgroundTransparency = 1
				frame.BorderSizePixel = 0
				frame.LayoutOrder = state.ZIndex
				frame.AutomaticSize = Enum.AutomaticSize.Y
				local uiListLayout = data2.UIListLayout(
					frame,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

				local udim = UDim.new(
					data._config.ContentWidth.Scale / p2,
					(data._config.ContentWidth.Offset - data._config.ItemInnerSpacing.X * (p2 - 1)) / p2
				)
				local udim2 = UDim.new(
					udim.Scale * (p2 - 1),
					udim.Offset * (p2 - 1) + data._config.ItemInnerSpacing.X * (p2 - 1)
				)
				local v15 = data._config.ContentWidth - udim2

				for i = 1, p2 do
					local textButton = Instance.new("TextButton")
					textButton.Name = "SliderField" .. tostring(i)
					textButton.LayoutOrder = i

					if i == p2 then
						textButton.Size = UDim2.new(v15, data._config.ContentHeight)
					else
						textButton.Size = UDim2.new(udim, data._config.ContentHeight)
					end

					textButton.AutomaticSize = Enum.AutomaticSize.Y
					textButton.BackgroundColor3 = data._config.FrameBgColor
					textButton.BackgroundTransparency = data._config.FrameBgTransparency
					textButton.AutoButtonColor = false
					textButton.Text = ""
					textButton.ClipsDescendants = true

					data2.applyFrameStyle(textButton)
					data2.applyTextStyle(textButton)
					data2.UISizeConstraint(textButton, Vector2.xAxis)

					textButton.Parent = frame

					local overlayText = Instance.new("TextLabel")
					overlayText.Name = "OverlayText"
					overlayText.Size = UDim2.fromScale(1, 1)
					overlayText.BackgroundTransparency = 1
					overlayText.BorderSizePixel = 0
					overlayText.ZIndex = 10
					overlayText.ClipsDescendants = true

					data2.applyTextStyle(overlayText)

					overlayText.TextXAlignment = Enum.TextXAlignment.Center

					overlayText.Parent = textButton

					data2.applyInteractionHighlights("Background", textButton, textButton, {
						Color = data._config.FrameBgColor,
						Transparency = data._config.FrameBgTransparency,
						HoveredColor = data._config.FrameBgHoveredColor,
						HoveredTransparency = data._config.FrameBgHoveredTransparency,
						ActiveColor = data._config.FrameBgActiveColor,
						ActiveTransparency = data._config.FrameBgActiveTransparency
					})

					local inputField = Instance.new("TextBox")
					inputField.Name = "InputField"
					inputField.Size = UDim2.new(1, 0, 1, 0)
					inputField.BackgroundTransparency = 1
					inputField.ClearTextOnFocus = false
					inputField.TextTruncate = Enum.TextTruncate.AtEnd
					inputField.ClipsDescendants = true
					inputField.Visible = false

					data2.applyFrameStyle(inputField, true)
					data2.applyTextStyle(inputField)

					inputField.Parent = textButton

					inputField.FocusLost:Connect(function()
						local v16 = tonumber(inputField.Text:match("-?%d*%.?%d*"))

						if v16 ~= nil then
							if state.arguments.Min ~= nil then
								v16 = math.max(v16, getValueByIndex(state.arguments.Min, i, state.arguments))
							end

							if state.arguments.Max ~= nil then
								v16 = math.min(v16, getValueByIndex(state.arguments.Max, i, state.arguments))
							end

							if state.arguments.Increment then
								v16 = math.round(v16 / getValueByIndex(state.arguments.Increment, i, state.arguments)) * getValueByIndex(
									state.arguments.Increment,
									i,
									state.arguments
								)
							end

							state.state.number:set(updateValueByIndex(state.state.number.value, i, v16, state.arguments))
							state.lastNumberChangedTick = data._cycleTick + 1
						end

						local v17 = state.arguments.Format[i] or state.arguments.Format[1]

						if state.arguments.Prefix then
							v17 = state.arguments.Prefix[i] .. v17
						end

						inputField.Text = string.format(
							v17,
							getValueByIndex(state.state.number.value, i, state.arguments)
						)

						state.state.editingText:set(0)
						inputField:ReleaseFocus(true)
					end)

					inputField.Focused:Connect(function()
						inputField.CursorPosition = #inputField.Text + 1
						inputField.SelectionStart = 1

						state.state.editingText:set(i)
					end)

					data2.applyButtonDown(textButton, function()
						SliderMouseDown(state, p, i)
					end)

					local grabBar = Instance.new("Frame")
					grabBar.Name = "GrabBar"
					grabBar.ZIndex = 5
					grabBar.AnchorPoint = Vector2.new(0.5, 0.5)
					grabBar.Position = UDim2.new(0, 0, 0.5, 0)
					grabBar.BorderSizePixel = 0
					grabBar.BackgroundColor3 = data._config.SliderGrabColor
					grabBar.Transparency = data._config.SliderGrabTransparency

					if data._config.GrabRounding > 0 then
						data2.UICorner(grabBar, data._config.GrabRounding)
					end

					data2.UISizeConstraint(grabBar, Vector2.new(data._config.GrabMinSize, 0))

					grabBar.Parent = textButton
				end

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.LayoutOrder = 5
				textLabel.AutomaticSize = Enum.AutomaticSize.XY

				data2.applyTextStyle(textLabel)

				textLabel.Parent = frame

				return frame
			end,
			Update = function(data3)
				local instance = data3.Instance
				instance.TextLabel.Text = data3.arguments.Text or `Slider {p}`

				if data3.arguments.Format and typeof(data3.arguments.Format) ~= "table" then
					data3.arguments.Format = { data3.arguments.Format }
				elseif not data3.arguments.Format then
					local format = {}

					for i = 1, p2 do
						local v15 = v5[p][i]

						if data3.arguments.Increment then
							local valueByIndex = getValueByIndex(data3.arguments.Increment, i, data3.arguments)
							v15 = math.max(v15, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v15)
						end

						if data3.arguments.Max then
							local valueByIndex = getValueByIndex(data3.arguments.Max, i, data3.arguments)
							v15 = math.max(v15, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v15)
						end

						if data3.arguments.Min then
							local valueByIndex = getValueByIndex(data3.arguments.Min, i, data3.arguments)
							v15 = math.max(v15, math.ceil(-math.log10(valueByIndex == 0 and 1 or valueByIndex)), v15)
						end

						if v15 > 0 then
							format[i] = `%.{v15}f`
						else
							format[i] = "%d"
						end
					end

					data3.arguments.Format = format
					data3.arguments.Prefix = v4[p]
				end

				for i = 1, p2 do
					local grabBar = instance:FindFirstChild("SliderField" .. tostring(i)).GrabBar

					local v15 = data3.arguments.Increment
						and getValueByIndex(data3.arguments.Increment, i, data3.arguments)
						or v[p][i]
					local v16 = data3.arguments.Min and getValueByIndex(data3.arguments.Min, i, data3.arguments)
						or v2[p][i]
					local v17 = 1 / math.floor(((data3.arguments.Max and getValueByIndex(data3.arguments.Max, i, data3.arguments) or v3[p][i]) + 1 - v16) / v15)

					grabBar.Size = UDim2.new(v17, 0, 1, 0)
				end

				local v15 = #data._postCycleCallbacks + 1
				local v16 = data._cycleTick + 1
				data._postCycleCallbacks[v15] = function()
					if v16 <= data._cycleTick then
						if data3.lastCycleTick ~= -1 then
							data3.state.number.lastChangeTick = data._cycleTick
							data._widgets[`Slider{p}`].UpdateState(data3)
						end

						data._postCycleCallbacks[v15] = nil
					end
				end
			end,
			Discard = function(p4)
				p4.Instance:Destroy()
				data2.discardState(p4)
			end,
			GenerateState = function(p4)
				if p4.state.number == nil then
					p4.state.number = data._widgetState(p4, "number", p3)
				end

				if p4.state.editingText == nil then
					p4.state.editingText = data._widgetState(p4, "editingText", false)
				end
			end,
			UpdateState = function(data3)
				local instance = data3.Instance

				for i = 1, p2 do
					local child = instance:FindFirstChild("SliderField" .. tostring(i))
					local inputField = child.InputField
					local overlayText = child.OverlayText
					local grabBar = child.GrabBar

					local valueByIndex = getValueByIndex(data3.state.number.value, i, data3.arguments)
					local v15 = data3.arguments.Format[i] or data3.arguments.Format[1]

					if data3.arguments.Prefix then
						v15 = data3.arguments.Prefix[i] .. v15
					end

					overlayText.Text = string.format(v15, valueByIndex)
					inputField.Text = tostring(valueByIndex)

					local v16 = data3.arguments.Increment
						and getValueByIndex(data3.arguments.Increment, i, data3.arguments)
						or v[p][i]
					local v17 = data3.arguments.Min and getValueByIndex(data3.arguments.Min, i, data3.arguments)
						or v2[p][i]
					local v18 = data3.arguments.Max and getValueByIndex(data3.arguments.Max, i, data3.arguments)
						or v3[p][i]

					local x = child.AbsoluteSize.X
					local v19 = x - grabBar.AbsoluteSize.X
					local v20 = (valueByIndex - v17) / (v18 - v17)
					local v21 = math.floor((v18 - v17) / v16)
					local v22 = math.clamp(math.floor(v20 * v21) / v21, 0, 1)
					local v23 = v19 / x * v22 + (1 - v19 / x) / 2

					grabBar.Position = UDim2.new(v23, 0, 0.5, 0)

					if data3.state.editingText.value == i then
						inputField.Visible = true
						overlayText.Visible = false
						grabBar.Visible = false
						inputField:CaptureFocus()
					else
						inputField.Visible = false
						overlayText.Visible = true
						grabBar.Visible = true
					end
				end
			end
		}
	end

	local function generateEnumSliderScalar(object, p)
		local v15 = generateSliderScalar("Enum", 1, p.Value)
		local v16 = { string }

		for _, v17 in object:GetEnumItems() do
			v16[v17.Value] = v17.Name
		end

		return data2.extend(v15, {
			Args = { Text = 1 },
			Update = function(p2)
				local instance = p2.Instance
				instance.TextLabel.Text = p2.arguments.Text or "Input Enum"

				p2.arguments.Increment = 1
				p2.arguments.Min = 0
				p2.arguments.Max = #object:GetEnumItems() - 1

				local grabBar = instance:FindFirstChild("SliderField1").GrabBar

				local v17 = 1 / math.floor(#object:GetEnumItems())

				grabBar.Size = UDim2.new(v17, 0, 1, 0)
			end,
			GenerateState = function(p2)
				if p2.state.number == nil then
					p2.state.number = data._widgetState(p2, "number", p.Value)
				end

				if p2.state.enumItem == nil then
					p2.state.enumItem = data._widgetState(p2, "enumItem", p)
				end

				if p2.state.editingText == nil then
					p2.state.editingText = data._widgetState(p2, "editingText", false)
				end
			end
		})
	end

	local v15 = generateInputScalar("Num", 1, 0)
	v15.Args.NoButtons = 6
	data.WidgetConstructor("InputNum", v15)

	data.WidgetConstructor("InputVector2", generateInputScalar("Vector2", 2, Vector2.zero))
	data.WidgetConstructor("InputVector3", generateInputScalar("Vector3", 3, Vector3.new(0, 0, 0)))
	data.WidgetConstructor("InputUDim", generateInputScalar("UDim", 2, UDim.new()))
	data.WidgetConstructor("InputUDim2", generateInputScalar("UDim2", 4, UDim2.new()))
	data.WidgetConstructor("InputRect", generateInputScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

	data.WidgetConstructor("DragNum", generateDragScalar("Num", 1, 0))
	data.WidgetConstructor("DragVector2", generateDragScalar("Vector2", 2, Vector2.zero))
	data.WidgetConstructor("DragVector3", generateDragScalar("Vector3", 3, Vector3.new(0, 0, 0)))
	data.WidgetConstructor("DragUDim", generateDragScalar("UDim", 2, UDim.new()))
	data.WidgetConstructor("DragUDim2", generateDragScalar("UDim2", 4, UDim2.new()))
	data.WidgetConstructor("DragRect", generateDragScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

	data.WidgetConstructor("InputColor3", generateColorDragScalar("Color3", Color3.fromRGB(0, 0, 0)))
	data.WidgetConstructor("InputColor4", generateColorDragScalar("Color4", Color3.fromRGB(0, 0, 0), 0))

	data.WidgetConstructor("SliderNum", generateSliderScalar("Num", 1, 0))
	data.WidgetConstructor("SliderVector2", generateSliderScalar("Vector2", 2, Vector2.zero))
	data.WidgetConstructor("SliderVector3", generateSliderScalar("Vector3", 3, Vector3.new(0, 0, 0)))
	data.WidgetConstructor("SliderUDim", generateSliderScalar("UDim", 2, UDim.new()))
	data.WidgetConstructor("SliderUDim2", generateSliderScalar("UDim2", 4, UDim2.new()))
	data.WidgetConstructor("SliderRect", generateSliderScalar("Rect", 4, Rect.new(0, 0, 0, 0)))

	data.WidgetConstructor("InputText", {
		hasState = true,
		hasChildren = false,
		Args = { Text = 1, TextHint = 2, ReadOnly = 3, MultiLine = 4 },
		Events = {
			textChanged = {
				Init = function(p)
					p.lastTextChangedTick = 0
				end,
				Get = function(p): boolean
					return p.lastTextChangedTick == data._cycleTick
				end
			},
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			local iris_InputText = Instance.new("Frame")
			iris_InputText.Name = "Iris_InputText"
			iris_InputText.AutomaticSize = Enum.AutomaticSize.Y
			iris_InputText.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			iris_InputText.BackgroundTransparency = 1
			iris_InputText.BorderSizePixel = 0
			iris_InputText.ZIndex = state.ZIndex
			iris_InputText.LayoutOrder = state.ZIndex
			local uiListLayout = data2.UIListLayout(
				iris_InputText,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local inputField = Instance.new("TextBox")
			inputField.Name = "InputField"
			inputField.Size = UDim2.new(data._config.ContentWidth, data._config.ContentHeight)
			inputField.AutomaticSize = Enum.AutomaticSize.Y
			inputField.BackgroundColor3 = data._config.FrameBgColor
			inputField.BackgroundTransparency = data._config.FrameBgTransparency
			inputField.Text = ""
			inputField.TextYAlignment = Enum.TextYAlignment.Top
			inputField.PlaceholderColor3 = data._config.TextDisabledColor
			inputField.ClearTextOnFocus = false
			inputField.ClipsDescendants = true

			data2.applyFrameStyle(inputField)
			data2.applyTextStyle(inputField)
			data2.UISizeConstraint(inputField, Vector2.xAxis)

			inputField.Parent = iris_InputText

			inputField.FocusLost:Connect(function()
				state.state.text:set(inputField.Text)
				state.lastTextChangedTick = data._cycleTick + 1
			end)

			local v16 = data._config.TextSize + 2 * data._config.FramePadding.Y

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, v16)
			textLabel.AutomaticSize = Enum.AutomaticSize.X
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.LayoutOrder = 1

			data2.applyTextStyle(textLabel)

			textLabel.Parent = iris_InputText

			return iris_InputText
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local inputField = instance.InputField

			textLabel.Text = p.arguments.Text or "Input Text"
			inputField.PlaceholderText = p.arguments.TextHint or ""
			inputField.TextEditable = not p.arguments.ReadOnly
			inputField.MultiLine = p.arguments.MultiLine or false
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.text == nil then
				p.state.text = data._widgetState(p, "text", "")
			end
		end,
		UpdateState = function(p)
			p.Instance.InputField.Text = p.state.text.value
		end
	})
end