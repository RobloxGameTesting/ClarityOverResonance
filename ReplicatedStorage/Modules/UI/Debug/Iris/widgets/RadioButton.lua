require(script.Parent.Parent.Types)

return function(data, data2)
	data.WidgetConstructor("RadioButton", {
		hasState = true,
		hasChildren = false,
		Args = { Text = 1, Index = 2 },
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
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(data3)
			local iris_RadioButton = Instance.new("TextButton")
			iris_RadioButton.Name = "Iris_RadioButton"
			iris_RadioButton.AutomaticSize = Enum.AutomaticSize.XY
			iris_RadioButton.Size = UDim2.fromOffset(0, 0)
			iris_RadioButton.BackgroundTransparency = 1
			iris_RadioButton.BorderSizePixel = 0
			iris_RadioButton.Text = ""
			iris_RadioButton.LayoutOrder = data3.ZIndex
			iris_RadioButton.AutoButtonColor = false
			iris_RadioButton.ZIndex = data3.ZIndex
			iris_RadioButton.LayoutOrder = data3.ZIndex

			local uiListLayout = data2.UIListLayout(
				iris_RadioButton,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local v = data._config.TextSize + 2 * (data._config.FramePadding.Y - 1)
			local button = Instance.new("Frame")
			button.Name = "Button"
			button.Size = UDim2.fromOffset(v, v)
			button.Parent = iris_RadioButton
			button.BackgroundColor3 = data._config.FrameBgColor
			button.BackgroundTransparency = data._config.FrameBgTransparency

			data2.UICorner(button)
			data2.UIPadding(button, Vector2.new(math.max(1, (math.floor(v / 5))), (math.max(1, (math.floor(v / 5))))))

			local circle = Instance.new("Frame")
			circle.Name = "Circle"
			circle.Size = UDim2.fromScale(1, 1)
			circle.Parent = button
			circle.BackgroundColor3 = data._config.CheckMarkColor
			circle.BackgroundTransparency = data._config.CheckMarkTransparency
			data2.UICorner(circle)

			data2.applyInteractionHighlights("Background", iris_RadioButton, button, {
				Color = data._config.FrameBgColor,
				Transparency = data._config.FrameBgTransparency,
				HoveredColor = data._config.FrameBgHoveredColor,
				HoveredTransparency = data._config.FrameBgHoveredTransparency,
				ActiveColor = data._config.FrameBgActiveColor,
				ActiveTransparency = data._config.FrameBgActiveTransparency
			})

			data2.applyButtonClick(iris_RadioButton, function()
				data3.state.index:set(data3.arguments.Index)
			end)

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.LayoutOrder = 1

			data2.applyTextStyle(textLabel)
			textLabel.Parent = iris_RadioButton

			return iris_RadioButton
		end,
		Update = function(data3)
			data3.Instance.TextLabel.Text = data3.arguments.Text or "Radio Button"

			if data3.state then
				data3.state.index.lastChangeTick = data._cycleTick
				data._widgets[data3.type].UpdateState(data3)
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.index == nil then
				p.state.index = data._widgetState(p, "index", p.arguments.Index)
			end
		end,
		UpdateState = function(state)
			local circle = state.Instance.Button.Circle

			if state.state.index.value == state.arguments.Index then
				circle.BackgroundTransparency = data._config.CheckMarkTransparency
				state.lastSelectedTick = data._cycleTick + 1
			else
				circle.BackgroundTransparency = 1
				state.lastUnselectedTick = data._cycleTick + 1
			end
		end
	})
end