require(script.Parent.Parent.Types)

return function(p, p2)
	p.WidgetConstructor("Separator", {
		hasState = false,
		hasChildren = false,
		Args = {},
		Events = {},
		Generate = function(p3)
			local iris_Separator = Instance.new("Frame")
			iris_Separator.Name = "Iris_Separator"
			iris_Separator.BackgroundColor3 = p._config.SeparatorColor
			iris_Separator.BackgroundTransparency = p._config.SeparatorTransparency
			iris_Separator.BorderSizePixel = 0

			if p3.parentWidget.type == "SameLine" then
				iris_Separator.Size = UDim2.new(0, 1, p._config.ItemWidth.Scale, p._config.ItemWidth.Offset)
			else
				iris_Separator.Size = UDim2.new(p._config.ItemWidth.Scale, p._config.ItemWidth.Offset, 0, 1)
			end

			iris_Separator.LayoutOrder = p3.ZIndex

			p2.UIListLayout(iris_Separator, Enum.FillDirection.Vertical, UDim.new(0, 0))

			return iris_Separator
		end,
		Update = function(_) end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end
	})

	p.WidgetConstructor("Indent", {
		hasState = false,
		hasChildren = true,
		Args = { Width = 1 },
		Events = {},
		Generate = function(p3)
			local iris_Indent = Instance.new("Frame")
			iris_Indent.Name = "Iris_Indent"
			iris_Indent.BackgroundTransparency = 1
			iris_Indent.BorderSizePixel = 0
			iris_Indent.Size = UDim2.new(p._config.ItemWidth, UDim.new())
			iris_Indent.AutomaticSize = Enum.AutomaticSize.Y
			iris_Indent.LayoutOrder = p3.ZIndex

			p2.UIListLayout(iris_Indent, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))
			p2.UIPadding(iris_Indent, Vector2.zero)

			return iris_Indent
		end,
		Update = function(p3)
			local instance = p3.Instance
			local v

			if p3.arguments.Width then
				v = p3.arguments.Width
			else
				v = p._config.IndentSpacing
			end

			instance.UIPadding.PaddingLeft = UDim.new(0, v)
		end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end,
		ChildAdded = function(p3, _)
			return p3.Instance
		end
	})

	p.WidgetConstructor("SameLine", {
		hasState = false,
		hasChildren = true,
		Args = { Width = 1, VerticalAlignment = 2, HorizontalAlignment = 3 },
		Events = {},
		Generate = function(p3)
			local iris_SameLine = Instance.new("Frame")
			iris_SameLine.Name = "Iris_SameLine"
			iris_SameLine.BackgroundTransparency = 1
			iris_SameLine.BorderSizePixel = 0
			iris_SameLine.Size = UDim2.new(p._config.ItemWidth, UDim.new())
			iris_SameLine.AutomaticSize = Enum.AutomaticSize.Y
			iris_SameLine.LayoutOrder = p3.ZIndex

			p2.UIListLayout(iris_SameLine, Enum.FillDirection.Horizontal, UDim.new(0, 0))

			return iris_SameLine
		end,
		Update = function(p3)
			local uiListLayout = p3.Instance.UIListLayout
			local v

			if p3.arguments.Width then
				v = p3.arguments.Width
			else
				v = p._config.ItemSpacing.X
			end

			uiListLayout.Padding = UDim.new(0, v)

			if p3.arguments.VerticalAlignment then
				uiListLayout.VerticalAlignment = p3.arguments.VerticalAlignment
			else
				uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			end

			if p3.arguments.HorizontalAlignment then
				uiListLayout.HorizontalAlignment = p3.arguments.HorizontalAlignment
			else
				uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			end
		end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end,
		ChildAdded = function(p3, _)
			return p3.Instance
		end
	})

	p.WidgetConstructor("Group", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(p3)
			local iris_Group = Instance.new("Frame")
			iris_Group.Name = "Iris_Group"
			iris_Group.AutomaticSize = Enum.AutomaticSize.XY
			iris_Group.Size = UDim2.fromOffset(0, 0)
			iris_Group.BackgroundTransparency = 1
			iris_Group.BorderSizePixel = 0
			iris_Group.LayoutOrder = p3.ZIndex
			iris_Group.ClipsDescendants = false

			p2.UIListLayout(iris_Group, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))

			return iris_Group
		end,
		Update = function(_) end,
		Discard = function(p3)
			p3.Instance:Destroy()
		end,
		ChildAdded = function(p3, _)
			return p3.Instance
		end
	})
end