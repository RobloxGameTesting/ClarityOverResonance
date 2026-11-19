require(script.Parent.Parent.Types)

return function(state, data)
	local function relocateTooltips()
		if state._rootInstance == nil then
			return
		end

		local popupScreenGui = state._rootInstance:FindFirstChild("PopupScreenGui")
		local tooltipContainer = popupScreenGui.TooltipContainer
		local mouseLocation = data.getMouseLocation()
		local bestWindowPosForPopup = data.findBestWindowPosForPopup(
			mouseLocation,
			tooltipContainer.AbsoluteSize,
			state._config.DisplaySafeAreaPadding,
			popupScreenGui.AbsoluteSize
		)
		tooltipContainer.Position = UDim2.fromOffset(bestWindowPosForPopup.X, bestWindowPosForPopup.Y)
	end

	data.registerEvent("InputChanged", function()
		if not state._started then
			return
		end

		relocateTooltips()
	end)

	state.WidgetConstructor("Tooltip", {
		hasState = false,
		hasChildren = false,
		Args = { Text = 1 },
		Events = {},
		Generate = function(p)
			p.parentWidget = state._rootWidget

			local iris_Tooltip = Instance.new("Frame")
			iris_Tooltip.Name = "Iris_Tooltip"
			iris_Tooltip.Size = UDim2.new(state._config.ContentWidth, UDim.new(0, 0))
			iris_Tooltip.AutomaticSize = Enum.AutomaticSize.Y
			iris_Tooltip.BorderSizePixel = 0
			iris_Tooltip.BackgroundTransparency = 1
			iris_Tooltip.ZIndex = 1

			local tooltipText = Instance.new("TextLabel")
			tooltipText.Name = "TooltipText"
			tooltipText.Size = UDim2.fromOffset(0, 0)
			tooltipText.AutomaticSize = Enum.AutomaticSize.XY
			tooltipText.BackgroundColor3 = state._config.PopupBgColor
			tooltipText.BackgroundTransparency = state._config.PopupBgTransparency
			tooltipText.TextWrapped = state._config.TextWrapped

			data.applyTextStyle(tooltipText)
			data.UIStroke(
				tooltipText,
				state._config.PopupBorderSize,
				state._config.BorderActiveColor,
				state._config.BorderActiveTransparency
			)
			data.UIPadding(tooltipText, state._config.WindowPadding)

			if state._config.PopupRounding > 0 then
				data.UICorner(tooltipText, state._config.PopupRounding)
			end

			tooltipText.Parent = iris_Tooltip

			return iris_Tooltip
		end,
		Update = function(p)
			local tooltipText = p.Instance.TooltipText

			if p.arguments.Text == nil then
				error("Text argument is required for Iris.Tooltip().", 5)
			end

			tooltipText.Text = p.arguments.Text
			relocateTooltips()
		end,
		Discard = function(p)
			p.Instance:Destroy()
		end
	})

	local count = 0
	local v = nil
	local v2 = false
	local v3 = nil

	local v4 = nil
	local v5 = false
	local v6 = false
	local v7 = false
	local v8 = Enum.TopBottom.Top
	local v9 = Enum.LeftRight.Left

	local v10 = nil

	local v11 = nil
	local v12 = false

	local v13 = {}

	local function quickSwapWindows()
		if state._config.UseScreenGUIs == false then
			return
		end

		local v14 = 65535
		local v15 = nil

		for _, v16 in v13 do
			if not v16.state.isOpened.value or v16.arguments.NoNav or not v16.Instance:IsA("ScreenGui") then
				continue
			end

			local displayOrder = v16.Instance.DisplayOrder

			if not (displayOrder < v14) then
				continue
			end

			v15 = v16
			v14 = displayOrder
		end

		if not v15 then
			return
		end

		if v15.state.isUncollapsed.value == false then
			v15.state.isUncollapsed:set(true)
		end

		state.SetFocusedWindow(v15)
	end

	local function fitSizeToWindowBounds(p, vector2: Vector2)
		local vector2_2 = Vector2.new(p.state.position.value.X, p.state.position.value.Y)
		local v14 = (state._config.TextSize + 2 * state._config.FramePadding.Y) * 2
		local screenSizeForWindow = data.getScreenSizeForWindow(p)
		local vector2_3 = Vector2.new(
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.X,
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.Y
		)

		local v15 = screenSizeForWindow - vector2_2 - vector2_3
		return Vector2.new(
			math.clamp(vector2.X, v14, (math.max(v15.X, v14))),
			(math.clamp(vector2.Y, v14, (math.max(v15.Y, v14))))
		)
	end

	local function fitPositionToWindowBounds(p, vector2: Vector2)
		local instance = p.Instance
		local screenSizeForWindow = data.getScreenSizeForWindow(p)
		local vector2_2 = Vector2.new(
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.X,
			state._config.WindowBorderSize + state._config.DisplaySafeAreaPadding.Y
		)

		return Vector2.new(
			math.clamp(
				vector2.X,
				vector2_2.X,
				(math.max(vector2_2.X, screenSizeForWindow.X - instance.WindowButton.AbsoluteSize.X - vector2_2.X))
			),
			(math.clamp(
				vector2.Y,
				vector2_2.Y,
				(math.max(vector2_2.Y, screenSizeForWindow.Y - instance.WindowButton.AbsoluteSize.Y - vector2_2.Y))
			))
		)
	end

	function state.SetFocusedWindow(data2)
		if v11 == data2 then
			return
		end

		if v12 and v11 ~= nil then
			if v13[v11.ID] then
				local windowButton = v11.Instance.WindowButton
				local titleBar = windowButton.Content.TitleBar

				if v11.state.isUncollapsed.value then
					titleBar.BackgroundColor3 = state._config.TitleBgColor
					titleBar.BackgroundTransparency = state._config.TitleBgTransparency
				else
					titleBar.BackgroundColor3 = state._config.TitleBgCollapsedColor
					titleBar.BackgroundTransparency = state._config.TitleBgCollapsedTransparency
				end

				windowButton.UIStroke.Color = state._config.BorderColor
			end

			v12 = false
			v11 = nil
		end

		if data2 ~= nil then
			v12 = true
			v11 = data2
			local instance = data2.Instance
			local windowButton = instance.WindowButton
			local titleBar = windowButton.Content.TitleBar

			titleBar.BackgroundColor3 = state._config.TitleBgActiveColor
			titleBar.BackgroundTransparency = state._config.TitleBgActiveTransparency
			windowButton.UIStroke.Color = state._config.BorderActiveColor

			count += 1

			if data2.usesScreenGuis then
				instance.DisplayOrder = count + state._config.DisplayOrderOffset
			else
				instance.ZIndex = count + state._config.DisplayOrderOffset
			end

			if data2.state.isUncollapsed.value == false then
				data2.state.isUncollapsed:set(true)
			end

			if data.GuiService.SelectedObject then
				if titleBar.Visible then
					data.GuiService:Select(titleBar)
				else
					data.GuiService:Select(data2.ChildContainer)
				end
			end
		end
	end

	data.registerEvent("InputBegan", function(p)
		if not state._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouseLocation = data.getMouseLocation()
			local v14 = false

			for _, v15 in v13 do
				local instance = v15.Instance

				if not instance then
					continue
				end

				local resizeBorder = instance.WindowButton.ResizeBorder

				if
					resizeBorder
					and data.isPosInsideRect(
						mouseLocation,
						resizeBorder.AbsolutePosition - data.GuiOffset,
						resizeBorder.AbsolutePosition - data.GuiOffset + resizeBorder.AbsoluteSize
					)
				then
					v14 = true
					break
				end
			end

			if not v14 then
				state.SetFocusedWindow(nil)
			end
		end

		if
			p.KeyCode == Enum.KeyCode.Tab
			and (data.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or data.UserInputService:IsKeyDown(Enum.KeyCode.RightControl))
		then
			quickSwapWindows()
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v6 and not v7 and v12 and v11 then
			local v14 = v11.state.position.value + v11.state.size.value / 2
			local v15 = data.getMouseLocation() - v14

			if math.abs(v15.X) * v11.state.size.value.Y >= math.abs(v15.Y) * v11.state.size.value.X then
				v8 = Enum.TopBottom.Center
				local v16

				if math.sign(v15.X) == -1 then
					v16 = Enum.LeftRight.Left
				else
					v16 = Enum.LeftRight.Right
				end

				v9 = v16
			else
				v9 = Enum.LeftRight.Center
				local v16

				if math.sign(v15.Y) == -1 then
					v16 = Enum.TopBottom.Top
				else
					v16 = Enum.TopBottom.Bottom
				end

				v8 = v16
			end

			v5 = true
			v4 = v11
		end
	end)

	data.registerEvent("TouchTapInWorld", function(_, flag: boolean)
		if not state._started then
			return
		end

		if not flag then
			state.SetFocusedWindow(nil)
		end
	end)

	data.registerEvent("InputChanged", function(data2)
		if not state._started then
			return
		end

		if v2 and v then
			local v14

			if data2.UserInputType == Enum.UserInputType.Touch then
				local position = data2.Position
				v14 = Vector2.new(position.X, position.Y)
			else
				v14 = data.getMouseLocation()
			end

			local windowButton = v.Instance.WindowButton
			local v15 = v14 - v3
			local v16 = fitPositionToWindowBounds(v, v15)

			windowButton.Position = UDim2.fromOffset(v16.X, v16.Y)
			v.state.position.value = v16
		end

		if v5 and v4 and v4.arguments.NoResize ~= true then
			local windowButton = v4.Instance.WindowButton
			local vector2 = Vector2.new(windowButton.Position.X.Offset, windowButton.Position.Y.Offset)
			local vector2_2 = Vector2.new(windowButton.Size.X.Offset, windowButton.Size.Y.Offset)
			local v14

			if data2.UserInputType == Enum.UserInputType.Touch then
				v14 = data2.Delta
			else
				v14 = data.getMouseLocation() - v10
			end

			local v15 = vector2 + Vector2.new(
				v9 ~= Enum.LeftRight.Left and 0 or v14.X,
				v8 ~= Enum.TopBottom.Top and 0 or v14.Y
			)
			local v16

			if v9 == Enum.LeftRight.Left then
				v16 = -v14.X
			else
				v16 = v9 ~= Enum.LeftRight.Right and 0 or v14.X
			end

			local v17

			if v8 == Enum.TopBottom.Top then
				v17 = -v14.Y
			else
				v17 = v8 ~= Enum.TopBottom.Bottom and 0 or v14.Y
			end

			local v18 = vector2_2 + Vector2.new(v16, v17)

			local v19 = fitSizeToWindowBounds(v4, v18)
			local v20 = fitPositionToWindowBounds(v4, v15)

			windowButton.Size = UDim2.fromOffset(v19.X, v19.Y)
			v4.state.size.value = v19
			windowButton.Position = UDim2.fromOffset(v20.X, v20.Y)
			v4.state.position.value = v20
		end

		v10 = data.getMouseLocation()
	end)

	data.registerEvent("InputEnded", function(p, _)
		if not state._started then
			return
		end

		if
			(p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch)
			and v2
			and v
		then
			local windowButton = v.Instance.WindowButton
			v2 = false
			v.state.position:set(Vector2.new(windowButton.Position.X.Offset, windowButton.Position.Y.Offset))
		end

		if
			(p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch)
			and v5
			and v4
		then
			local instance = v4.Instance
			v5 = false
			v4.state.size:set(instance.WindowButton.AbsoluteSize)
		end

		if p.KeyCode == Enum.KeyCode.ButtonX then
			quickSwapWindows()
		end
	end)

	state.WidgetConstructor("Window", {
		hasState = true,
		hasChildren = true,
		Args = {
			Title = 1,
			NoTitleBar = 2,
			NoBackground = 3,
			NoCollapse = 4,
			NoClose = 5,
			NoMove = 6,
			NoScrollbar = 7,
			NoResize = 8,
			NoNav = 9,
			NoMenu = 10
		},
		Events = {
			closed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastClosedTick == state._cycleTick
				end
			},
			opened = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastOpenedTick == state._cycleTick
				end
			},
			collapsed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastCollapsedTick == state._cycleTick
				end
			},
			uncollapsed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastUncollapsedTick == state._cycleTick
				end
			},
			hovered = data.EVENTS.hover(function(p)
				return p.Instance.WindowButton
			end)
		},
		Generate = function(state2)
			state2.parentWidget = state._rootWidget

			state2.usesScreenGuis = state._config.UseScreenGUIs
			v13[state2.ID] = state2
			local iris_Window

			if state2.usesScreenGuis then
				iris_Window = Instance.new("ScreenGui")
				iris_Window.ResetOnSpawn = false
				iris_Window.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				iris_Window.DisplayOrder = state._config.DisplayOrderOffset
				iris_Window.IgnoreGuiInset = state._config.IgnoreGuiInset
			else
				iris_Window = Instance.new("Frame")
				iris_Window.AnchorPoint = Vector2.new(0.5, 0.5)
				iris_Window.Position = UDim2.new(0.5, 0, 0.5, 0)
				iris_Window.Size = UDim2.new(1, 0, 1, 0)
				iris_Window.BackgroundTransparency = 1
				iris_Window.ZIndex = state._config.DisplayOrderOffset
			end

			iris_Window.Name = "Iris_Window"

			local windowButton = Instance.new("TextButton")
			windowButton.Name = "WindowButton"
			windowButton.Size = UDim2.fromOffset(0, 0)
			windowButton.BackgroundColor3 = state._config.MenubarBgColor
			windowButton.BackgroundTransparency = state._config.MenubarBgTransparency
			windowButton.BorderSizePixel = 0
			windowButton.Text = ""
			windowButton.ClipsDescendants = false
			windowButton.AutoButtonColor = false
			windowButton.Selectable = false
			windowButton.SelectionImageObject = state.SelectionImageObject

			windowButton.SelectionGroup = true
			windowButton.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			windowButton.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			windowButton.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			windowButton.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

			data.UIStroke(
				windowButton,
				state._config.WindowBorderSize,
				state._config.BorderColor,
				state._config.BorderTransparency
			)

			windowButton.Parent = iris_Window

			data.applyInputBegan(windowButton, function(p)
				if
					p.UserInputType == Enum.UserInputType.MouseMovement
					or p.UserInputType == Enum.UserInputType.Keyboard
				then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end

				if not state2.arguments.NoMove and p.UserInputType == Enum.UserInputType.MouseButton1 then
					v = state2
					v2 = true
					v3 = data.getMouseLocation() - state2.state.position.value
				end
			end)

			local content = Instance.new("Frame")
			content.Name = "Content"
			content.AnchorPoint = Vector2.new(0.5, 0.5)
			content.Position = UDim2.fromScale(0.5, 0.5)
			content.Size = UDim2.fromScale(1, 1)
			content.BackgroundTransparency = 1
			content.ClipsDescendants = true
			content.Parent = windowButton

			local uiListLayout = data.UIListLayout(content, Enum.FillDirection.Vertical, UDim.new(0, 0))
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

			local windowContainer = Instance.new("ScrollingFrame")
			windowContainer.Name = "WindowContainer"
			windowContainer.Size = UDim2.fromScale(1, 1)
			windowContainer.BackgroundColor3 = state._config.WindowBgColor
			windowContainer.BackgroundTransparency = state._config.WindowBgTransparency
			windowContainer.BorderSizePixel = 0

			windowContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
			windowContainer.ScrollBarImageTransparency = state._config.ScrollbarGrabTransparency
			windowContainer.ScrollBarImageColor3 = state._config.ScrollbarGrabColor
			windowContainer.CanvasSize = UDim2.fromScale(0, 0)
			windowContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
			windowContainer.TopImage = data.ICONS.BLANK_SQUARE
			windowContainer.MidImage = data.ICONS.BLANK_SQUARE
			windowContainer.BottomImage = data.ICONS.BLANK_SQUARE

			windowContainer.LayoutOrder = state2.ZIndex + 65535
			windowContainer.ClipsDescendants = true

			data.UIPadding(windowContainer, state._config.WindowPadding)

			windowContainer.Parent = content

			local uiFlexItem = Instance.new("UIFlexItem")
			uiFlexItem.FlexMode = Enum.UIFlexMode.Fill
			uiFlexItem.ItemLineAlignment = Enum.ItemLineAlignment.End
			uiFlexItem.Parent = windowContainer

			windowContainer:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				state2.state.scrollDistance.value = windowContainer.CanvasPosition.Y
			end)

			data.applyInputBegan(windowContainer, function(p)
				if
					p.UserInputType == Enum.UserInputType.MouseMovement
					or p.UserInputType == Enum.UserInputType.Keyboard
				then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end
			end)

			local terminatingFrame = Instance.new("Frame")
			terminatingFrame.Name = "TerminatingFrame"
			terminatingFrame.Size = UDim2.fromOffset(0, state._config.WindowPadding.Y + state._config.FramePadding.Y)
			terminatingFrame.BackgroundTransparency = 1
			terminatingFrame.BorderSizePixel = 0
			terminatingFrame.LayoutOrder = 2147483632

			local uiListLayout_2 = data.UIListLayout(
				windowContainer,
				Enum.FillDirection.Vertical,
				UDim.new(0, state._config.ItemSpacing.Y)
			)
			uiListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Top

			terminatingFrame.Parent = windowContainer

			local titleBar = Instance.new("Frame")
			titleBar.Name = "TitleBar"
			titleBar.AutomaticSize = Enum.AutomaticSize.Y
			titleBar.Size = UDim2.fromScale(1, 0)
			titleBar.BorderSizePixel = 0
			titleBar.ClipsDescendants = true

			titleBar.Parent = content

			data.UIPadding(titleBar, Vector2.new(state._config.FramePadding.X))
			local uiListLayout_3 = data.UIListLayout(
				titleBar,
				Enum.FillDirection.Horizontal,
				UDim.new(0, state._config.ItemInnerSpacing.X)
			)
			uiListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center
			data.applyInputBegan(titleBar, function(p)
				if p.UserInputType == Enum.UserInputType.Touch and not state2.arguments.NoMove then
					v = state2
					v2 = true
					local position = p.Position
					v3 = Vector2.new(position.X, position.Y) - state2.state.position.value
				end
			end)

			local v14 = state._config.TextSize + (state._config.FramePadding.Y - 1) * 2

			local collapseButton = Instance.new("TextButton")
			collapseButton.Name = "CollapseButton"
			collapseButton.AnchorPoint = Vector2.new(0, 0.5)
			collapseButton.Size = UDim2.fromOffset(v14, v14)
			collapseButton.Position = UDim2.new(0, 0, 0.5, 0)
			collapseButton.AutomaticSize = Enum.AutomaticSize.None
			collapseButton.BackgroundTransparency = 1
			collapseButton.BorderSizePixel = 0
			collapseButton.AutoButtonColor = false
			collapseButton.Text = ""

			data.UICorner(collapseButton)

			collapseButton.Parent = titleBar

			data.applyButtonClick(collapseButton, function()
				state2.state.isUncollapsed:set(not state2.state.isUncollapsed.value)
			end)

			data.applyInteractionHighlights("Background", collapseButton, collapseButton, {
				Color = state._config.ButtonColor,
				Transparency = 1,
				HoveredColor = state._config.ButtonHoveredColor,
				HoveredTransparency = state._config.ButtonHoveredTransparency,
				ActiveColor = state._config.ButtonActiveColor,
				ActiveTransparency = state._config.ButtonActiveTransparency
			})

			local arrow = Instance.new("ImageLabel")
			arrow.Name = "Arrow"
			arrow.AnchorPoint = Vector2.new(0.5, 0.5)
			arrow.Size = UDim2.fromOffset(math.floor(v14 * 0.7), (math.floor(v14 * 0.7)))
			arrow.Position = UDim2.fromScale(0.5, 0.5)
			arrow.BackgroundTransparency = 1
			arrow.BorderSizePixel = 0
			arrow.Image = data.ICONS.MULTIPLICATION_SIGN
			arrow.ImageColor3 = state._config.TextColor
			arrow.ImageTransparency = state._config.TextTransparency
			arrow.Parent = collapseButton

			local closeButton = Instance.new("TextButton")
			closeButton.Name = "CloseButton"
			closeButton.AnchorPoint = Vector2.new(1, 0.5)
			closeButton.Size = UDim2.fromOffset(v14, v14)
			closeButton.Position = UDim2.new(1, 0, 0.5, 0)
			closeButton.AutomaticSize = Enum.AutomaticSize.None
			closeButton.BackgroundTransparency = 1
			closeButton.BorderSizePixel = 0
			closeButton.Text = ""
			closeButton.LayoutOrder = 2
			closeButton.AutoButtonColor = false

			data.UICorner(closeButton)

			data.applyButtonClick(closeButton, function()
				state2.state.isOpened:set(false)
			end)

			data.applyInteractionHighlights("Background", closeButton, closeButton, {
				Color = state._config.ButtonColor,
				Transparency = 1,
				HoveredColor = state._config.ButtonHoveredColor,
				HoveredTransparency = state._config.ButtonHoveredTransparency,
				ActiveColor = state._config.ButtonActiveColor,
				ActiveTransparency = state._config.ButtonActiveTransparency
			})

			closeButton.Parent = titleBar

			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Size = UDim2.fromOffset(math.floor(v14 * 0.7), (math.floor(v14 * 0.7)))
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.BackgroundTransparency = 1
			icon.BorderSizePixel = 0
			icon.Image = data.ICONS.MULTIPLICATION_SIGN
			icon.ImageColor3 = state._config.TextColor
			icon.ImageTransparency = state._config.TextTransparency
			icon.Parent = closeButton

			local title = Instance.new("TextLabel")
			title.Name = "Title"
			title.AutomaticSize = Enum.AutomaticSize.XY
			title.BorderSizePixel = 0
			title.BackgroundTransparency = 1
			title.LayoutOrder = 1
			title.ClipsDescendants = true

			data.UIPadding(title, Vector2.new(0, state._config.FramePadding.Y))
			data.applyTextStyle(title)
			title.TextXAlignment = Enum.TextXAlignment[state._config.WindowTitleAlign.Name]

			local uiFlexItem2 = Instance.new("UIFlexItem")
			uiFlexItem2.FlexMode = Enum.UIFlexMode.Fill
			uiFlexItem2.ItemLineAlignment = Enum.ItemLineAlignment.Center

			uiFlexItem2.Parent = title

			title.Parent = titleBar

			local v15 = state._config.TextSize + state._config.FramePadding.X

			local leftResizeGrip = Instance.new("ImageButton")
			leftResizeGrip.Name = "LeftResizeGrip"
			leftResizeGrip.AnchorPoint = Vector2.yAxis
			leftResizeGrip.Rotation = 180
			leftResizeGrip.Size = UDim2.fromOffset(v15, v15)
			leftResizeGrip.Position = UDim2.fromScale(0, 1)
			leftResizeGrip.BackgroundTransparency = 1
			leftResizeGrip.BorderSizePixel = 0
			leftResizeGrip.Image = data.ICONS.BOTTOM_RIGHT_CORNER
			leftResizeGrip.ImageColor3 = state._config.ResizeGripColor
			leftResizeGrip.ImageTransparency = 1
			leftResizeGrip.AutoButtonColor = false
			leftResizeGrip.ZIndex = 3
			leftResizeGrip.Parent = windowButton

			data.applyInteractionHighlights("Image", leftResizeGrip, leftResizeGrip, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})

			data.applyButtonDown(leftResizeGrip, function()
				if not v12 or v11 ~= state2 then
					state.SetFocusedWindow(state2)
				end

				v5 = true
				v8 = Enum.TopBottom.Bottom
				v9 = Enum.LeftRight.Left
				v4 = state2
			end)

			local rightResizeGrip = Instance.new("ImageButton")
			rightResizeGrip.Name = "RightResizeGrip"
			rightResizeGrip.AnchorPoint = Vector2.one
			rightResizeGrip.Rotation = 90
			rightResizeGrip.Size = UDim2.fromOffset(v15, v15)
			rightResizeGrip.Position = UDim2.fromScale(1, 1)
			rightResizeGrip.BackgroundTransparency = 1
			rightResizeGrip.BorderSizePixel = 0
			rightResizeGrip.Image = data.ICONS.BOTTOM_RIGHT_CORNER
			rightResizeGrip.ImageColor3 = state._config.ResizeGripColor
			rightResizeGrip.ImageTransparency = state._config.ResizeGripTransparency
			rightResizeGrip.AutoButtonColor = false
			rightResizeGrip.ZIndex = 3
			rightResizeGrip.Parent = windowButton

			data.applyInteractionHighlights("Image", rightResizeGrip, rightResizeGrip, {
				Color = state._config.ResizeGripColor,
				Transparency = state._config.ResizeGripTransparency,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})

			data.applyButtonDown(rightResizeGrip, function()
				if not v12 or v11 ~= state2 then
					state.SetFocusedWindow(state2)
				end

				v5 = true
				v8 = Enum.TopBottom.Bottom
				v9 = Enum.LeftRight.Right
				v4 = state2
			end)

			local leftResizeBorder = Instance.new("ImageButton")
			leftResizeBorder.Name = "LeftResizeBorder"
			leftResizeBorder.AnchorPoint = Vector2.new(1, 0.5)
			leftResizeBorder.Position = UDim2.fromScale(0, 0.5)
			leftResizeBorder.Size = UDim2.new(
				0,
				state._config.WindowResizePadding.X,
				1,
				2 * state._config.WindowBorderSize
			)
			leftResizeBorder.Transparency = 1
			leftResizeBorder.Image = data.ICONS.BORDER
			leftResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
			leftResizeBorder.ScaleType = Enum.ScaleType.Slice
			leftResizeBorder.SliceCenter = Rect.new(0, 0, 1, 1)
			leftResizeBorder.ImageRectOffset = Vector2.new(2, 2)
			leftResizeBorder.ImageRectSize = Vector2.new(2, 1)
			leftResizeBorder.ImageTransparency = 1
			leftResizeBorder.ZIndex = 4
			leftResizeBorder.AutoButtonColor = false

			leftResizeBorder.Parent = windowButton

			local rightResizeBorder = Instance.new("ImageButton")
			rightResizeBorder.Name = "RightResizeBorder"
			rightResizeBorder.AnchorPoint = Vector2.new(0, 0.5)
			rightResizeBorder.Position = UDim2.fromScale(1, 0.5)
			rightResizeBorder.Size = UDim2.new(
				0,
				state._config.WindowResizePadding.X,
				1,
				2 * state._config.WindowBorderSize
			)
			rightResizeBorder.Transparency = 1
			rightResizeBorder.Image = data.ICONS.BORDER
			rightResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
			rightResizeBorder.ScaleType = Enum.ScaleType.Slice
			rightResizeBorder.SliceCenter = Rect.new(1, 0, 2, 1)
			rightResizeBorder.ImageRectOffset = Vector2.new(1, 2)
			rightResizeBorder.ImageRectSize = Vector2.new(2, 1)
			rightResizeBorder.ImageTransparency = 1
			rightResizeBorder.ZIndex = 4
			rightResizeBorder.AutoButtonColor = false

			rightResizeBorder.Parent = windowButton

			local topResizeBorder = Instance.new("ImageButton")
			topResizeBorder.Name = "TopResizeBorder"
			topResizeBorder.AnchorPoint = Vector2.new(0.5, 1)
			topResizeBorder.Position = UDim2.fromScale(0.5, 0)
			topResizeBorder.Size = UDim2.new(
				1,
				2 * state._config.WindowBorderSize,
				0,
				state._config.WindowResizePadding.Y
			)
			topResizeBorder.Transparency = 1
			topResizeBorder.Image = data.ICONS.BORDER
			topResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
			topResizeBorder.ScaleType = Enum.ScaleType.Slice
			topResizeBorder.SliceCenter = Rect.new(0, 0, 1, 1)
			topResizeBorder.ImageRectOffset = Vector2.new(2, 2)
			topResizeBorder.ImageRectSize = Vector2.new(1, 2)
			topResizeBorder.ImageTransparency = 1
			topResizeBorder.ZIndex = 4
			topResizeBorder.AutoButtonColor = false

			topResizeBorder.Parent = windowButton

			local bottomResizeBorder = Instance.new("ImageButton")
			bottomResizeBorder.Name = "BottomResizeBorder"
			bottomResizeBorder.AnchorPoint = Vector2.new(0.5, 0)
			bottomResizeBorder.Position = UDim2.fromScale(0.5, 1)
			bottomResizeBorder.Size = UDim2.new(
				1,
				2 * state._config.WindowBorderSize,
				0,
				state._config.WindowResizePadding.Y
			)
			bottomResizeBorder.Transparency = 1
			bottomResizeBorder.Image = data.ICONS.BORDER
			bottomResizeBorder.ResampleMode = Enum.ResamplerMode.Pixelated
			bottomResizeBorder.ScaleType = Enum.ScaleType.Slice
			bottomResizeBorder.SliceCenter = Rect.new(0, 1, 1, 2)
			bottomResizeBorder.ImageRectOffset = Vector2.new(2, 1)
			bottomResizeBorder.ImageRectSize = Vector2.new(1, 2)
			bottomResizeBorder.ImageTransparency = 1
			bottomResizeBorder.ZIndex = 4
			bottomResizeBorder.AutoButtonColor = false

			bottomResizeBorder.Parent = windowButton

			data.applyInteractionHighlights("Image", leftResizeBorder, leftResizeBorder, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})

			data.applyInteractionHighlights("Image", rightResizeBorder, rightResizeBorder, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})

			data.applyInteractionHighlights("Image", topResizeBorder, topResizeBorder, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})

			data.applyInteractionHighlights("Image", bottomResizeBorder, bottomResizeBorder, {
				Color = state._config.ResizeGripColor,
				Transparency = 1,
				HoveredColor = state._config.ResizeGripHoveredColor,
				HoveredTransparency = state._config.ResizeGripHoveredTransparency,
				ActiveColor = state._config.ResizeGripActiveColor,
				ActiveTransparency = state._config.ResizeGripActiveTransparency
			})

			local resizeBorder = Instance.new("Frame")
			resizeBorder.Name = "ResizeBorder"
			resizeBorder.Size = UDim2.new(
				1,
				state._config.WindowResizePadding.X * 2,
				1,
				state._config.WindowResizePadding.Y * 2
			)
			resizeBorder.Position = UDim2.fromOffset(
				-state._config.WindowResizePadding.X,
				-state._config.WindowResizePadding.Y
			)
			resizeBorder.BackgroundTransparency = 1
			resizeBorder.BorderSizePixel = 0
			resizeBorder.Active = false
			resizeBorder.Selectable = false
			resizeBorder.ClipsDescendants = false
			resizeBorder.Parent = windowButton

			data.applyMouseEnter(resizeBorder, function()
				if v11 == state2 then
					v6 = true
				end
			end)
			data.applyMouseLeave(resizeBorder, function()
				if v11 == state2 then
					v6 = false
				end
			end)
			data.applyInputBegan(resizeBorder, function(p)
				if
					p.UserInputType == Enum.UserInputType.MouseMovement
					or p.UserInputType == Enum.UserInputType.Keyboard
				then
					return
				end

				if state2.state.isUncollapsed.value then
					state.SetFocusedWindow(state2)
				end
			end)

			data.applyMouseEnter(windowButton, function()
				if v11 == state2 then
					v7 = true
				end
			end)
			data.applyMouseLeave(windowButton, function()
				if v11 == state2 then
					v7 = false
				end
			end)

			state2.ChildContainer = windowContainer
			return iris_Window
		end,
		Update = function(data2)
			local instance = data2.Instance
			local childContainer = data2.ChildContainer
			local windowButton = instance.WindowButton
			local content = windowButton.Content
			local titleBar = content.TitleBar
			local title = titleBar.Title
			local iris_MenuBar = content:FindFirstChild("Iris_MenuBar")
			local leftResizeGrip = windowButton.LeftResizeGrip
			local rightResizeGrip = windowButton.RightResizeGrip
			local leftResizeBorder = windowButton.LeftResizeBorder
			local rightResizeBorder = windowButton.RightResizeBorder
			local topResizeBorder = windowButton.TopResizeBorder
			local bottomResizeBorder = windowButton.BottomResizeBorder

			if data2.arguments.NoResize == true then
				leftResizeGrip.Visible = false
				rightResizeGrip.Visible = false
				leftResizeBorder.Visible = false
				rightResizeBorder.Visible = false
				topResizeBorder.Visible = false
				bottomResizeBorder.Visible = false
			else
				leftResizeGrip.Visible = true
				rightResizeGrip.Visible = true
				leftResizeBorder.Visible = true
				rightResizeBorder.Visible = true
				topResizeBorder.Visible = true
				bottomResizeBorder.Visible = true
			end

			if data2.arguments.NoScrollbar then
				childContainer.ScrollBarThickness = 0
			else
				childContainer.ScrollBarThickness = state._config.ScrollbarSize
			end

			if data2.arguments.NoTitleBar then
				titleBar.Visible = false
			else
				titleBar.Visible = true
			end

			if iris_MenuBar then
				if data2.arguments.NoMenu then
					iris_MenuBar.Visible = false
				else
					iris_MenuBar.Visible = true
				end
			end

			if data2.arguments.NoBackground then
				childContainer.BackgroundTransparency = 1
			else
				childContainer.BackgroundTransparency = state._config.WindowBgTransparency
			end

			if data2.arguments.NoCollapse then
				titleBar.CollapseButton.Visible = false
			else
				titleBar.CollapseButton.Visible = true
			end

			if data2.arguments.NoClose then
				titleBar.CloseButton.Visible = false
			else
				titleBar.CloseButton.Visible = true
			end

			title.Text = data2.arguments.Title or ""
		end,
		Discard = function(p)
			if v11 == p then
				v11 = nil
				v12 = false
			end

			if v == p then
				v = nil
				v2 = false
			end

			if v4 == p then
				v4 = nil
				v5 = false
			end

			v13[p.ID] = nil
			p.Instance:Destroy()
			data.discardState(p)
		end,
		ChildAdded = function(p, p2)
			local content = p.Instance.WindowButton.Content

			if p2.type ~= "MenuBar" then
				return p.ChildContainer
			end

			local childContainer = p.ChildContainer
			p2.Instance.ZIndex = childContainer.ZIndex + 1
			p2.Instance.LayoutOrder = childContainer.LayoutOrder - 1
			return content
		end,
		UpdateState = function(state2)
			local value = state2.state.size.value
			local value2 = state2.state.position.value
			local value3 = state2.state.isUncollapsed.value
			local value4 = state2.state.isOpened.value
			local value5 = state2.state.scrollDistance.value

			local instance = state2.Instance
			local childContainer = state2.ChildContainer
			local windowButton = instance.WindowButton
			local content = windowButton.Content
			local titleBar = content.TitleBar
			local iris_MenuBar = content:FindFirstChild("Iris_MenuBar")
			local leftResizeGrip = windowButton.LeftResizeGrip
			local rightResizeGrip = windowButton.RightResizeGrip
			local leftResizeBorder = windowButton.LeftResizeBorder
			local rightResizeBorder = windowButton.RightResizeBorder
			local topResizeBorder = windowButton.TopResizeBorder
			local bottomResizeBorder = windowButton.BottomResizeBorder

			windowButton.Size = UDim2.fromOffset(value.X, value.Y)
			windowButton.Position = UDim2.fromOffset(value2.X, value2.Y)

			if value4 then
				if state2.usesScreenGuis then
					instance.Enabled = true
				else
					instance.Visible = true
				end

				windowButton.Visible = true

				state2.lastOpenedTick = state._cycleTick + 1
			else
				if state2.usesScreenGuis then
					instance.Enabled = false
				else
					instance.Visible = false
				end

				windowButton.Visible = false

				state2.lastClosedTick = state._cycleTick + 1
			end

			if value3 then
				titleBar.CollapseButton.Arrow.Image = data.ICONS.DOWN_POINTING_TRIANGLE

				if iris_MenuBar then
					iris_MenuBar.Visible = not state2.arguments.NoMenu
				end

				childContainer.Visible = true

				if state2.arguments.NoResize ~= true then
					leftResizeGrip.Visible = true
					rightResizeGrip.Visible = true
					leftResizeBorder.Visible = true
					rightResizeBorder.Visible = true
					topResizeBorder.Visible = true
					bottomResizeBorder.Visible = true
				end

				windowButton.AutomaticSize = Enum.AutomaticSize.None
				state2.lastUncollapsedTick = state._cycleTick + 1
			else
				local y = titleBar.AbsoluteSize.Y
				titleBar.CollapseButton.Arrow.Image = data.ICONS.RIGHT_POINTING_TRIANGLE

				if iris_MenuBar then
					iris_MenuBar.Visible = false
				end

				childContainer.Visible = false
				leftResizeGrip.Visible = false
				rightResizeGrip.Visible = false
				leftResizeBorder.Visible = false
				rightResizeBorder.Visible = false
				topResizeBorder.Visible = false
				bottomResizeBorder.Visible = false
				windowButton.Size = UDim2.fromOffset(value.X, y)
				state2.lastCollapsedTick = state._cycleTick + 1
			end

			if value4 and value3 then
				state.SetFocusedWindow(state2)
			else
				titleBar.BackgroundColor3 = state._config.TitleBgCollapsedColor
				titleBar.BackgroundTransparency = state._config.TitleBgCollapsedTransparency
				windowButton.UIStroke.Color = state._config.BorderColor

				state.SetFocusedWindow(nil)
			end

			if value5 and value5 ~= 0 then
				local v14 = #state._postCycleCallbacks + 1
				local v15 = state._cycleTick + 1
				state._postCycleCallbacks[v14] = function()
					if v15 <= state._cycleTick then
						if state2.lastCycleTick ~= -1 then
							childContainer.CanvasPosition = Vector2.new(0, value5)
						end

						state._postCycleCallbacks[v14] = nil
					end
				end
			end
		end,
		GenerateState = function(p)
			if p.state.size == nil then
				p.state.size = state._widgetState(p, "size", Vector2.new(400, 300))
			end

			if p.state.position == nil then
				local state2 = p.state
				local widgetState = state._widgetState
				local v14

				if v12 and v11 then
					v14 = v11.state.position.value + Vector2.new(15, 45)
				else
					v14 = Vector2.new(150, 250)
				end

				state2.position = widgetState(p, "position", v14)
			end

			p.state.position.value = fitPositionToWindowBounds(p, p.state.position.value)
			p.state.size.value = fitSizeToWindowBounds(p, p.state.size.value)

			if p.state.isUncollapsed == nil then
				p.state.isUncollapsed = state._widgetState(p, "isUncollapsed", true)
			end

			if p.state.isOpened == nil then
				p.state.isOpened = state._widgetState(p, "isOpened", true)
			end

			if p.state.scrollDistance == nil then
				p.state.scrollDistance = state._widgetState(p, "scrollDistance", 0)
			end
		end
	})
end