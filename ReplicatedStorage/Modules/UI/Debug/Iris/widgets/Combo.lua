require(script.Parent.Parent.Types)

return function(data, data2)
	data.WidgetConstructor("Selectable", {
		hasState = true,
		hasChildren = false,
		Args = { Text = 1, Index = 2, NoClick = 3 },
		Events = {
			selected = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastSelectedTick == data._cycleTick
				end
			},
			unselected = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastUnselectedTick == data._cycleTick
				end
			},
			active = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.state.index.value == p.arguments.Index
				end
			},
			["clicked"] = data2.EVENTS.click(function(p)
				return p.Instance.SelectableButton
			end),
			rightClicked = data2.EVENTS.rightClick(function(p)
				return p.Instance.SelectableButton
			end),
			doubleClicked = data2.EVENTS.doubleClick(function(p)
				return p.Instance.SelectableButton
			end),
			ctrlClicked = data2.EVENTS.ctrlClick(function(p)
				return p.Instance.SelectableButton
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance.SelectableButton
			end)
		},
		Generate = function(state)
			local iris_Selectable = Instance.new("Frame")
			iris_Selectable.Name = "Iris_Selectable"
			iris_Selectable.Size = UDim2.new(
				data._config.ItemWidth,
				UDim.new(0, data._config.TextSize + 2 * data._config.FramePadding.Y - data._config.ItemSpacing.Y)
			)
			iris_Selectable.BackgroundTransparency = 1
			iris_Selectable.BorderSizePixel = 0
			iris_Selectable.ZIndex = 0
			iris_Selectable.LayoutOrder = state.ZIndex

			local selectableButton = Instance.new("TextButton")
			selectableButton.Name = "SelectableButton"
			selectableButton.Size = UDim2.new(1, 0, 0, data._config.TextSize + 2 * data._config.FramePadding.Y)
			selectableButton.Position = UDim2.fromOffset(0, -bit32.rshift(data._config.ItemSpacing.Y, 1))
			selectableButton.BackgroundColor3 = data._config.HeaderColor
			selectableButton.ClipsDescendants = true

			data2.applyFrameStyle(selectableButton)
			data2.applyTextStyle(selectableButton)
			data2.UISizeConstraint(selectableButton, Vector2.xAxis)

			state.ButtonColors = {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			}

			data2.applyInteractionHighlights("Background", selectableButton, selectableButton, state.ButtonColors)

			data2.applyButtonClick(selectableButton, function()
				if state.arguments.NoClick ~= true then
					if type(state.state.index.value) == "boolean" then
						state.state.index:set(not state.state.index.value)
					else
						state.state.index:set(state.arguments.Index)
					end
				end
			end)

			selectableButton.Parent = iris_Selectable

			return iris_Selectable
		end,
		Update = function(p)
			p.Instance.SelectableButton.Text = p.arguments.Text or "Selectable"
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				if p.arguments.Index ~= nil then
					error("A shared state index is required for Iris.Selectables() with an Index argument.", 5)
				end

				p.state.index = data._widgetState(p, "index", false)
			end
		end,
		UpdateState = function(state)
			local selectableButton = state.Instance.SelectableButton

			if state.state.index.value == (state.arguments.Index or true) then
				state.ButtonColors.Transparency = data._config.HeaderTransparency
				selectableButton.BackgroundTransparency = data._config.HeaderTransparency
				state.lastSelectedTick = data._cycleTick + 1
			else
				state.ButtonColors.Transparency = 1
				selectableButton.BackgroundTransparency = 1
				state.lastUnselectedTick = data._cycleTick + 1
			end
		end
	})

	local flag = false
	local v = -1
	local v2 = nil
	local v3 = 0

	local function UpdateChildContainerTransform(data3)
		local previewContainer = data3.Instance.PreviewContainer
		local childContainer = data3.ChildContainer

		local v4 = previewContainer.AbsolutePosition - data2.GuiOffset
		local absoluteSize = previewContainer.AbsoluteSize
		local popupBorderSize = data._config.PopupBorderSize
		local absoluteSize2 = childContainer.Parent.AbsoluteSize

		local y = data3.UIListLayout.AbsoluteContentSize.Y
		v3 = y

		local v5 = y + 2 * data._config.WindowPadding.Y

		local x = v4.X
		local v6 = v4.Y + absoluteSize.Y + popupBorderSize
		local anchorPoint = Vector2.zero
		local v7 = absoluteSize2.Y - v6

		if v7 < v5 and absoluteSize2.Y / 2 < v6 then
			v6 = v4.Y - popupBorderSize
			anchorPoint = Vector2.yAxis
			v7 = v6
		end

		childContainer.AnchorPoint = anchorPoint
		childContainer.Position = UDim2.fromOffset(x, v6)

		local v8 = math.min(v5, v7)
		childContainer.Size = UDim2.fromOffset(previewContainer.AbsoluteSize.X, v8)
	end

	table.insert(data._postCycleCallbacks, function()
		if flag and v2 and v2.UIListLayout.AbsoluteContentSize.Y ~= v3 then
			UpdateChildContainerTransform(v2)
		end
	end)

	local function UpdateComboState(p)
		if
			not data._started
			or p.UserInputType ~= Enum.UserInputType.MouseButton1
			and p.UserInputType ~= Enum.UserInputType.MouseButton2
			and p.UserInputType ~= Enum.UserInputType.Touch
			and p.UserInputType ~= Enum.UserInputType.MouseWheel
		then
			return
		end

		if flag == false or not v2 or v == data._cycleTick then
			return
		end

		local mouseLocation = data2.getMouseLocation()
		local previewContainer = v2.Instance.PreviewContainer
		local childContainer = v2.ChildContainer
		local v4 = previewContainer.AbsolutePosition - data2.GuiOffset
		local v5 = previewContainer.AbsolutePosition - data2.GuiOffset + previewContainer.AbsoluteSize

		if data2.isPosInsideRect(mouseLocation, v4, v5) then
			return
		end

		local v6 = childContainer.AbsolutePosition - data2.GuiOffset
		local v7 = childContainer.AbsolutePosition - data2.GuiOffset + childContainer.AbsoluteSize

		if data2.isPosInsideRect(mouseLocation, v6, v7) then
			return
		end

		v2.state.isOpened:set(false)
	end

	data2.registerEvent("InputBegan", UpdateComboState)

	data2.registerEvent("InputChanged", UpdateComboState)

	data.WidgetConstructor("Combo", {
		hasState = true,
		hasChildren = true,
		Args = { Text = 1, NoButton = 2, NoPreview = 3 },
		Events = {
			opened = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastOpenedTick == data._cycleTick
				end
			},
			closed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastClosedTick == data._cycleTick
				end
			},
			changed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastChangedTick == data._cycleTick
				end
			},
			["clicked"] = data2.EVENTS.click(function(p)
				return p.Instance.PreviewContainer
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			local v4 = data._config.TextSize + 2 * data._config.FramePadding.Y

			local iris_Combo = Instance.new("Frame")
			iris_Combo.Name = "Iris_Combo"
			iris_Combo.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			iris_Combo.AutomaticSize = Enum.AutomaticSize.Y
			iris_Combo.BackgroundTransparency = 1
			iris_Combo.BorderSizePixel = 0
			iris_Combo.LayoutOrder = state.ZIndex

			local uiListLayout_2 = data2.UIListLayout(
				iris_Combo,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

			local previewContainer = Instance.new("TextButton")
			previewContainer.Name = "PreviewContainer"
			previewContainer.Size = UDim2.new(data._config.ContentWidth, UDim.new(0, 0))
			previewContainer.AutomaticSize = Enum.AutomaticSize.Y
			previewContainer.BackgroundTransparency = 1
			previewContainer.Text = ""
			previewContainer.ZIndex = state.ZIndex + 2
			previewContainer.AutoButtonColor = false

			data2.applyFrameStyle(previewContainer, true)
			data2.UIListLayout(previewContainer, Enum.FillDirection.Horizontal, UDim.new(0, 0))
			data2.UISizeConstraint(previewContainer, Vector2.new(v4))

			previewContainer.Parent = iris_Combo

			local previewLabel = Instance.new("TextLabel")
			previewLabel.Name = "PreviewLabel"
			previewLabel.Size = UDim2.new(UDim.new(1, 0), data._config.ContentHeight)
			previewLabel.AutomaticSize = Enum.AutomaticSize.Y
			previewLabel.BackgroundColor3 = data._config.FrameBgColor
			previewLabel.BackgroundTransparency = data._config.FrameBgTransparency
			previewLabel.BorderSizePixel = 0
			previewLabel.ClipsDescendants = true

			data2.applyTextStyle(previewLabel)
			data2.UIPadding(previewLabel, data._config.FramePadding)

			previewLabel.Parent = previewContainer

			local dropdownButton = Instance.new("TextLabel")
			dropdownButton.Name = "DropdownButton"
			dropdownButton.Size = UDim2.new(
				0,
				v4,
				data._config.ContentHeight.Scale,
				(math.max(data._config.ContentHeight.Offset, v4))
			)
			dropdownButton.BorderSizePixel = 0
			dropdownButton.BackgroundColor3 = data._config.ButtonColor
			dropdownButton.BackgroundTransparency = data._config.ButtonTransparency
			dropdownButton.Text = ""

			local v5 = v4 - math.round(v4 * 0.2) * 2

			local dropdown = Instance.new("ImageLabel")
			dropdown.Name = "Dropdown"
			dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
			dropdown.Size = UDim2.fromOffset(v5, v5)
			dropdown.Position = UDim2.fromScale(0.5, 0.5)
			dropdown.BackgroundTransparency = 1
			dropdown.BorderSizePixel = 0
			dropdown.ImageColor3 = data._config.TextColor
			dropdown.ImageTransparency = data._config.TextTransparency

			dropdown.Parent = dropdownButton

			dropdownButton.Parent = previewContainer

			data2.applyInteractionHighlightsWithMultiHighlightee("Background", previewContainer, {
				{
					previewLabel,
					{
						Color = data._config.FrameBgColor,
						Transparency = data._config.FrameBgTransparency,
						HoveredColor = data._config.FrameBgHoveredColor,
						HoveredTransparency = data._config.FrameBgHoveredTransparency,
						ActiveColor = data._config.FrameBgActiveColor,
						ActiveTransparency = data._config.FrameBgActiveTransparency
					}
				},
				{
					dropdownButton,
					{
						Color = data._config.ButtonColor,
						Transparency = data._config.ButtonTransparency,
						HoveredColor = data._config.ButtonHoveredColor,
						HoveredTransparency = data._config.ButtonHoveredTransparency,
						ActiveColor = data._config.ButtonHoveredColor,
						ActiveTransparency = data._config.ButtonHoveredTransparency
					}
				}
			})

			data2.applyButtonClick(previewContainer, function()
				if flag and v2 ~= state then
					return
				end

				state.state.isOpened:set(not state.state.isOpened.value)
			end)

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, v4)
			textLabel.AutomaticSize = Enum.AutomaticSize.X
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0

			data2.applyTextStyle(textLabel)

			textLabel.Parent = iris_Combo

			local comboContainer = Instance.new("ScrollingFrame")
			comboContainer.Name = "ComboContainer"
			comboContainer.BackgroundColor3 = data._config.PopupBgColor
			comboContainer.BackgroundTransparency = data._config.PopupBgTransparency
			comboContainer.BorderSizePixel = 0

			comboContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
			comboContainer.ScrollBarImageTransparency = data._config.ScrollbarGrabTransparency
			comboContainer.ScrollBarImageColor3 = data._config.ScrollbarGrabColor
			comboContainer.ScrollBarThickness = data._config.ScrollbarSize
			comboContainer.CanvasSize = UDim2.fromScale(0, 0)
			comboContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			comboContainer.TopImage = data2.ICONS.BLANK_SQUARE
			comboContainer.MidImage = data2.ICONS.BLANK_SQUARE
			comboContainer.BottomImage = data2.ICONS.BLANK_SQUARE

			comboContainer.ClipsDescendants = true

			data2.UIStroke(
				comboContainer,
				data._config.WindowBorderSize,
				data._config.BorderColor,
				data._config.BorderTransparency
			)
			data2.UIPadding(comboContainer, Vector2.new(2, data._config.WindowPadding.Y))
			data2.UISizeConstraint(comboContainer, Vector2.new(100))

			local uiListLayout = data2.UIListLayout(
				comboContainer,
				Enum.FillDirection.Vertical,
				UDim.new(0, data._config.ItemSpacing.Y)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

			comboContainer.Parent = data._rootInstance and data._rootInstance:WaitForChild("PopupScreenGui")

			state.ChildContainer = comboContainer
			state.UIListLayout = uiListLayout
			return iris_Combo
		end,
		Update = function(p)
			local instance = p.Instance
			local previewContainer = instance.PreviewContainer
			local previewLabel = previewContainer.PreviewLabel
			local dropdownButton = previewContainer.DropdownButton
			instance.TextLabel.Text = p.arguments.Text or "Combo"

			if p.arguments.NoButton then
				dropdownButton.Visible = false
				previewLabel.Size = UDim2.new(UDim.new(1, 0), previewLabel.Size.Height)
			else
				dropdownButton.Visible = true
				local v4 = data._config.TextSize + 2 * data._config.FramePadding.Y
				previewLabel.Size = UDim2.new(UDim.new(1, -v4), previewLabel.Size.Height)
			end

			if p.arguments.NoPreview then
				previewLabel.Visible = false
				previewContainer.Size = UDim2.new(0, 0, 0, 0)
				previewContainer.AutomaticSize = Enum.AutomaticSize.XY
			else
				previewLabel.Visible = true
				previewContainer.Size = UDim2.new(data._config.ContentWidth, data._config.ContentHeight)
				previewContainer.AutomaticSize = Enum.AutomaticSize.Y
			end
		end,
		ChildAdded = function(p, _)
			UpdateChildContainerTransform(p)
			return p.ChildContainer
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				p.state.index = data._widgetState(p, "index", "No Selection")
			end

			if p.state.isOpened == nil then
				p.state.isOpened = data._widgetState(p, "isOpened", false)
			end

			p.state.index:onChange(function()
				p.lastChangedTick = data._cycleTick + 1

				if p.state.isOpened.value then
					p.state.isOpened:set(false)
				end
			end)
		end,
		UpdateState = function(state)
			local instance = state.Instance
			local childContainer = state.ChildContainer
			local previewContainer = instance.PreviewContainer
			local previewLabel = previewContainer.PreviewLabel
			local dropdown = previewContainer.DropdownButton.Dropdown

			if state.state.isOpened.value then
				flag = true
				v2 = state
				v = data._cycleTick
				state.lastOpenedTick = data._cycleTick + 1

				dropdown.Image = data2.ICONS.RIGHT_POINTING_TRIANGLE
				childContainer.Visible = true

				UpdateChildContainerTransform(state)
			else
				if flag then
					flag = false
					v2 = nil
					state.lastClosedTick = data._cycleTick + 1
				end

				dropdown.Image = data2.ICONS.DOWN_POINTING_TRIANGLE
				childContainer.Visible = false
			end

			local value = state.state.index.value
			local text

			if typeof(value) == "EnumItem" then
				text = value.Name
			else
				text = tostring(value)
			end

			previewLabel.Text = text
		end,
		Discard = function(p)
			if v2 and v2 == p then
				v2 = nil
				flag = false
			end

			p.Instance:Destroy()
			p.ChildContainer:Destroy()
			data2.discardState(p)
		end
	})
end