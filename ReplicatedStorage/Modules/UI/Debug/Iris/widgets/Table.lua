require(script.Parent.Parent.Types)

return function(data, data2)
	local v = {}
	local v2 = {}
	local v3 = false
	local v4 = nil
	local v5 = 0
	local v6 = -1
	local v7 = -1
	local v8 = 0

	local function CalculateMinColumnWidth(k, k2: number)
		local maxX = 0

		for _, cellInstance in k._cellInstances do
			for _, guiObject in cellInstance[k2]:GetChildren() do
				if guiObject:IsA("GuiObject") then
					maxX = math.max(maxX, guiObject.AbsoluteSize.X)
				end
			end
		end

		k._minWidths[k2] = maxX + 2 * data._config.CellPadding.X
	end

	table.insert(data._postCycleCallbacks, function()
		for _, v9 in v do
			for k, rowCycle in v9._rowCycles do
				if not (rowCycle < data._cycleTick - 1) then
					continue
				end

				local rowInstance = v9._rowInstances[k]
				local rowBorder = v9._rowBorders[k - 1]

				if rowInstance ~= nil then
					rowInstance:Destroy()
				end

				if rowBorder ~= nil then
					rowBorder:Destroy()
				end

				v9._rowInstances[k] = nil
				v9._rowBorders[k - 1] = nil
				v9._cellInstances[k] = nil
				v9._rowCycles[k] = nil
			end

			v9._rowIndex = 1
			v9._columnIndex = 1

			v9.Instance.BorderContainer.Size = UDim2.new(1, 0, 0, v9._rowContainer.AbsoluteSize.Y)
			v9._columnBorders[0].Size = UDim2.new(0, 5, 0, v9._rowContainer.AbsoluteSize.Y)
		end

		for k, list in v2 do
			local flag = false

			for k2, _ in list do
				CalculateMinColumnWidth(k, k2)
				flag = true
			end

			if not flag then
				continue
			end

			table.clear(list)
			data._widgets.Table.UpdateState(k)
		end
	end)

	local function UpdateActiveColumn()
		if v3 == false or v4 == nil then
			return
		end

		local widths = v4.state.widths
		local numColumns = v4.arguments.NumColumns
		local instance = v4.Instance
		local borderContainer = instance.BorderContainer
		local fixedWidth = v4.arguments.FixedWidth
		local v9 = 2 * data._config.CellPadding.X

		if v6 == -1 then
			v6 = widths.value[v5]

			if v6 == 0 then
				v6 = v9 / instance.AbsoluteSize.X
			end

			v7 = widths.value[v5 + 1] or -1

			if v7 == 0 then
				v7 = v9 / instance.AbsoluteSize.X
			end
		end

		local x = instance.AbsolutePosition.X

		local v10 = v5 == 1 and 0
			or math.floor(borderContainer:FindFirstChild(`Border_{v5 - 1}`).AbsolutePosition.X + 3 - x)

		local v11 = v5
		local v12

		if numColumns - 1 <= v11 then
			v12 = instance.AbsoluteSize.X
		else
			v12 = math.floor(borderContainer:FindFirstChild(`Border_{v5 + 1}`).AbsolutePosition.X + 3 - x)
		end

		local v13 = x - data2.GuiOffset.X
		local v14 = math.clamp(data2.getMouseLocation().X, v10 + v13 + v9, v12 + v13 - v9) - v8
		local v15 = v8 - v13 - v10
		local v16 = v6 / v15

		if fixedWidth then
			widths.value[v5] = math.clamp(math.round(v6 + v14), v9, instance.AbsoluteSize.X - v10)
		else
			local v17 = v16 * v14
			widths.value[v5] = math.clamp(v6 + v17, 0, (v12 - v10 - v9) / instance.AbsoluteSize.X)

			if v5 < numColumns then
				widths.value[v5 + 1] = math.clamp(v7 - v17, 0, 1)
			end
		end

		widths:set(widths.value, true)
	end

	local function ColumnMouseDown(p, zIndex: number) -- 1 equivalent call inferred from this helper
		v3 = true
		v4 = p
		v5 = zIndex
		v6 = -1
		v7 = -1
		v8 = data2.getMouseLocation().X
	end

	data2.registerEvent("InputChanged", function()
		if not data._started then
			return
		end

		UpdateActiveColumn()
	end)

	data2.registerEvent("InputEnded", function(p)
		if not data._started then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 and v3 then
			v3 = false
			v4 = nil
			v5 = 0
			v6 = -1
			v7 = -1
			v8 = 0
		end
	end)

	local function GenerateCell(_, i: number, udim: UDim, flag: boolean)
		local v9

		if flag then
			v9 = Instance.new("TextButton")
			v9.Text = ""
			v9.AutoButtonColor = false
		else
			v9 = Instance.new("Frame")
		end

		v9.Name = `Cell_{i}`
		v9.AutomaticSize = Enum.AutomaticSize.Y
		v9.Size = UDim2.new(udim, UDim.new())
		v9.BackgroundTransparency = 1
		v9.ZIndex = i
		v9.LayoutOrder = i
		v9.ClipsDescendants = true

		if flag then
			data2.applyInteractionHighlights("Background", v9, v9, {
				Color = data._config.HeaderColor,
				Transparency = 1,
				HoveredColor = data._config.HeaderHoveredColor,
				HoveredTransparency = data._config.HeaderHoveredTransparency,
				ActiveColor = data._config.HeaderActiveColor,
				ActiveTransparency = data._config.HeaderActiveTransparency
			})
		end

		data2.UIPadding(v9, data._config.CellPadding)
		data2.UIListLayout(v9, Enum.FillDirection.Vertical, UDim.new())
		data2.UISizeConstraint(v9, Vector2.new(2 * data._config.CellPadding.X, 0))

		return v9
	end

	local function GenerateColumnBorder(state, zIndex: number, p: string)
		local imageButton = Instance.new("ImageButton")
		imageButton.Name = `Border_{zIndex}`
		imageButton.Size = UDim2.new(0, 5, 1, 0)
		imageButton.BackgroundTransparency = 1
		imageButton.AutoButtonColor = false
		imageButton.Image = ""
		imageButton.ImageTransparency = 1
		imageButton.ZIndex = zIndex
		imageButton.LayoutOrder = zIndex * 2

		local v9 = zIndex == state.arguments.NumColumns and 3 or 2

		local line = Instance.new("Frame")
		line.Name = "Line"
		line.Size = UDim2.new(0, 1, 1, 0)
		line.Position = UDim2.fromOffset(v9, 0)
		line.BackgroundColor3 = data._config[`TableBorder{p}Color`]
		line.BackgroundTransparency = data._config[`TableBorder{p}Transparency`]
		line.BorderSizePixel = 0

		line.Parent = imageButton

		local hover = Instance.new("Frame")
		hover.Name = "Hover"
		hover.Size = UDim2.new(0, 1, 1, 0)
		hover.Position = UDim2.fromOffset(v9, 0)
		hover.BackgroundColor3 = data._config[`TableBorder{p}Color`]
		hover.BackgroundTransparency = data._config[`TableBorder{p}Transparency`]
		hover.BorderSizePixel = 0

		hover.Visible = state.arguments.Resizable

		hover.Parent = imageButton

		data2.applyInteractionHighlights("Background", imageButton, hover, {
			Color = data._config.ResizeGripColor,
			Transparency = 1,
			HoveredColor = data._config.ResizeGripHoveredColor,
			HoveredTransparency = data._config.ResizeGripHoveredTransparency,
			ActiveColor = data._config.ResizeGripActiveColor,
			ActiveTransparency = data._config.ResizeGripActiveTransparency
		})

		data2.applyButtonDown(imageButton, function()
			if state.arguments.Resizable then
				ColumnMouseDown(state, zIndex) -- inferred equivalent call
			end
		end)

		return imageButton
	end

	local function GenerateRow(data3, rowIndex: number)
		local frame = Instance.new("Frame")
		frame.Name = `Row_{rowIndex}`
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.Size = UDim2.fromScale(1, 0)

		if rowIndex == 0 then
			frame.BackgroundColor3 = data._config.TableHeaderColor
			frame.BackgroundTransparency = data._config.TableHeaderTransparency
		elseif data3.arguments.RowBackground == true then
			if rowIndex % 2 == 0 then
				frame.BackgroundColor3 = data._config.TableRowBgAltColor
				frame.BackgroundTransparency = data._config.TableRowBgAltTransparency
			else
				frame.BackgroundColor3 = data._config.TableRowBgColor
				frame.BackgroundTransparency = data._config.TableRowBgTransparency
			end
		else
			frame.BackgroundTransparency = 1
		end

		frame.BorderSizePixel = 0
		frame.ZIndex = rowIndex * 2 - 1
		frame.LayoutOrder = rowIndex * 2 - 1
		frame.ClipsDescendants = true

		data2.UIListLayout(frame, Enum.FillDirection.Horizontal, UDim.new())

		data3._cellInstances[rowIndex] = table.create(data3.arguments.NumColumns)

		for i = 1, data3.arguments.NumColumns do
			local generateCell = GenerateCell(data3, i, data3._widths[i], rowIndex == 0)
			generateCell.Parent = frame
			data3._cellInstances[rowIndex][i] = generateCell
		end

		data3._rowInstances[rowIndex] = frame

		return frame
	end

	local function GenerateRowBorder(_, p: number, p2: string)
		local frame = Instance.new("Frame")
		frame.Name = `Border_{p}`
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.BackgroundTransparency = 1
		frame.ZIndex = p * 2
		frame.LayoutOrder = p * 2

		local line = Instance.new("Frame")
		line.Name = "Line"
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.Size = UDim2.new(1, 0, 0, 1)
		line.BackgroundColor3 = data._config[`TableBorder{p2}Color`]
		line.BackgroundTransparency = data._config[`TableBorder{p2}Transparency`]
		line.BorderSizePixel = 0

		line.Parent = frame

		return frame
	end

	data.WidgetConstructor("Table", {
		hasState = true,
		hasChildren = true,
		Args = {
			NumColumns = 1,
			Header = 2,
			RowBackground = 3,
			OuterBorders = 4,
			InnerBorders = 5,
			Resizable = 6,
			FixedWidth = 7,
			ProportionalWidth = 8,
			LimitTableWidth = 9
		},
		Events = {},
		Generate = function(state)
			v[state.ID] = state
			v2[state] = {}

			local iris_Table = Instance.new("Frame")
			iris_Table.Name = "Iris_Table"
			iris_Table.AutomaticSize = Enum.AutomaticSize.Y
			iris_Table.Size = UDim2.fromScale(1, 0)
			iris_Table.BackgroundTransparency = 1
			iris_Table.ZIndex = state.ZIndex
			iris_Table.LayoutOrder = state.ZIndex

			local rowContainer = Instance.new("Frame")
			rowContainer.Name = "RowContainer"
			rowContainer.AutomaticSize = Enum.AutomaticSize.Y
			rowContainer.Size = UDim2.fromScale(1, 0)
			rowContainer.BackgroundTransparency = 1
			rowContainer.ZIndex = 1

			data2.UISizeConstraint(rowContainer)
			data2.UIListLayout(rowContainer, Enum.FillDirection.Vertical, UDim.new())

			rowContainer.Parent = iris_Table
			state._rowContainer = rowContainer

			local borderContainer = Instance.new("Frame")
			borderContainer.Name = "BorderContainer"
			borderContainer.Size = UDim2.fromScale(1, 1)
			borderContainer.BackgroundTransparency = 1
			borderContainer.ZIndex = 2
			borderContainer.ClipsDescendants = true

			data2.UISizeConstraint(borderContainer)
			data2.UIListLayout(borderContainer, Enum.FillDirection.Horizontal, UDim.new())
			data2.UIStroke(
				borderContainer,
				1,
				data._config.TableBorderStrongColor,
				data._config.TableBorderStrongTransparency
			)

			borderContainer.Parent = iris_Table

			state._columnIndex = 1
			state._rowIndex = 1
			state._rowInstances = {}
			state._cellInstances = {}
			state._rowBorders = {}
			state._columnBorders = {}
			state._rowCycles = {}

			local v9 = #data._postCycleCallbacks + 1
			local v10 = data._cycleTick + 1
			data._postCycleCallbacks[v9] = function()
				if v10 <= data._cycleTick then
					if state.lastCycleTick ~= -1 then
						state.state.widths.lastChangeTick = data._cycleTick
						data._widgets.Table.UpdateState(state)
					end

					data._postCycleCallbacks[v9] = nil
				end
			end

			return iris_Table
		end,
		GenerateState = function(state)
			local numColumns = state.arguments.NumColumns

			if state.state.widths == nil then
				local v9 = table.create(numColumns, 1 / numColumns)
				state.state.widths = data._widgetState(state, "widths", v9)
			end

			state._widths = table.create(numColumns, UDim.new())
			state._minWidths = table.create(numColumns, 0)

			local instance = state.Instance
			local borderContainer = instance.BorderContainer

			state._cellInstances[-1] = table.create(numColumns)

			for i = 1, numColumns do
				local parent = GenerateColumnBorder(state, i, "Light")
				parent.Visible = state.arguments.InnerBorders
				state._columnBorders[i] = parent
				parent.Parent = borderContainer

				local generateCell = GenerateCell(state, i, state._widths[i], false)
				local uiSizeConstraint = generateCell:FindFirstChild("UISizeConstraint")
				uiSizeConstraint.MinSize = Vector2.new(
					2 * data._config.CellPadding.X + (i > 1 and -2 or 0) + (i < numColumns and -3 or 0),
					0
				)

				generateCell.LayoutOrder = i * 2 - 1
				state._cellInstances[-1][i] = generateCell
				generateCell.Parent = borderContainer
			end

			local parent = GenerateColumnBorder(state, numColumns, "Strong")
			state._columnBorders[0] = parent
			parent.Parent = instance
		end,
		Update = function(data3)
			local numColumns = data3.arguments.NumColumns
			assert(numColumns >= 1, "Iris.Table must have at least one column.")

			if data3._widths ~= nil and #data3._widths ~= numColumns then
				data3.arguments.NumColumns = #data3._widths
				warn("NumColumns cannot change once set. See documentation.")
			end

			for k, rowInstance in data3._rowInstances do
				if k == 0 then
					rowInstance.BackgroundColor3 = data._config.TableHeaderColor
					rowInstance.BackgroundTransparency = data._config.TableHeaderTransparency
				elseif data3.arguments.RowBackground == true then
					if k % 2 == 0 then
						rowInstance.BackgroundColor3 = data._config.TableRowBgAltColor
						rowInstance.BackgroundTransparency = data._config.TableRowBgAltTransparency
					else
						rowInstance.BackgroundColor3 = data._config.TableRowBgColor
						rowInstance.BackgroundTransparency = data._config.TableRowBgTransparency
					end
				else
					rowInstance.BackgroundTransparency = 1
				end
			end

			for _, rowBorder in data3._rowBorders do
				rowBorder.Visible = data3.arguments.InnerBorders
			end

			for _, columnBorder in data3._columnBorders do
				columnBorder.Visible = data3.arguments.InnerBorders or data3.arguments.Resizable
			end

			for _, columnBorder in data3._columnBorders do
				local hover = columnBorder:FindFirstChild("Hover")

				if hover then
					hover.Visible = data3.arguments.Resizable
				end
			end

			if data3._columnBorders[numColumns] ~= nil then
				data3._columnBorders[numColumns].Visible = not data3.arguments.LimitTableWidth
					and (data3.arguments.Resizable or data3.arguments.InnerBorders)
				data3._columnBorders[0].Visible = data3.arguments.LimitTableWidth
					and (data3.arguments.Resizable or data3.arguments.OuterBorders)
			end

			local rowInstance = data3._rowInstances[0]
			local rowBorder = data3._rowBorders[0]

			if rowInstance ~= nil then
				rowInstance.Visible = data3.arguments.Header
			end

			if rowBorder ~= nil then
				rowBorder.Visible = data3.arguments.Header and data3.arguments.InnerBorders
			end

			data3.Instance.BorderContainer.UIStroke.Enabled = data3.arguments.OuterBorders

			for i = 1, data3.arguments.NumColumns do
				v2[data3][i] = true
			end

			if data3._widths ~= nil then
				data._widgets.Table.UpdateState(data3)
			end
		end,
		UpdateState = function(data3)
			local instance = data3.Instance
			local borderContainer = instance.BorderContainer
			local rowContainer = instance.RowContainer
			local numColumns = data3.arguments.NumColumns
			local value = data3.state.widths.value
			local minWidths = data3._minWidths

			local fixedWidth = data3.arguments.FixedWidth
			local proportionalWidth = data3.arguments.ProportionalWidth

			if not data3.arguments.Resizable then
				if fixedWidth then
					if proportionalWidth then
						for i = 1, numColumns do
							value[i] = minWidths[i]
						end
					else
						local maxValue = 0

						for _, minWidth in minWidths do
							maxValue = math.max(maxValue, minWidth)
						end

						for i = 1, numColumns do
							value[i] = maxValue
						end
					end
				elseif proportionalWidth then
					local total = 0

					for _, minWidth in minWidths do
						total += minWidth
					end

					local v9 = 1 / total

					for i = 1, numColumns do
						value[i] = v9 * minWidths[i]
					end
				else
					local v9 = 1 / numColumns

					for i = 1, numColumns do
						value[i] = v9
					end
				end
			end

			local udim = UDim.new()

			for i = 1, numColumns do
				local v9 = value[i]

				local udim2 = UDim.new(
					fixedWidth and 0 or math.clamp(v9, 0, 1),
					not fixedWidth and 0 or math.max(v9, 0)
				)

				data3._widths[i] = udim2
				udim += udim2

				for _, cellInstance in data3._cellInstances do
					cellInstance[i].Size = UDim2.new(udim2, UDim.new())
				end

				data3._cellInstances[-1][i].Size = UDim2.new(udim2 + UDim.new(0, (i > 1 and -2 or 0) - 3), UDim.new())
			end

			local offset = udim.Offset
			local v9 = not (data3.arguments.FixedWidth and data3.arguments.LimitTableWidth) and 1e999 or offset

			borderContainer.UISizeConstraint.MaxSize = Vector2.new(v9, 1e999)
			rowContainer.UISizeConstraint.MaxSize = Vector2.new(v9, 1e999)
			data3._columnBorders[0].Position = UDim2.new(0, v9 - 3, 0, 0)
		end,
		ChildAdded = function(data3, _)
			local rowIndex = data3._rowIndex
			local columnIndex = data3._columnIndex

			local rowInstance = data3._rowInstances[rowIndex]
			data3._rowCycles[rowIndex] = data._cycleTick
			v2[data3][columnIndex] = true

			if rowInstance ~= nil then
				return data3._cellInstances[rowIndex][columnIndex]
			end

			local generateRow = GenerateRow(data3, rowIndex)

			if rowIndex == 0 then
				generateRow.Visible = data3.arguments.Header
			end

			generateRow.Parent = data3._rowContainer

			if rowIndex > 0 then
				local parent = GenerateRowBorder(data3, rowIndex - 1, rowIndex == 1 and "Strong" or "Light")
				parent.Visible = data3.arguments.InnerBorders
					and (rowIndex ~= 1 or data3.arguments.Header and data3.arguments.InnerBorders and data3._rowInstances[0] ~= nil)
				data3._rowBorders[rowIndex - 1] = parent
				parent.Parent = data3._rowContainer
			end

			return data3._cellInstances[rowIndex][columnIndex]
		end,
		ChildDiscarded = function(p, p2)
			local parent = p2.Instance.Parent

			local v9 = parent ~= nil and tonumber(parent.Name:sub(6))

			if v9 then
				v2[p][v9] = true
			end
		end,
		Discard = function(p)
			v[p.ID] = nil
			v2[p] = nil
			p.Instance:Destroy()
			data2.discardState(p)
		end
	})
end