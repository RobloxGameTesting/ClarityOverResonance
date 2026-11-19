require(script.Parent.Parent.Types)

return function(data, data2)
	local function openTab(parentWidget, index: number) -- 1 equivalent call inferred from this helper
		if parentWidget.state.index.value > 0 then
			return
		end

		parentWidget.state.index:set(index)
	end

	local function closeTab(p, index: number)
		if p.state.index.value ~= index then
			return
		end

		for i = index - 1, 1, -1 do
			if p.Tabs[i].state.isOpened.value == true then
				p.state.index:set(i)
				return
			end
		end

		for i = index, #p.Tabs do
			if p.Tabs[i].state.isOpened.value == true then
				p.state.index:set(i)
				return
			end
		end

		p.state.index:set(0)
	end

	data.WidgetConstructor("TabBar", {
		hasState = true,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(p)
			local iris_TabBar = Instance.new("Frame")
			iris_TabBar.Name = "Iris_TabBar"
			iris_TabBar.AutomaticSize = Enum.AutomaticSize.Y
			iris_TabBar.Size = UDim2.fromScale(1, 0)
			iris_TabBar.BackgroundTransparency = 1
			iris_TabBar.BorderSizePixel = 0
			iris_TabBar.LayoutOrder = p.ZIndex

			local uiListLayout = data2.UIListLayout(iris_TabBar, Enum.FillDirection.Vertical, UDim.new())
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

			local bar = Instance.new("Frame")
			bar.Name = "Bar"
			bar.AutomaticSize = Enum.AutomaticSize.Y
			bar.Size = UDim2.fromScale(1, 0)
			bar.BackgroundTransparency = 1
			bar.BorderSizePixel = 0

			data2.UIListLayout(bar, Enum.FillDirection.Horizontal, UDim.new(0, data._config.ItemInnerSpacing.X))

			bar.Parent = iris_TabBar

			local underline = Instance.new("Frame")
			underline.Name = "Underline"
			underline.Size = UDim2.new(1, 0, 0, 1)
			underline.BackgroundColor3 = data._config.TabActiveColor
			underline.BackgroundTransparency = data._config.TabActiveTransparency
			underline.BorderSizePixel = 0
			underline.LayoutOrder = 1

			underline.Parent = iris_TabBar

			local tabContainer = Instance.new("Frame")
			tabContainer.Name = "TabContainer"
			tabContainer.AutomaticSize = Enum.AutomaticSize.Y
			tabContainer.Size = UDim2.fromScale(1, 0)
			tabContainer.BackgroundTransparency = 1
			tabContainer.BorderSizePixel = 0
			tabContainer.LayoutOrder = 2
			tabContainer.ClipsDescendants = true

			tabContainer.Parent = iris_TabBar

			p.ChildContainer = tabContainer
			p.Tabs = {}

			return iris_TabBar
		end,
		Update = function(_) end,
		ChildAdded = function(data3, state)
			assert(state.type == "Tab", "Only Iris.Tab can be parented to Iris.TabBar.")
			local instance = data3.Instance
			state.ChildContainer.Parent = data3.ChildContainer
			state.Index = #data3.Tabs + 1
			data3.state.index.ConnectedWidgets[state.ID] = state
			table.insert(data3.Tabs, state)

			return instance.Bar
		end,
		ChildDiscarded = function(p, p2)
			local index = p2.Index
			table.remove(p.Tabs, index)

			for i = index, #p.Tabs do
				p.Tabs[i].Index = i
			end

			closeTab(p, index)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				p.state.index = data._widgetState(p, "index", 1)
			end
		end,
		UpdateState = function(_) end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})

	data.WidgetConstructor("Tab", {
		hasState = true,
		hasChildren = true,
		Args = { Text = 1, Hideable = 2 },
		Events = {
			["clicked"] = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end),
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
					return p.state.index.value == p.Index
				end
			},
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
			}
		},
		Generate = function(state)
			local iris_Tab = Instance.new("TextButton")
			iris_Tab.Name = "Iris_Tab"
			iris_Tab.AutomaticSize = Enum.AutomaticSize.XY
			iris_Tab.BackgroundColor3 = data._config.TabColor
			iris_Tab.BackgroundTransparency = data._config.TabTransparency
			iris_Tab.BorderSizePixel = 0
			iris_Tab.Text = ""
			iris_Tab.AutoButtonColor = false

			state.ButtonColors = {
				Color = data._config.TabColor,
				Transparency = data._config.TabTransparency,
				HoveredColor = data._config.TabHoveredColor,
				HoveredTransparency = data._config.TabHoveredTransparency,
				ActiveColor = data._config.TabActiveColor,
				ActiveTransparency = data._config.TabActiveTransparency
			}

			data2.UIPadding(iris_Tab, Vector2.new(data._config.FramePadding.X, 0))
			data2.applyFrameStyle(iris_Tab, true, true)
			local uiListLayout = data2.UIListLayout(
				iris_Tab,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyInteractionHighlights("Background", iris_Tab, iris_Tab, state.ButtonColors)
			data2.applyButtonClick(iris_Tab, function()
				state.state.index:set(state.Index)
			end)

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0

			data2.applyTextStyle(textLabel)
			data2.UIPadding(textLabel, Vector2.new(0, data._config.FramePadding.Y))

			textLabel.Parent = iris_Tab

			local v = data._config.TextSize + (data._config.FramePadding.Y - 1) * 2

			local closeButton = Instance.new("TextButton")
			closeButton.Name = "CloseButton"
			closeButton.BackgroundTransparency = 1
			closeButton.BorderSizePixel = 0
			closeButton.LayoutOrder = 1
			closeButton.Size = UDim2.fromOffset(v, v)
			closeButton.Text = ""
			closeButton.AutoButtonColor = false

			data2.UICorner(closeButton)
			data2.applyButtonClick(closeButton, function()
				state.state.isOpened:set(false)
				closeTab(state.parentWidget, state.Index)
			end)

			data2.applyInteractionHighlights("Background", closeButton, closeButton, {
				Color = data._config.TabColor,
				Transparency = 1,
				HoveredColor = data._config.ButtonHoveredColor,
				HoveredTransparency = data._config.ButtonHoveredTransparency,
				ActiveColor = data._config.ButtonActiveColor,
				ActiveTransparency = data._config.ButtonActiveTransparency
			})

			closeButton.Parent = iris_Tab

			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.BorderSizePixel = 0
			icon.Image = data2.ICONS.MULTIPLICATION_SIGN
			icon.ImageTransparency = 1
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.Size = UDim2.fromOffset(math.floor(v * 0.7), (math.floor(v * 0.7)))

			data2.applyInteractionHighlights("Image", iris_Tab, icon, {
				Color = data._config.TextColor,
				Transparency = 1,
				HoveredColor = data._config.TextColor,
				HoveredTransparency = data._config.TextTransparency,
				ActiveColor = data._config.TextColor,
				ActiveTransparency = data._config.TextTransparency
			})

			icon.Parent = closeButton

			local tabContainer = Instance.new("Frame")
			tabContainer.Name = "TabContainer"
			tabContainer.AutomaticSize = Enum.AutomaticSize.Y
			tabContainer.Size = UDim2.fromScale(1, 0)
			tabContainer.BackgroundTransparency = 1
			tabContainer.BorderSizePixel = 0

			tabContainer.ClipsDescendants = true
			data2.UIListLayout(tabContainer, Enum.FillDirection.Vertical, UDim.new(0, data._config.ItemSpacing.Y))
			local uiPadding = data2.UIPadding(tabContainer, Vector2.new(0, data._config.ItemSpacing.Y))
			uiPadding.PaddingBottom = UDim.new()

			state.ChildContainer = tabContainer

			return iris_Tab
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local closeButton = instance.CloseButton

			textLabel.Text = p.arguments.Text
			closeButton.Visible = p.arguments.Hideable == true
		end,
		ChildAdded = function(p, _)
			return p.ChildContainer
		end,
		GenerateState = function(data3)
			data3.state.index = data3.parentWidget.state.index
			data3.state.index.ConnectedWidgets[data3.ID] = data3

			if data3.state.isOpened == nil then
				data3.state.isOpened = data._widgetState(data3, "isOpened", true)
			end
		end,
		UpdateState = function(state)
			local instance = state.Instance
			local childContainer = state.ChildContainer

			if state.state.isOpened.lastChangeTick == data._cycleTick then
				if state.state.isOpened.value == true then
					state.lastOpenedTick = data._cycleTick + 1
					openTab(state.parentWidget, state.Index) -- inferred equivalent call
					instance.Visible = true
				else
					state.lastClosedTick = data._cycleTick + 1
					closeTab(state.parentWidget, state.Index)
					instance.Visible = false
				end
			end

			if state.state.index.lastChangeTick == data._cycleTick then
				if state.state.index.value == state.Index then
					state.ButtonColors.Color = data._config.TabActiveColor
					state.ButtonColors.Transparency = data._config.TabActiveTransparency
					instance.BackgroundColor3 = data._config.TabActiveColor
					instance.BackgroundTransparency = data._config.TabActiveTransparency
					childContainer.Visible = true
					state.lastSelectedTick = data._cycleTick + 1
				else
					state.ButtonColors.Color = data._config.TabColor
					state.ButtonColors.Transparency = data._config.TabTransparency
					instance.BackgroundColor3 = data._config.TabColor
					instance.BackgroundTransparency = data._config.TabTransparency
					childContainer.Visible = false
					state.lastUnselectedTick = data._cycleTick + 1
				end
			end
		end,
		Discard = function(data3)
			if data3.state.isOpened.value == true then
				closeTab(data3.parentWidget, data3.Index)
			end

			data3.Instance:Destroy()
			data3.ChildContainer:Destroy()
			data2.discardState(data3)
		end
	})
end