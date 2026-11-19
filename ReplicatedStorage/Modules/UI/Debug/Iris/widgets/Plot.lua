require(script.Parent.Parent.Types)

return function(data, data2)
	data.WidgetConstructor("ProgressBar", {
		hasState = true,
		hasChildren = false,
		Args = { Text = 1, Format = 2 },
		Events = {
			["hovered"] = data2.EVENTS.hover(function(p)
				return p.Instance
			end),
			changed = {
				Init = function(_) end,
				Get = function(p): boolean
					return p.lastChangedTick == data._cycleTick
				end
			}
		},
		Generate = function(p)
			local iris_ProgressBar = Instance.new("Frame")
			iris_ProgressBar.Name = "Iris_ProgressBar"
			iris_ProgressBar.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			iris_ProgressBar.BackgroundTransparency = 1
			iris_ProgressBar.AutomaticSize = Enum.AutomaticSize.Y
			iris_ProgressBar.LayoutOrder = p.ZIndex

			local uiListLayout = data2.UIListLayout(
				iris_ProgressBar,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local bar = Instance.new("Frame")
			bar.Name = "Bar"
			bar.Size = UDim2.new(data._config.ContentWidth, data._config.ContentHeight)
			bar.BackgroundColor3 = data._config.FrameBgColor
			bar.BackgroundTransparency = data._config.FrameBgTransparency
			bar.BorderSizePixel = 0
			bar.AutomaticSize = Enum.AutomaticSize.Y
			bar.ClipsDescendants = true

			data2.applyFrameStyle(bar, true)

			bar.Parent = iris_ProgressBar

			local progress = Instance.new("TextLabel")
			progress.Name = "Progress"
			progress.AutomaticSize = Enum.AutomaticSize.Y
			progress.Size = UDim2.new(UDim.new(0, 0), data._config.ContentHeight)
			progress.BackgroundColor3 = data._config.PlotHistogramColor
			progress.BackgroundTransparency = data._config.PlotHistogramTransparency
			progress.BorderSizePixel = 0

			data2.applyTextStyle(progress)
			data2.UIPadding(progress, data._config.FramePadding)
			data2.UICorner(progress, data._config.FrameRounding)

			progress.Text = ""
			progress.Parent = bar

			local value = Instance.new("TextLabel")
			value.Name = "Value"
			value.AutomaticSize = Enum.AutomaticSize.XY
			value.Size = UDim2.new(UDim.new(0, 0), data._config.ContentHeight)
			value.BackgroundTransparency = 1
			value.BorderSizePixel = 0
			value.ZIndex = 1

			data2.applyTextStyle(value)
			data2.UIPadding(value, data._config.FramePadding)

			value.Parent = bar

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.AnchorPoint = Vector2.new(0, 0.5)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.LayoutOrder = 1

			data2.applyTextStyle(textLabel)
			data2.UIPadding(value, data._config.FramePadding)

			textLabel.Parent = iris_ProgressBar

			return iris_ProgressBar
		end,
		GenerateState = function(p)
			if p.state.progress == nil then
				p.state.progress = data._widgetState(p, "Progress", 0)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local value = instance.Bar.Value

			if p.arguments.Format ~= nil and typeof(p.arguments.Format) == "string" then
				value.Text = p.arguments.Format
			end

			textLabel.Text = p.arguments.Text or "Progress Bar"
		end,
		UpdateState = function(state)
			local bar = state.Instance.Bar
			local progress = bar.Progress
			local value = bar.Value

			local v = math.clamp(state.state.progress.value, 0, 1)
			local x = bar.AbsoluteSize.X
			local x2 = value.AbsoluteSize.X

			if x * (1 - v) < x2 then
				value.AnchorPoint = Vector2.xAxis
				value.Position = UDim2.fromScale(1, 0)
			else
				value.AnchorPoint = Vector2.zero
				value.Position = UDim2.new(v, 0, 0, 0)
			end

			progress.Size = UDim2.new(UDim.new(v, 0), progress.Size.Height)

			if state.arguments.Format == nil or typeof(state.arguments.Format) ~= "string" then
				value.Text = string.format("%d%%", v * 100)
			else
				value.Text = state.arguments.Format
			end

			state.lastChangedTick = data._cycleTick + 1
		end,
		Discard = function(p)
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})

	local function createLine(plot, i: number) -- 1 equivalent call inferred from this helper
		local frame = Instance.new("Frame")
		frame.Name = tostring(i)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = data._config.PlotLinesColor
		frame.BackgroundTransparency = data._config.PlotLinesTransparency
		frame.BorderSizePixel = 0

		frame.Parent = plot

		return frame
	end

	local function clearLine(state) -- 2 equivalent calls inferred from this helper
		if state.HoveredLine then
			state.HoveredLine.BackgroundColor3 = data._config.PlotLinesColor
			state.HoveredLine.BackgroundTransparency = data._config.PlotLinesTransparency
			state.HoveredLine = false
			state.state.hovered:set(nil)
		end
	end

	local function updateLine(state, flag: boolean?)
		local plot = state.Instance.Background.Plot

		local mouseLocation = data2.getMouseLocation()

		local v = plot.AbsolutePosition - data2.GuiOffset
		local v2 = math.ceil((mouseLocation.X - v.X) / plot.AbsoluteSize.X * #state.Lines)
		local line = state.Lines[v2]

		if line then
			if line ~= state.HoveredLine and not flag then
				clearLine(state) -- inferred equivalent call
			end

			local v3 = state.state.values.value[v2]
			local v4 = state.state.values.value[v2 + 1]

			if v3 and v4 then
				if math.floor(v3) == v3 and math.floor(v4) == v4 then
					state.Tooltip.Text = ("%d: %d\n%d: %d"):format(v2, v3, v2 + 1, v4)
				else
					state.Tooltip.Text = ("%d: %.3f\n%d: %.3f"):format(v2, v3, v2 + 1, v4)
				end
			end

			state.HoveredLine = line
			line.BackgroundColor3 = data._config.PlotLinesHoveredColor
			line.BackgroundTransparency = data._config.PlotLinesHoveredTransparency

			if flag then
				state.state.hovered.value = { v3, v4 }
			else
				state.state.hovered:set({ v3, v4 })
			end
		end
	end

	data.WidgetConstructor("PlotLines", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Height = 2,
			Min = 3,
			Max = 4,
			TextOverlay = 5
		},
		Events = {
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			local iris_PlotLines = Instance.new("Frame")
			iris_PlotLines.Name = "Iris_PlotLines"
			iris_PlotLines.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			iris_PlotLines.BackgroundTransparency = 1
			iris_PlotLines.BorderSizePixel = 0
			iris_PlotLines.ZIndex = state.ZIndex
			iris_PlotLines.LayoutOrder = state.ZIndex

			local uiListLayout = data2.UIListLayout(
				iris_PlotLines,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local background = Instance.new("Frame")
			background.Name = "Background"
			background.Size = UDim2.new(data._config.ContentWidth, UDim.new(1, 0))
			background.BackgroundColor3 = data._config.FrameBgColor
			background.BackgroundTransparency = data._config.FrameBgTransparency
			data2.applyFrameStyle(background)

			background.Parent = iris_PlotLines

			local plot = Instance.new("Frame")
			plot.Name = "Plot"
			plot.Size = UDim2.fromScale(1, 1)
			plot.BackgroundTransparency = 1
			plot.BorderSizePixel = 0
			plot.ClipsDescendants = true

			plot:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				state.state.values.lastChangeTick = data._cycleTick
				data._widgets.PlotLines.UpdateState(state)
			end)

			local overlayText = Instance.new("TextLabel")
			overlayText.Name = "OverlayText"
			overlayText.AutomaticSize = Enum.AutomaticSize.XY
			overlayText.AnchorPoint = Vector2.new(0.5, 0)
			overlayText.Size = UDim2.fromOffset(0, 0)
			overlayText.Position = UDim2.fromScale(0.5, 0)
			overlayText.BackgroundTransparency = 1
			overlayText.BorderSizePixel = 0
			overlayText.ZIndex = 2

			data2.applyTextStyle(overlayText)

			overlayText.Parent = plot

			local iris_Tooltip = Instance.new("TextLabel")
			iris_Tooltip.Name = "Iris_Tooltip"
			iris_Tooltip.AutomaticSize = Enum.AutomaticSize.XY
			iris_Tooltip.Size = UDim2.fromOffset(0, 0)
			iris_Tooltip.BackgroundColor3 = data._config.PopupBgColor
			iris_Tooltip.BackgroundTransparency = data._config.PopupBgTransparency
			iris_Tooltip.BorderSizePixel = 0
			iris_Tooltip.Visible = false

			data2.applyTextStyle(iris_Tooltip)
			data2.UIStroke(
				iris_Tooltip,
				data._config.PopupBorderSize,
				data._config.BorderActiveColor,
				data._config.BorderActiveTransparency
			)
			data2.UIPadding(iris_Tooltip, data._config.WindowPadding)

			if data._config.PopupRounding > 0 then
				data2.UICorner(iris_Tooltip, data._config.PopupRounding)
			end

			local popupScreenGui = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")
			iris_Tooltip.Parent = popupScreenGui and popupScreenGui:FindFirstChild("TooltipContainer")

			state.Tooltip = iris_Tooltip

			data2.applyMouseMoved(plot, function()
				updateLine(state)
			end)

			data2.applyMouseLeave(plot, function()
				clearLine(state) -- inferred equivalent call
			end)

			plot.Parent = background

			state.Lines = {}
			state.HoveredLine = false

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = state.ZIndex + 3
			textLabel.LayoutOrder = state.ZIndex + 3

			data2.applyTextStyle(textLabel)

			textLabel.Parent = iris_PlotLines

			return iris_PlotLines
		end,
		GenerateState = function(p)
			if p.state.values == nil then
				p.state.values = data._widgetState(p, "values", { 0, 1 })
			end

			if p.state.hovered == nil then
				p.state.hovered = data._widgetState(p, "hovered", nil)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local overlayText = instance.Background.Plot.OverlayText

			textLabel.Text = p.arguments.Text or "Plot Lines"
			overlayText.Text = p.arguments.TextOverlay or ""
			instance.Size = UDim2.new(1, 0, 0, p.arguments.Height or 0)
		end,
		UpdateState = function(data3)
			if data3.state.hovered.lastChangeTick == data._cycleTick then
				if data3.state.hovered.value then
					data3.Tooltip.Visible = true
				else
					data3.Tooltip.Visible = false
				end
			end

			if data3.state.values.lastChangeTick == data._cycleTick then
				local plot = data3.Instance.Background.Plot

				local value = data3.state.values.value
				local v = #value - 1
				local count = #data3.Lines

				local min = data3.arguments.Min or 1e999
				local max = data3.arguments.Max or -1e999

				if min == nil or max == nil then
					for _, v2 in value do
						min = math.min(min, v2)
						max = math.max(max, v2)
					end
				end

				if count < v then
					for i = count + 1, v do
						local lines = data3.Lines
						table.insert(lines, createLine(plot, i)) -- inferred equivalent call
					end
				elseif v < count then
					for _ = v + 1, count do
						local v2 = table.remove(data3.Lines)

						if v2 then
							v2:Destroy()
						end
					end
				end

				local v2 = max - min
				local absoluteSize = plot.AbsoluteSize

				for i = 1, v do
					local v3 = value[i]
					local v4 = value[i + 1]
					local v5 = absoluteSize * Vector2.new((i - 1) / v, (max - v3) / v2)
					local v6 = absoluteSize * Vector2.new(i / v, (max - v4) / v2)
					local midpoint = (v5 + v6) / 2

					data3.Lines[i].Size = UDim2.fromOffset((v6 - v5).Magnitude + 1, 1)
					data3.Lines[i].Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
					data3.Lines[i].Rotation = math.atan2(v6.Y - v5.Y, v6.X - v5.X) * 57.29577951308232
				end

				if data3.HoveredLine then
					updateLine(data3, true)
				end
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			p.Tooltip:Destroy()
			data2.discardState(p)
		end
	})

	local function createBlock(plot, i: number) -- 1 equivalent call inferred from this helper
		local frame = Instance.new("Frame")
		frame.Name = tostring(i)
		frame.BackgroundColor3 = data._config.PlotHistogramColor
		frame.BackgroundTransparency = data._config.PlotHistogramTransparency
		frame.BorderSizePixel = 0

		frame.Parent = plot

		return frame
	end

	local function clearBlock(state) -- 2 equivalent calls inferred from this helper
		if state.HoveredBlock then
			state.HoveredBlock.BackgroundColor3 = data._config.PlotHistogramColor
			state.HoveredBlock.BackgroundTransparency = data._config.PlotHistogramTransparency
			state.HoveredBlock = false
			state.state.hovered:set(nil)
		end
	end

	local function updateBlock(state, flag: boolean?)
		local plot = state.Instance.Background.Plot

		local mouseLocation = data2.getMouseLocation()

		local v = plot.AbsolutePosition - data2.GuiOffset
		local v2 = math.ceil((mouseLocation.X - v.X) / plot.AbsoluteSize.X * #state.Blocks)
		local block = state.Blocks[v2]

		if block then
			if block ~= state.HoveredBlock and not flag then
				clearBlock(state) -- inferred equivalent call
			end

			local v3 = state.state.values.value[v2]

			if v3 then
				local tooltip = state.Tooltip
				local text

				if math.floor(v3) == v3 then
					text = ("%d: %d"):format(v2, v3)
				else
					text = ("%d: %.3f"):format(v2, v3)
				end

				tooltip.Text = text
			end

			state.HoveredBlock = block
			block.BackgroundColor3 = data._config.PlotHistogramHoveredColor
			block.BackgroundTransparency = data._config.PlotHistogramHoveredTransparency

			if flag then
				state.state.hovered.value = v3
			else
				state.state.hovered:set(v3)
			end
		end
	end

	data.WidgetConstructor("PlotHistogram", {
		hasState = true,
		hasChildren = false,
		Args = {
			Text = 1,
			Height = 2,
			Min = 3,
			Max = 4,
			TextOverlay = 5,
			BaseLine = 6
		},
		Events = {
			hovered = data2.EVENTS.hover(function(p)
				return p.Instance
			end)
		},
		Generate = function(state)
			local iris_PlotHistogram = Instance.new("Frame")
			iris_PlotHistogram.Name = "Iris_PlotHistogram"
			iris_PlotHistogram.Size = UDim2.new(data._config.ItemWidth, UDim.new())
			iris_PlotHistogram.BackgroundTransparency = 1
			iris_PlotHistogram.BorderSizePixel = 0
			iris_PlotHistogram.ZIndex = state.ZIndex
			iris_PlotHistogram.LayoutOrder = state.ZIndex

			local uiListLayout = data2.UIListLayout(
				iris_PlotHistogram,
				Enum.FillDirection.Horizontal,
				UDim.new(0, data._config.ItemInnerSpacing.X)
			)
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

			local background = Instance.new("Frame")
			background.Name = "Background"
			background.Size = UDim2.new(data._config.ContentWidth, UDim.new(1, 0))
			background.BackgroundColor3 = data._config.FrameBgColor
			background.BackgroundTransparency = data._config.FrameBgTransparency
			data2.applyFrameStyle(background)

			background.UIPadding.PaddingRight = UDim.new(0, data._config.FramePadding.X - 1)

			background.Parent = iris_PlotHistogram

			local plot = Instance.new("Frame")
			plot.Name = "Plot"
			plot.Size = UDim2.fromScale(1, 1)
			plot.BackgroundTransparency = 1
			plot.BorderSizePixel = 0
			plot.ClipsDescendants = true

			local overlayText = Instance.new("TextLabel")
			overlayText.Name = "OverlayText"
			overlayText.AutomaticSize = Enum.AutomaticSize.XY
			overlayText.AnchorPoint = Vector2.new(0.5, 0)
			overlayText.Size = UDim2.fromOffset(0, 0)
			overlayText.Position = UDim2.fromScale(0.5, 0)
			overlayText.BackgroundTransparency = 1
			overlayText.BorderSizePixel = 0
			overlayText.ZIndex = 2

			data2.applyTextStyle(overlayText)

			overlayText.Parent = plot

			local iris_Tooltip = Instance.new("TextLabel")
			iris_Tooltip.Name = "Iris_Tooltip"
			iris_Tooltip.AutomaticSize = Enum.AutomaticSize.XY
			iris_Tooltip.Size = UDim2.fromOffset(0, 0)
			iris_Tooltip.BackgroundColor3 = data._config.PopupBgColor
			iris_Tooltip.BackgroundTransparency = data._config.PopupBgTransparency
			iris_Tooltip.BorderSizePixel = 0
			iris_Tooltip.Visible = false

			data2.applyTextStyle(iris_Tooltip)
			data2.UIStroke(
				iris_Tooltip,
				data._config.PopupBorderSize,
				data._config.BorderActiveColor,
				data._config.BorderActiveTransparency
			)
			data2.UIPadding(iris_Tooltip, data._config.WindowPadding)

			if data._config.PopupRounding > 0 then
				data2.UICorner(iris_Tooltip, data._config.PopupRounding)
			end

			local popupScreenGui = data._rootInstance and data._rootInstance:FindFirstChild("PopupScreenGui")
			iris_Tooltip.Parent = popupScreenGui and popupScreenGui:FindFirstChild("TooltipContainer")

			state.Tooltip = iris_Tooltip

			data2.applyMouseMoved(plot, function()
				updateBlock(state)
			end)

			data2.applyMouseLeave(plot, function()
				clearBlock(state) -- inferred equivalent call
			end)

			plot.Parent = background

			state.Blocks = {}
			state.HoveredBlock = false

			local textLabel = Instance.new("TextLabel")
			textLabel.Name = "TextLabel"
			textLabel.AutomaticSize = Enum.AutomaticSize.XY
			textLabel.Size = UDim2.fromOffset(0, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.ZIndex = state.ZIndex + 3
			textLabel.LayoutOrder = state.ZIndex + 3

			data2.applyTextStyle(textLabel)

			textLabel.Parent = iris_PlotHistogram

			return iris_PlotHistogram
		end,
		GenerateState = function(p)
			if p.state.values == nil then
				p.state.values = data._widgetState(p, "values", { 1 })
			end

			if p.state.hovered == nil then
				p.state.hovered = data._widgetState(p, "hovered", nil)
			end
		end,
		Update = function(p)
			local instance = p.Instance
			local textLabel = instance.TextLabel
			local overlayText = instance.Background.Plot.OverlayText

			textLabel.Text = p.arguments.Text or "Plot Histogram"
			overlayText.Text = p.arguments.TextOverlay or ""
			instance.Size = UDim2.new(1, 0, 0, p.arguments.Height or 0)
		end,
		UpdateState = function(data3)
			if data3.state.hovered.lastChangeTick == data._cycleTick then
				if data3.state.hovered.value then
					data3.Tooltip.Visible = true
				else
					data3.Tooltip.Visible = false
				end
			end

			if data3.state.values.lastChangeTick == data._cycleTick then
				local plot = data3.Instance.Background.Plot

				local value = data3.state.values.value
				local count = #value
				local count2 = #data3.Blocks

				local v = data3.arguments.Min or 1e999
				local v2 = data3.arguments.Max or -1e999
				local baseLine = data3.arguments.BaseLine or 0

				if v == nil or v2 == nil then
					for _, v3 in value do
						v = math.min(v or v3, v3)
						v2 = math.max(v2 or v3, v3)
					end
				end

				if count2 < count then
					for i = count2 + 1, count do
						local blocks = data3.Blocks
						table.insert(blocks, createBlock(plot, i)) -- inferred equivalent call
					end
				elseif count < count2 then
					for _ = count + 1, count2 do
						local v3 = table.remove(data3.Blocks)

						if v3 then
							v3:Destroy()
						end
					end
				end

				local v3 = v2 - v
				local udim = UDim.new(1 / count, -1)

				for i = 1, count do
					local v4 = value[i]

					if v4 >= 0 then
						data3.Blocks[i].Size = UDim2.new(udim, UDim.new((v4 - baseLine) / v3))
						data3.Blocks[i].Position = UDim2.fromScale((i - 1) / count, (v2 - v4) / v3)
					else
						data3.Blocks[i].Size = UDim2.new(udim, UDim.new((baseLine - v4) / v3))
						data3.Blocks[i].Position = UDim2.fromScale((i - 1) / count, (v2 - baseLine) / v3)
					end
				end

				if data3.HoveredBlock then
					updateBlock(data3, true)
				end
			end
		end,
		Discard = function(p)
			p.Instance:Destroy()
			p.Tooltip:Destroy()
			data2.discardState(p)
		end
	})
end