require(script.Parent.Parent.Types)

return function(p, data)
	p.WidgetConstructor("Text", {
		hasState = false,
		hasChildren = false,
		Args = { Text = 1, Wrapped = 2, Color = 3, RichText = 4 },
		Events = {
			hovered = data.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local iris_Text = Instance.new("TextLabel")
			iris_Text.Name = "Iris_Text"
			iris_Text.Size = UDim2.fromOffset(0, 0)
			iris_Text.BackgroundTransparency = 1
			iris_Text.BorderSizePixel = 0
			iris_Text.LayoutOrder = p2.ZIndex
			iris_Text.AutomaticSize = Enum.AutomaticSize.XY

			data.applyTextStyle(iris_Text)
			data.UIPadding(iris_Text, Vector2.new(0, 2))

			return iris_Text
		end,
		Update = function(p2)
			local instance = p2.Instance

			if p2.arguments.Text == nil then
				error("Text argument is required for Iris.Text().", 5)
			end

			if p2.arguments.Wrapped == nil then
				instance.TextWrapped = p._config.TextWrapped
			else
				instance.TextWrapped = p2.arguments.Wrapped
			end

			if p2.arguments.Color then
				instance.TextColor3 = p2.arguments.Color
			else
				instance.TextColor3 = p._config.TextColor
			end

			if p2.arguments.RichText == nil then
				instance.RichText = p._config.RichText
			else
				instance.RichText = p2.arguments.RichText
			end

			instance.Text = p2.arguments.Text
		end,
		Discard = function(p2)
			p2.Instance:Destroy()
		end
	})

	p.WidgetConstructor("SeparatorText", {
		hasState = false,
		hasChildren = false,
		Args = { Text = 1 },
		Events = {
			hovered = data.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local iris_SeparatorText = Instance.new("Frame")
			iris_SeparatorText.Name = "Iris_SeparatorText"
			iris_SeparatorText.Size = UDim2.new(p._config.ItemWidth, UDim.new())
			iris_SeparatorText.BackgroundTransparency = 1
			iris_SeparatorText.BorderSizePixel = 0
			iris_SeparatorText.AutomaticSize = Enum.AutomaticSize.Y
			iris_SeparatorText.LayoutOrder = p2.ZIndex
			iris_SeparatorText.ClipsDescendants = true

			data.UIPadding(iris_SeparatorText, Vector2.new(0, p._config.SeparatorTextPadding.Y))
			data.UIListLayout(iris_SeparatorText, Enum.FillDirection.Horizontal, UDim.new(0, p._config.ItemSpacing.X))

			iris_SeparatorText.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.LayoutOrder = 1

			data.applyTextStyle(textLabel)

			textLabel.Parent = iris_SeparatorText

			local left = Instance.new("Frame")
			left.Name = "Left"
			left.AnchorPoint = Vector2.new(1, 0.5)
			left.BackgroundColor3 = p._config.SeparatorColor
			left.BackgroundTransparency = p._config.SeparatorTransparency
			left.BorderSizePixel = 0
			left.Size = UDim2.fromOffset(
				p._config.SeparatorTextPadding.X - p._config.ItemSpacing.X,
				p._config.SeparatorTextBorderSize
			)

			left.Parent = iris_SeparatorText

			local right = Instance.new("Frame")
			right.Name = "Right"
			right.AnchorPoint = Vector2.new(1, 0.5)
			right.BackgroundColor3 = p._config.SeparatorColor
			right.BackgroundTransparency = p._config.SeparatorTransparency
			right.BorderSizePixel = 0
			right.Size = UDim2.new(1, 0, 0, p._config.SeparatorTextBorderSize)
			right.LayoutOrder = 2

			right.Parent = iris_SeparatorText

			return iris_SeparatorText
		end,
		Update = function(p2)
			local textLabel = p2.Instance.TextLabel

			if p2.arguments.Text == nil then
				error("Text argument is required for Iris.SeparatorText().", 5)
			end

			textLabel.Text = p2.arguments.Text
		end,
		Discard = function(p2)
			p2.Instance:Destroy()
		end
	})
end