require(script.Parent.Parent.Types)

return function(data, data2)
	local v = {
		hasState = true,
		hasChildren = true,
		Events = {
			collapsed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastCollapsedTick == data._cycleTick
				end
			},
			uncollapsed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastUncollapsedTick == data._cycleTick
				end
			},
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		ChildAdded = function(p, _)
			local childContainer = p.ChildContainer

			childContainer.Visible = p.state.isUncollapsed.value

			return childContainer
		end,
		UpdateState = function(state)
			local visible = state.state.isUncollapsed.value
			local instance = state.Instance
			local childContainer = state.ChildContainer
			instance.Header.Button.Arrow.Image = visible and data2.ICONS.DOWN_POINTING_TRIANGLE
				or data2.ICONS.RIGHT_POINTING_TRIANGLE

			if visible then
				state.lastUncollapsedTick = data._cycleTick + 1
			else
				state.lastCollapsedTick = data._cycleTick + 1
			end

			childContainer.Visible = visible
		end,
		GenerateState = function(p)
			if p.state.isUncollapsed == nil then
				p.state.isUncollapsed = data._widgetState(p, "isUncollapsed", p.arguments.DefaultOpen or false)
			end
		end
	}

	data.WidgetConstructor("Tree", data2.extend(v, {
		Args = { Text = 1, SpanAvailWidth = 2, NoIndent = 3, DefaultOpen = 4 },
		Generate = function(state)
			local iris_Tree = Instance.new("Frame")
			iris_Tree.Name = "Iris_Tree"
			iris_Tree.Size = UDim2.new(data._config.ItemWidth, UDim.new(0, 0))
			iris_Tree.AutomaticSize = Enum.AutomaticSize.Y
			iris_Tree.BackgroundTransparency = 1
			iris_Tree.BorderSizePixel = 0
			iris_Tree.LayoutOrder = state.ZIndex

			data2.UIListLayout(iris_Tree, Enum.FillDirection.Vertical, UDim.new(0, 0))

			local treeContainer = Instance.new("Frame")
			treeContainer.Name = "TreeContainer"
			treeContainer.Size = UDim2.fromScale(1, 0)
			treeContainer.AutomaticSize = Enum.AutomaticSize.Y
			treeContainer.BackgroundTransparency = 1
			treeContainer.BorderSizePixel = 0
			treeContainer.LayoutOrder = 1
			treeContainer.Visible = false

			data2.UIListLayout(treeContainer, Enum.FillDirection.Vertical, UDim.new(0, data._config.ItemSpacing.Y))
			local uiPadding = data2.UIPadding(treeContainer, Vector2.zero)
			uiPadding.PaddingTop = UDim.new(0, data._config.ItemSpacing.Y)

			treeContainer.Parent = iris_Tree

			local header = Instance.new("Frame")
			header.Name = "Header"
			header.Size = UDim2.fromScale(1, 0)
			header.AutomaticSize = Enum.AutomaticSize.Y
			header.BackgroundTransparency = 1
			header.BorderSizePixel = 0
			header.Parent = iris_Tree

			local button = Instance.new("TextButton")
			button.Name = "Button"
			button.BackgroundTransparency = 1
			button.BorderSizePixel = 0
			button.Text = ""
			button.AutoButtonColor = false

			data2.applyInteractionHighlights("Background", button, header, {
				Color = Color3.fromRGB(0, 0, 0),
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			})

			local uiPadding_2 = data2.UIPadding(button, Vector2.zero)
			uiPadding_2.PaddingLeft = UDim.new(0, data._config.FramePadding.X)
			local uiListLayout = data2.UIListLayout(
				button,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.FramePadding.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			button.Parent = header

			local arrow = Instance.new("ImageLabel")
			arrow.Name = "Arrow"
			arrow.Size = UDim2.fromOffset(data._config.TextSize, (math.floor(data._config.TextSize * 0.7)))
			arrow.BackgroundTransparency = 1
			arrow.BorderSizePixel = 0
			arrow.ImageColor3 = data._config.TextColor
			arrow.ImageTransparency = data._config.TextTransparency
			arrow.ScaleType = Enum.ScaleType.Fit

			arrow.Parent = button

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0

			local uiPadding_3 = data2.UIPadding(textLabel, Vector2.zero)
			uiPadding_3.PaddingRight = UDim.new(0, 21)
			data2.applyTextStyle(textLabel)

			textLabel.Parent = button

			data2.applyButtonClick(button, function()
				state.state.isUncollapsed:set(not state.state.isUncollapsed.value)
			end)

			state.ChildContainer = treeContainer
			return iris_Tree
		end,
		Update = function(data3)
			local instance = data3.Instance
			local childContainer = data3.ChildContainer
			local button = instance.Header.Button
			local textLabel = button.TextLabel
			local uiPadding = childContainer.UIPadding

			textLabel.Text = data3.arguments.Text or "Tree"

			if data3.arguments.SpanAvailWidth then
				button.AutomaticSize = Enum.AutomaticSize.Y
				button.Size = UDim2.fromScale(1, 0)
			else
				button.AutomaticSize = Enum.AutomaticSize.XY
				button.Size = UDim2.fromScale(0, 0)
			end

			if data3.arguments.NoIndent then
				uiPadding.PaddingLeft = UDim.new(0, 0)
			else
				uiPadding.PaddingLeft = UDim.new(0, data._config.IndentSpacing)
			end
		end
	}))

	data.WidgetConstructor("CollapsingHeader", data2.extend(v, {
		Args = { Text = 1, DefaultOpen = 2 },
		Generate = function(state)
			local iris_CollapsingHeader = Instance.new("Frame")
			iris_CollapsingHeader.Name = "Iris_CollapsingHeader"
			iris_CollapsingHeader.Size = UDim2.new(data._config.ItemWidth, UDim.new(0, 0))
			iris_CollapsingHeader.AutomaticSize = Enum.AutomaticSize.Y
			iris_CollapsingHeader.BackgroundTransparency = 1
			iris_CollapsingHeader.BorderSizePixel = 0
			iris_CollapsingHeader.LayoutOrder = state.ZIndex

			data2.UIListLayout(iris_CollapsingHeader, Enum.FillDirection.Vertical, UDim.new(0, 0))

			local collapsingHeaderContainer = Instance.new("Frame")
			collapsingHeaderContainer.Name = "CollapsingHeaderContainer"
			collapsingHeaderContainer.Size = UDim2.fromScale(1, 0)
			collapsingHeaderContainer.AutomaticSize = Enum.AutomaticSize.Y
			collapsingHeaderContainer.BackgroundTransparency = 1
			collapsingHeaderContainer.BorderSizePixel = 0
			collapsingHeaderContainer.LayoutOrder = 1
			collapsingHeaderContainer.Visible = false

			data2.UIListLayout(
				collapsingHeaderContainer,
				Enum.FillDirection.Vertical,
				UDim.new(0, data._config.ItemSpacing.Y)
			)
			local uiPadding = data2.UIPadding(collapsingHeaderContainer, Vector2.zero)
			uiPadding.PaddingTop = UDim.new(0, data._config.ItemSpacing.Y)

			collapsingHeaderContainer.Parent = iris_CollapsingHeader

			local header = Instance.new("Frame")
			header.Name = "Header"
			header.Size = UDim2.fromScale(1, 0)
			header.AutomaticSize = Enum.AutomaticSize.Y
			header.BackgroundTransparency = 1
			header.BorderSizePixel = 0
			header.Parent = iris_CollapsingHeader

			local button = Instance.new("TextButton")
			button.Name = "Button"
			button.Size = UDim2.new(1, 0, 0, 0)
			button.AutomaticSize = Enum.AutomaticSize.Y
			button.BackgroundColor3 = data._config.HeaderColor
			button.BackgroundTransparency = data._config.HeaderTransparency
			button.BorderSizePixel = 0
			button.Text = ""
			button.AutoButtonColor = false
			button.ClipsDescendants = true

			data2.UIPadding(button, data._config.FramePadding)
			data2.applyFrameStyle(button, true)
			local uiListLayout = data2.UIListLayout(
				button,
				Enum.FillDirection.Horizontal,
				UDim.new(0, 2 * data._config.FramePadding.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			data2.applyInteractionHighlights("Background", button, button, {
				Color = data._config.HeaderColor,
				Transparency = data._config.HeaderTransparency,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			})

			button.Parent = header

			local arrow = Instance.new("ImageLabel")
			arrow.Name = "Arrow"
			arrow.Size = UDim2.fromOffset(data._config.TextSize, (math.ceil(data._config.TextSize * 0.8)))
			arrow.AutomaticSize = Enum.AutomaticSize.Y
			arrow.BackgroundTransparency = 1
			arrow.BorderSizePixel = 0
			arrow.ImageColor3 = data._config.TextColor
			arrow.ImageTransparency = data._config.TextTransparency
			arrow.ScaleType = Enum.ScaleType.Fit

			arrow.Parent = button

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0

			local uiPadding_2 = data2.UIPadding(textLabel, Vector2.zero)
			uiPadding_2.PaddingRight = UDim.new(0, 21)
			data2.applyTextStyle(textLabel)

			textLabel.Parent = button

			data2.applyButtonClick(button, function()
				state.state.isUncollapsed:set(not state.state.isUncollapsed.value)
			end)

			state.ChildContainer = collapsingHeaderContainer
			return iris_CollapsingHeader
		end,
		Update = function(p)
			p.Instance.Header.Button.TextLabel.Text = p.arguments.Text or "Collapsing Header"
		end
	}))
end