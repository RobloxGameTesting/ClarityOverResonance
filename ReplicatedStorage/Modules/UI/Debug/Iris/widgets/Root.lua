require(script.Parent.Parent.Types)

return function(p, p2)
	local v = 0

	p.WidgetConstructor("Root", {
		hasState = false,
		hasChildren = true,
		Args = {},
		Events = {},
		Generate = function(_)
			local iris_Root = Instance.new("Folder")
			iris_Root.Name = "Iris_Root"
			local pseudoWindowScreenGui

			if p._config.UseScreenGUIs then
				pseudoWindowScreenGui = Instance.new("ScreenGui")
				pseudoWindowScreenGui.ResetOnSpawn = false
				pseudoWindowScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				pseudoWindowScreenGui.DisplayOrder = p._config.DisplayOrderOffset
				pseudoWindowScreenGui.IgnoreGuiInset = p._config.IgnoreGuiInset
			else
				pseudoWindowScreenGui = Instance.new("Frame")
				pseudoWindowScreenGui.AnchorPoint = Vector2.new(0.5, 0.5)
				pseudoWindowScreenGui.Position = UDim2.new(0.5, 0, 0.5, 0)
				pseudoWindowScreenGui.Size = UDim2.new(1, 0, 1, 0)
				pseudoWindowScreenGui.BackgroundTransparency = 1
				pseudoWindowScreenGui.ZIndex = p._config.DisplayOrderOffset
			end

			pseudoWindowScreenGui.Name = "PseudoWindowScreenGui"
			pseudoWindowScreenGui.Parent = iris_Root
			local popupScreenGui

			if p._config.UseScreenGUIs then
				popupScreenGui = Instance.new("ScreenGui")
				popupScreenGui.ResetOnSpawn = false
				popupScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
				popupScreenGui.DisplayOrder = p._config.DisplayOrderOffset + 1024
				popupScreenGui.IgnoreGuiInset = p._config.IgnoreGuiInset
			else
				popupScreenGui = Instance.new("Frame")
				popupScreenGui.AnchorPoint = Vector2.new(0.5, 0.5)
				popupScreenGui.Position = UDim2.new(0.5, 0, 0.5, 0)
				popupScreenGui.Size = UDim2.new(1, 0, 1, 0)
				popupScreenGui.BackgroundTransparency = 1
				popupScreenGui.ZIndex = p._config.DisplayOrderOffset + 1024
			end

			popupScreenGui.Name = "PopupScreenGui"
			popupScreenGui.Parent = iris_Root

			local tooltipContainer = Instance.new("Frame")
			tooltipContainer.Name = "TooltipContainer"
			tooltipContainer.AutomaticSize = Enum.AutomaticSize.XY
			tooltipContainer.Size = UDim2.fromOffset(0, 0)
			tooltipContainer.BackgroundTransparency = 1
			tooltipContainer.BorderSizePixel = 0

			p2.UIListLayout(tooltipContainer, Enum.FillDirection.Vertical, UDim.new(0, p._config.PopupBorderSize))

			tooltipContainer.Parent = popupScreenGui

			local menuBarContainer = Instance.new("Frame")
			menuBarContainer.Name = "MenuBarContainer"
			menuBarContainer.AutomaticSize = Enum.AutomaticSize.Y
			menuBarContainer.Size = UDim2.fromScale(1, 0)
			menuBarContainer.BackgroundTransparency = 1
			menuBarContainer.BorderSizePixel = 0

			menuBarContainer.Parent = popupScreenGui

			local pseudoWindow = Instance.new("Frame")
			pseudoWindow.Name = "PseudoWindow"
			pseudoWindow.Size = UDim2.new(0, 0, 0, 0)
			pseudoWindow.Position = UDim2.fromOffset(0, 22)
			pseudoWindow.AutomaticSize = Enum.AutomaticSize.XY
			pseudoWindow.BackgroundTransparency = p._config.WindowBgTransparency
			pseudoWindow.BackgroundColor3 = p._config.WindowBgColor
			pseudoWindow.BorderSizePixel = p._config.WindowBorderSize
			pseudoWindow.BorderColor3 = p._config.BorderColor

			pseudoWindow.Selectable = false
			pseudoWindow.SelectionGroup = true
			pseudoWindow.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			pseudoWindow.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
			pseudoWindow.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
			pseudoWindow.SelectionBehaviorRight = Enum.SelectionBehavior.Stop

			pseudoWindow.Visible = false

			p2.UIPadding(pseudoWindow, p._config.WindowPadding)
			p2.UIListLayout(pseudoWindow, Enum.FillDirection.Vertical, UDim.new(0, p._config.ItemSpacing.Y))

			pseudoWindow.Parent = pseudoWindowScreenGui

			return iris_Root
		end,
		Update = function(p3)
			if v > 0 then
				p3.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = true
			end
		end,
		Discard = function(p3)
			v = 0
			p3.Instance:Destroy()
		end,
		ChildAdded = function(p3, p4)
			local instance = p3.Instance

			if p4.type == "Window" then
				return p3.Instance
			end

			if p4.type == "Tooltip" then
				return instance.PopupScreenGui.TooltipContainer
			end

			if p4.type == "MenuBar" then
				return instance.PopupScreenGui.MenuBarContainer
			end

			local pseudoWindow = instance.PseudoWindowScreenGui.PseudoWindow

			v += 1
			pseudoWindow.Visible = true

			return pseudoWindow
		end,
		ChildDiscarded = function(p3, p4)
			if p4.type ~= "Window" and p4.type ~= "Tooltip" and p4.type ~= "MenuBar" then
				v -= 1

				if v == 0 then
					p3.Instance.PseudoWindowScreenGui.PseudoWindow.Visible = false
				end
			end
		end
	})
end