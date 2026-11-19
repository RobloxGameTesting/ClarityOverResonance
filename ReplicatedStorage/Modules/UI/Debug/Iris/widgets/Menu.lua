require(script.Parent.Parent.Types)

return function(data, data2)
	local v = false
	local v2 = nil
	local states = {}

	local function EmptyMenuStack(p: number?)
		for i = #states, p and p + 1 or 1, -1 do
			local v3 = states[i]
			v3.state.isOpened:set(false)

			v3.Instance.BackgroundColor3 = data._config.HeaderColor
			v3.Instance.BackgroundTransparency = 1

			table.remove(states, i)
		end

		if #states == 0 then
			v = false
			v2 = nil
		end
	end

	local function UpdateChildContainerTransform(data3)
		local v3 = data3.parentWidget.type == "Menu"

		local instance = data3.Instance
		local childContainer = data3.ChildContainer
		childContainer.Size = UDim2.fromOffset(instance.AbsoluteSize.X, 0)

		if childContainer.Parent == nil then
			return
		end

		local v4 = instance.AbsolutePosition - data2.GuiOffset
		local absoluteSize = instance.AbsoluteSize
		local absoluteSize2 = childContainer.AbsoluteSize
		local popupBorderSize = data._config.PopupBorderSize
		local absoluteSize3 = childContainer.Parent.AbsoluteSize

		local v5 = v4.X

		local anchorPoint = Vector2.zero

		if v3 then
			if v4.X + absoluteSize2.X > absoluteSize3.X then
				anchorPoint = Vector2.xAxis
			else
				v5 = v4.X + absoluteSize.X
			end
		end

		local v6

		if v4.Y + absoluteSize2.Y > absoluteSize3.Y then
			v6 = v4.Y - popupBorderSize + (v3 and absoluteSize.Y or 0)
			anchorPoint += Vector2.yAxis
		else
			v6 = v4.Y + popupBorderSize + (v3 and 0 or absoluteSize.Y)
		end

		childContainer.Position = UDim2.fromOffset(v5, v6)
		childContainer.AnchorPoint = anchorPoint
	end

	data2.registerEvent("InputBegan", function(p)
		if
			not data._started
			or p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.MouseButton2
			or v == false
			or v2 == nil
		then
			return
		end

		local mouseLocation = data2.getMouseLocation()
		local flag = false

		for _, v3 in states do
			for _, v4 in { v3.ChildContainer, v3.Instance } do
				local v5 = v4.AbsolutePosition - data2.GuiOffset
				local v6 = v5 + v4.AbsoluteSize

				if data2.isPosInsideRect(mouseLocation, v5, v6) then
					flag = true
					break
				end
			end

			if flag then
				break
			end
		end

		if not flag then
			EmptyMenuStack()
		end
	end)

	data.WidgetConstructor("MenuBar", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(p)
			local iris_MenuBar = Instance.new("Frame")
			iris_MenuBar.Name = "Iris_MenuBar"
			iris_MenuBar.Size = UDim2.fromScale(1, 0)
			iris_MenuBar.AutomaticSize = Enum.AutomaticSize.Y
			iris_MenuBar.BackgroundColor3 = data._config.MenubarBgColor
			iris_MenuBar.BackgroundTransparency = data._config.MenubarBgTransparency
			iris_MenuBar.BorderSizePixel = 0
			iris_MenuBar.LayoutOrder = p.ZIndex
			iris_MenuBar.ClipsDescendants = true

			data2.UIPadding(iris_MenuBar, Vector2.new(data._config.WindowPadding.X, 1))
			local uiListLayout = data2.UIListLayout(iris_MenuBar, Enum.FillDirection.Horizontal, UDim.new())
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			data2.applyFrameStyle(iris_MenuBar, true, true)

			return iris_MenuBar
		end,
		Update = function(_) end,
		ChildAdded = function(p, _)
			return p.Instance
		end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})

	data.WidgetConstructor("Menu", {
		hasState = true,
		hasChildren = true,
		Args = { Text = 1 },
		Events = {
			["clicked"] = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end),
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
			state.ButtonColors = {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderHoveredColor,
				ActiveTransparency = data._config.HeaderHoveredTransparency
			}
			local menu

			if state.parentWidget.type == "Menu" then
				menu = Instance.new("TextButton")
				menu.Name = "Menu"
				menu.BackgroundColor3 = data._config.HeaderColor
				menu.BackgroundTransparency = 1
				menu.BorderSizePixel = 0
				menu.Size = UDim2.fromScale(1, 0)
				menu.Text = ""
				menu.AutomaticSize = Enum.AutomaticSize.Y
				menu.LayoutOrder = state.ZIndex
				menu.AutoButtonColor = false

				local uiPadding = data2.UIPadding(menu, data._config.FramePadding)
				uiPadding.PaddingTop -= UDim.new(0, 1)
				local uiListLayout = data2.UIListLayout(
					menu,
					Enum.FillDirection.Horizontal,
					UDim.new(0, data._config.ItemInnerSpacing.X)
				)
				uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.BackgroundTransparency = 1
				textLabel.BorderSizePixel = 0
				textLabel.AutomaticSize = Enum.AutomaticSize.XY

				data2.applyTextStyle(textLabel)

				textLabel.Parent = menu

				local v3 = data._config.TextSize + 2 * data._config.FramePadding.Y
				local v4 = v3 - math.round(v3 * 0.2) * 2

				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.Size = UDim2.fromOffset(v4, v4)
				icon.BackgroundTransparency = 1
				icon.BorderSizePixel = 0
				icon.ImageColor3 = data._config.TextColor
				icon.ImageTransparency = data._config.TextTransparency
				icon.Image = data2.ICONS.RIGHT_POINTING_TRIANGLE
				icon.LayoutOrder = 1

				icon.Parent = menu
			else
				menu = Instance.new("TextButton")
				menu.Name = "Menu"
				menu.AutomaticSize = Enum.AutomaticSize.XY
				menu.Size = UDim2.fromScale(0, 0)
				menu.BackgroundColor3 = data._config.HeaderColor
				menu.BackgroundTransparency = 1
				menu.BorderSizePixel = 0
				menu.Text = ""
				menu.LayoutOrder = state.ZIndex
				menu.AutoButtonColor = false
				menu.ClipsDescendants = true

				data2.applyTextStyle(menu)
				data2.UIPadding(menu, Vector2.new(data._config.ItemSpacing.X, data._config.FramePadding.Y))
			end

			data2.applyInteractionHighlights("Background", menu, menu, state.ButtonColors)

			data2.applyButtonClick(menu, function()
				local v3 = not (#states <= 1) or not state.state.isOpened.value
				state.state.isOpened:set(v3)

				v = v3
				v2 = v3 and state or nil

				if #states <= 1 then
					if v3 then
						table.insert(states, state)
					else
						table.remove(states)
					end
				end
			end)

			data2.applyMouseEnter(menu, function()
				if v and v2 and v2 ~= state then
					local parentWidget = state.parentWidget
					EmptyMenuStack(table.find(states, parentWidget))
					state.state.isOpened:set(true)
					v2 = state
					v = true
					table.insert(states, state)
				end
			end)

			local menuContainer = Instance.new("ScrollingFrame")
			menuContainer.Name = "MenuContainer"
			menuContainer.BackgroundColor3 = data._config.PopupBgColor
			menuContainer.BackgroundTransparency = data._config.PopupBgTransparency
			menuContainer.BorderSizePixel = 0
			menuContainer.Size = UDim2.fromOffset(0, 0)
			menuContainer.AutomaticSize = Enum.AutomaticSize.XY

			menuContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
			menuContainer.ScrollBarImageTransparency = data._config.ScrollbarGrabTransparency
			menuContainer.ScrollBarImageColor3 = data._config.ScrollbarGrabColor
			menuContainer.ScrollBarThickness = data._config.ScrollbarSize
			menuContainer.CanvasSize = UDim2.fromScale(0, 0)
			menuContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			menuContainer.TopImage = data2.ICONS.BLANK_SQUARE
			menuContainer.MidImage = data2.ICONS.BLANK_SQUARE
			menuContainer.BottomImage = data2.ICONS.BLANK_SQUARE

			menuContainer.ZIndex = 6
			menuContainer.LayoutOrder = 6
			menuContainer.ClipsDescendants = true

			data2.UIStroke(
				menuContainer,
				data._config.WindowBorderSize,
				data._config.BorderColor,
				data._config.BorderTransparency
			)
			data2.UIPadding(menuContainer, Vector2.new(2, data._config.WindowPadding.Y - data._config.ItemSpacing.Y))

			local uiListLayout = data2.UIListLayout(menuContainer, Enum.FillDirection.Vertical, UDim.new(0, 1))
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

			menuContainer.Parent = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")

			state.ChildContainer = menuContainer
			return menu
		end,
		Update = function(data3)
			local v3 = data3.Instance

			if data3.parentWidget.type == "Menu" then
				v3 = v3.TextLabel
			end

			v3.Text = data3.arguments.Text or "Menu"
		end,
		ChildAdded = function(p, _)
			UpdateChildContainerTransform(p)
			return p.ChildContainer
		end,
		ChildDiscarded = function(p, _)
			UpdateChildContainerTransform(p)
		end,
		GenerateState = function(p)
			if p.state.isOpened == nil then
				p.state.isOpened = data._widgetState(p, "isOpened", false)
			end
		end,
		UpdateState = function(state)
			local childContainer = state.ChildContainer

			if state.state.isOpened.value then
				state.lastOpenedTick = data._cycleTick + 1
				state.ButtonColors.Transparency = data._config.HeaderTransparency
				childContainer.Visible = true

				UpdateChildContainerTransform(state)
			else
				state.lastClosedTick = data._cycleTick + 1
				state.ButtonColors.Transparency = 1
				childContainer.Visible = false
			end
		end,
		Discard = function(data3)
			if v then
				local parentWidget = data3.parentWidget
				local index = table.find(states, parentWidget)

				if index then
					EmptyMenuStack(index)

					if #states ~= 0 then
						v2 = parentWidget
						v = true
					end
				end
			end

			data3.Instance:Destroy()
			data3.ChildContainer:Destroy()
			data2.discardState(data3)
		end
	})

	data.WidgetConstructor("MenuItem", {
		hasState = false,
		hasChildren = false,
		Args = { Text = 1, KeyCode = 2, ModifierKey = 3 },
		Events = {
			["clicked"] = data2.EVENTS.click(function(p)
				return p.Instance
			end),
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(p)
			local menuItem = Instance.new("TextButton")
			menuItem.Name = "MenuItem"
			menuItem.BackgroundTransparency = 1
			menuItem.BorderSizePixel = 0
			menuItem.Size = UDim2.fromScale(1, 0)
			menuItem.Text = ""
			menuItem.AutomaticSize = Enum.AutomaticSize.Y
			menuItem.LayoutOrder = p.ZIndex
			menuItem.AutoButtonColor = false

			local uiPadding = data2.UIPadding(menuItem, data._config.FramePadding)
			uiPadding.PaddingTop -= UDim.new(0, 1)
			data2.UIListLayout(menuItem, Enum.FillDirection.Horizontal, UDim.new(0, data._config.ItemInnerSpacing.X))

			data2.applyInteractionHighlights("Background", menuItem, menuItem, {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderHoveredColor,
				ActiveTransparency = data._config.HeaderHoveredTransparency
			})

			data2.applyButtonClick(menuItem, function()
				EmptyMenuStack()
			end)

			data2.applyMouseEnter(menuItem, function()
				local parentWidget = p.parentWidget

				if v and v2 and v2 ~= parentWidget then
					EmptyMenuStack(table.find(states, parentWidget))
					v2 = parentWidget
					v = true
				end
			end)

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.AutomaticSize = Enum.AutomaticSize.XY

			data2.applyTextStyle(textLabel)

			textLabel.Parent = menuItem

			local shortcut = Instance.new("TextLabel")
			shortcut.Name = "Shortcut"
			shortcut.BackgroundTransparency = 1
			shortcut.BorderSizePixel = 0
			shortcut.LayoutOrder = 1
			shortcut.AutomaticSize = Enum.AutomaticSize.XY

			data2.applyTextStyle(shortcut)

			shortcut.Text = ""
			shortcut.TextColor3 = data._config.TextDisabledColor
			shortcut.TextTransparency = data._config.TextDisabledTransparency

			shortcut.Parent = menuItem

			return menuItem
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local shortcut = instance.Shortcut

			textLabel.Text = p.arguments.Text

			if p.arguments.KeyCode then
				if p.arguments.ModifierKey then
					shortcut.Text = p.arguments.ModifierKey.Name .. " + " .. p.arguments.KeyCode.Name
				else
					shortcut.Text = p.arguments.KeyCode.Name
				end
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})

	data.WidgetConstructor("MenuToggle", {
		hasState = true,
		hasChildren = false,
		Args = { Text = 1, KeyCode = 2, ModifierKey = 3 },
		Events = {
			checked = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastCheckedTick == data._cycleTick
				end
			},
			unchecked = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastUncheckedTick == data._cycleTick
				end
			},
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(data3)
			local menuItem = Instance.new("TextButton")
			menuItem.Name = "MenuItem"
			menuItem.BackgroundTransparency = 1
			menuItem.BorderSizePixel = 0
			menuItem.Size = UDim2.fromScale(1, 0)
			menuItem.Text = ""
			menuItem.AutomaticSize = Enum.AutomaticSize.Y
			menuItem.LayoutOrder = data3.ZIndex
			menuItem.AutoButtonColor = false

			local uiPadding = data2.UIPadding(menuItem, data._config.FramePadding)
			uiPadding.PaddingTop -= UDim.new(0, 1)
			local uiListLayout = data2.UIListLayout(
				menuItem,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			data2.applyInteractionHighlights("Background", menuItem, menuItem, {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderHoveredColor,
				ActiveTransparency = data._config.HeaderHoveredTransparency
			})

			data2.applyButtonClick(menuItem, function()
				local value = data3.state.isChecked.value
				data3.state.isChecked:set(not value)
				EmptyMenuStack()
			end)

			data2.applyMouseEnter(menuItem, function()
				local parentWidget = data3.parentWidget

				if v and v2 and v2 ~= parentWidget then
					EmptyMenuStack(table.find(states, parentWidget))
					v2 = parentWidget
					v = true
				end
			end)

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.AutomaticSize = Enum.AutomaticSize.XY

			data2.applyTextStyle(textLabel)

			textLabel.Parent = menuItem

			local shortcut = Instance.new("TextLabel")
			shortcut.Name = "Shortcut"
			shortcut.BackgroundTransparency = 1
			shortcut.BorderSizePixel = 0
			shortcut.LayoutOrder = 1
			shortcut.AutomaticSize = Enum.AutomaticSize.XY

			data2.applyTextStyle(shortcut)

			shortcut.Text = ""
			shortcut.TextColor3 = data._config.TextDisabledColor
			shortcut.TextTransparency = data._config.TextDisabledTransparency

			shortcut.Parent = menuItem

			local v3 = data._config.TextSize + 2 * data._config.FramePadding.Y
			local v4 = v3 - math.round(v3 * 0.2) * 2

			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.Size = UDim2.fromOffset(v4, v4)
			icon.BackgroundTransparency = 1
			icon.BorderSizePixel = 0
			icon.ImageColor3 = data._config.TextColor
			icon.ImageTransparency = data._config.TextTransparency
			icon.Image = data2.ICONS.CHECK_MARK
			icon.LayoutOrder = 2

			icon.Parent = menuItem

			return menuItem
		end,
		GenerateState = function(p)
			if p.state.isChecked == nil then
				p.state.isChecked = data._widgetState(p, "isChecked", false)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local shortcut = instance.Shortcut

			textLabel.Text = p.arguments.Text

			if p.arguments.KeyCode then
				if p.arguments.ModifierKey then
					shortcut.Text = p.arguments.ModifierKey.Name .. " + " .. p.arguments.KeyCode.Name
				else
					shortcut.Text = p.arguments.KeyCode.Name
				end
			end
		end,
		UpdateState = function(state)
			local icon = state.Instance.Icon

			if state.state.isChecked.value then
				icon.Image = data2.ICONS.CHECK_MARK
				state.lastCheckedTick = data._cycleTick + 1
			else
				icon.Image = ""
				state.lastUncheckedTick = data._cycleTick + 1
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
end