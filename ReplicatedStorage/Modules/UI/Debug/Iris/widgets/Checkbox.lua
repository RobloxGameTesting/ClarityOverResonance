require(script.Parent.Parent.Types)

return function(data, data2)
	data.WidgetConstructor("Checkbox", {
		hasState = true,
		hasChildren = false,
		Args = { Text = 1 },
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
		Generate = function(p)
			local iris_Checkbox = Instance.new("TextButton")
			iris_Checkbox.Name = "Iris_Checkbox"
			iris_Checkbox.AutomaticSize = Enum.AutomaticSize.XY
			iris_Checkbox.Size = UDim2.fromOffset(0, 0)
			iris_Checkbox.BackgroundTransparency = 1
			iris_Checkbox.BorderSizePixel = 0
			iris_Checkbox.Text = ""
			iris_Checkbox.AutoButtonColor = false
			iris_Checkbox.ZIndex = p.ZIndex
			iris_Checkbox.LayoutOrder = p.ZIndex

			local uiListLayout = data2.UIListLayout(
				iris_Checkbox,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local v = data._config.TextSize + 2 * data._config.FramePadding.Y

			local box = Instance.new("Frame")
			box.Name = "Box"
			box.Size = UDim2.fromOffset(v, v)
			box.BackgroundColor3 = data._config.FrameBgColor
			box.BackgroundTransparency = data._config.FrameBgTransparency

			data2.applyFrameStyle(box, true)
			data2.UIPadding(box, Vector2.new(math.floor(v / 10), (math.floor(v / 10))))

			data2.applyInteractionHighlights("Background", iris_Checkbox, box, {
				Color = data._config.FrameBgColor,
				Transparency = data._config.FrameBgTransparency,
				HoveredColor = data._config.FrameBgHoveredColor,
				HoveredTransparency = data._config.FrameBgHoveredTransparency,
				ActiveColor = data._config.FrameBgActiveColor,
				ActiveTransparency = data._config.FrameBgActiveTransparency
			})

			box.Parent = iris_Checkbox

			local checkmark = Instance.new("ImageLabel")
			checkmark.Name = "Checkmark"
			checkmark.Size = UDim2.fromScale(1, 1)
			checkmark.BackgroundTransparency = 1
			checkmark.ImageColor3 = data._config.CheckMarkColor
			checkmark.ImageTransparency = data._config.CheckMarkTransparency
			checkmark.ScaleType = Enum.ScaleType.Fit

			checkmark.Parent = box

			data2.applyButtonClick(iris_Checkbox, function()
				local value = p.state.isChecked.value
				p.state.isChecked:set(not value)
			end)

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.LayoutOrder = 1

			data2.applyTextStyle(textLabel)
			textLabel.Parent = iris_Checkbox

			return iris_Checkbox
		end,
		Update = function(p)
			p.Instance.TextLabel.Text = p.arguments.Text or "Checkbox"
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end,
		GenerateState = function(p)
			if p.state.isChecked == nil then
				p.state.isChecked = data._widgetState(p, "checked", false)
			end
		end,
		UpdateState = function(state)
			local checkmark = state.Instance.Box.Checkmark

			if state.state.isChecked.value then
				checkmark.Image = data2.ICONS.CHECK_MARK
				state.lastCheckedTick = data._cycleTick + 1
			else
				checkmark.Image = ""
				state.lastUncheckedTick = data._cycleTick + 1
			end
		end
	})
end