require(script.Parent.Types)

return function(state)
	local function wrapper(p) -- 49 equivalent calls inferred from this helper
		return function(p2, p3)
			return state.Internal._Insert(p, p2, p3)
		end
	end

	state.Window = wrapper("Window") -- inferred equivalent call

	state.SetFocusedWindow = state.Internal.SetFocusedWindow

	state.Tooltip = wrapper("Tooltip") -- inferred equivalent call

	state.MenuBar = wrapper("MenuBar") -- inferred equivalent call

	state.Menu = wrapper("Menu") -- inferred equivalent call

	state.MenuItem = wrapper("MenuItem") -- inferred equivalent call

	state.MenuToggle = wrapper("MenuToggle") -- inferred equivalent call

	state.Separator = wrapper("Separator") -- inferred equivalent call

	state.Indent = wrapper("Indent") -- inferred equivalent call

	state.SameLine = wrapper("SameLine") -- inferred equivalent call

	state.Group = wrapper("Group") -- inferred equivalent call

	state.Text = wrapper("Text") -- inferred equivalent call

	function state:TextWrapped()
		self[2] = true
		return (state.Internal._Insert("Text", self))
	end

	function state:TextColored()
		self[3] = self[2]
		self[2] = nil
		return (state.Internal._Insert("Text", self))
	end

	state.SeparatorText = wrapper("SeparatorText") -- inferred equivalent call

	state.InputText = wrapper("InputText") -- inferred equivalent call

	state.Button = wrapper("Button") -- inferred equivalent call

	state.SmallButton = wrapper("SmallButton") -- inferred equivalent call

	state.Checkbox = wrapper("Checkbox") -- inferred equivalent call

	state.RadioButton = wrapper("RadioButton") -- inferred equivalent call

	state.Image = wrapper("Image") -- inferred equivalent call

	state.ImageButton = wrapper("ImageButton") -- inferred equivalent call

	state.Tree = wrapper("Tree") -- inferred equivalent call

	state.CollapsingHeader = wrapper("CollapsingHeader") -- inferred equivalent call

	state.TabBar = wrapper("TabBar") -- inferred equivalent call

	state.Tab = wrapper("Tab") -- inferred equivalent call

	state.InputNum = wrapper("InputNum") -- inferred equivalent call

	state.InputVector2 = wrapper("InputVector2") -- inferred equivalent call

	state.InputVector3 = wrapper("InputVector3") -- inferred equivalent call

	state.InputUDim = wrapper("InputUDim") -- inferred equivalent call

	state.InputUDim2 = wrapper("InputUDim2") -- inferred equivalent call

	state.InputRect = wrapper("InputRect") -- inferred equivalent call

	state.DragNum = wrapper("DragNum") -- inferred equivalent call

	state.DragVector2 = wrapper("DragVector2") -- inferred equivalent call

	state.DragVector3 = wrapper("DragVector3") -- inferred equivalent call

	state.DragUDim = wrapper("DragUDim") -- inferred equivalent call

	state.DragUDim2 = wrapper("DragUDim2") -- inferred equivalent call

	state.DragRect = wrapper("DragRect") -- inferred equivalent call

	state.InputColor3 = wrapper("InputColor3") -- inferred equivalent call

	state.InputColor4 = wrapper("InputColor4") -- inferred equivalent call

	state.SliderNum = wrapper("SliderNum") -- inferred equivalent call

	state.SliderVector2 = wrapper("SliderVector2") -- inferred equivalent call

	state.SliderVector3 = wrapper("SliderVector3") -- inferred equivalent call

	state.SliderUDim = wrapper("SliderUDim") -- inferred equivalent call

	state.SliderUDim2 = wrapper("SliderUDim2") -- inferred equivalent call

	state.SliderRect = wrapper("SliderRect") -- inferred equivalent call

	state.Selectable = wrapper("Selectable") -- inferred equivalent call

	state.Combo = wrapper("Combo") -- inferred equivalent call

	function state.ComboArray(p, p2, list)
		if p2 == nil then
			p2 = state.State(list[1])
		end

		local v = state.Internal._Insert("Combo", p, p2)
		local index = v.state.index

		for _, item in list do
			state.Internal._Insert("Selectable", { item, item }, { index = index })
		end

		state.End()

		return v
	end

	function state.ComboEnum(p, p2, object)
		if p2 == nil then
			p2 = state.State(object:GetEnumItems()[1])
		end

		local v = state.Internal._Insert("Combo", p, p2)
		local index = v.state.index

		for _, v2 in object:GetEnumItems() do
			state.Internal._Insert("Selectable", { v2.Name, v2 }, { index = index })
		end

		state.End()

		return v
	end

	state.InputEnum = state.ComboEnum

	state.ProgressBar = wrapper("ProgressBar") -- inferred equivalent call

	state.PlotLines = wrapper("PlotLines") -- inferred equivalent call

	state.PlotHistogram = wrapper("PlotHistogram") -- inferred equivalent call

	state.Table = wrapper("Table") -- inferred equivalent call

	function state.NextColumn()
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.NextColumn() can only called when directly within a table.")

		if parentWidget._columnIndex == parentWidget.arguments.NumColumns then
			parentWidget._columnIndex = 1
			parentWidget._rowIndex += 1
		else
			parentWidget._columnIndex += 1
		end

		return parentWidget._columnIndex
	end

	function state.NextRow()
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.NextRow() can only called when directly within a table.")
		parentWidget._columnIndex = 1
		parentWidget._rowIndex += 1
		return parentWidget._rowIndex
	end

	function state.SetColumnIndex(columnIndex: number)
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.SetColumnIndex() can only called when directly within a table.")
		local v = columnIndex >= 1 and columnIndex <= parentWidget.arguments.NumColumns
		assert(v, `The index must be between 1 and {parentWidget.arguments.NumColumns}, inclusive.`)
		parentWidget._columnIndex = columnIndex
	end

	function state.SetRowIndex(rowIndex: number)
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.SetRowIndex() can only called when directly within a table.")
		assert(rowIndex >= 1, "The index must be greater or equal to 1.")
		parentWidget._rowIndex = rowIndex
	end

	function state.NextHeaderColumn()
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.NextHeaderColumn() can only called when directly within a table.")

		parentWidget._rowIndex = 0
		parentWidget._columnIndex = parentWidget._columnIndex % parentWidget.arguments.NumColumns + 1

		return parentWidget._columnIndex
	end

	function state.SetHeaderColumnIndex(columnIndex: number)
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.SetHeaderColumnIndex() can only called when directly within a table.")
		local v = columnIndex >= 1 and columnIndex <= parentWidget.arguments.NumColumns
		assert(v, `The index must be between 1 and {parentWidget.arguments.NumColumns}, inclusive.`)

		parentWidget._rowIndex = 0
		parentWidget._columnIndex = columnIndex
	end

	function state.SetColumnWidth(p: number, p2: number)
		local parentWidget = state.Internal._GetParentWidget()
		assert(parentWidget ~= nil, "Iris.SetColumnWidth() can only called when directly within a table.")
		local v = p >= 1 and p <= parentWidget.arguments.NumColumns
		assert(v, `The index must be between 1 and {parentWidget.arguments.NumColumns}, inclusive.`)

		local v2 = parentWidget.state.widths.value[p]
		parentWidget.state.widths.value[p] = p2
		parentWidget.state.widths:set(parentWidget.state.widths.value, p2 ~= v2)
	end
end