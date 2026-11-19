local MainGuiManager = {}

local currentSlot = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local syncMetadata = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SyncMetadata")
local SandBoxModels = ReplicatedStorage:WaitForChild("SandBoxModels")
local SaveModelsEvent = ReplicatedStorage.Remotes:WaitForChild("SaveModelsEvent")
local LoadModelsEvents = ReplicatedStorage.Remotes:WaitForChild("LoadModelsEvents")
local Workspace = game:GetService("Workspace")
local SandBox = Workspace:WaitForChild("SandBox")

local GUIReferences = require(script.Parent.GUIReferences)
local Serializer = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("Serializer"))
local NotificationModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("Notification"):WaitForChild("NotificationModule"))
local ViewportController = require(ReplicatedStorage.Modules.UI.MainUI:WaitForChild("ViewportController"))
local SandboxScanner = require(ReplicatedStorage.Modules:WaitForChild("System"):WaitForChild("SandboxScanner"))
local SettingsData = require(ReplicatedStorage.Modules.UI.MainUI:WaitForChild("SettingsData"))

MainGuiManager.References = GUIReferences

MainGuiManager.State = {
	currentPage = "ModelsPage",
	isGuiVisible = true,
	searchQueries = {},
	sortBy = "Name",
	filterType = "All",
	sortContainersVisible = {},
	typeContainerVisible = false,
	selectedSortOptions = {},
	selectedTypeOption = "All",
	currentSlotMetadata = {}
}

local visible = false
function MainGuiManager.updatehitboxsandboxstate(flag: boolean)
	visible = flag
end

local v = { timer = nil, debounceDelay = 0.1 }

local v2 = { timer = nil, interval = 200, slot = "autosave", running = false }
local v3 = {
	pending = false,
	timer = nil,
	debounceDelay = 0.3,
	changeCount = 0,
	lastRefreshTime = 0
}

for k in pairs(GUIReferences.UIComponents.SortComponents) do
	MainGuiManager.State.sortContainersVisible[k] = false
	MainGuiManager.State.selectedSortOptions[k] = "Name"
end

for k in pairs(GUIReferences.UIComponents.SearchComponents) do
	MainGuiManager.State.searchQueries[k] = ""
end

function MainGuiManager.GetCurrentSlot()
	return currentSlot
end

function MainGuiManager.RequestMetaData()
	syncMetadata:FireServer()
end

function MainGuiManager.switchToPage(currentPage: string): boolean
	if not GUIReferences.getPage(currentPage) then
		warn("Page '" .. currentPage .. "' not found!")
		return false
	end

	GUIReferences.showPage(currentPage)
	MainGuiManager.State.currentPage = currentPage

	MainGuiManager.loadSearchQueryFromPage(currentPage)

	return true
end

function MainGuiManager.getCurrentPage()
	return MainGuiManager.State.currentPage
end

function MainGuiManager.hideGui()
	GUIReferences.MainFrame.Visible = false
	MainGuiManager.State.isGuiVisible = false
end

function MainGuiManager.showGui()
	GUIReferences.MainFrame.Visible = true
	MainGuiManager.State.isGuiVisible = true
end

function MainGuiManager.toggleGui()
	if MainGuiManager.State.isGuiVisible then
		MainGuiManager.hideGui()
	else
		MainGuiManager.showGui()
	end
end

function MainGuiManager.getGroupedModels()
	local groupedModels = {}

	for _, child in ipairs(SandBoxModels:GetChildren()) do
		local primaryPart = child.PrimaryPart or child:FindFirstChild("BoundingBox")

		if not primaryPart then
			continue
		end

		local subType = primaryPart:GetAttribute("SubType") or "Others"
		local typeBox = primaryPart:GetAttribute("TypeBox") or child.Name

		if not groupedModels[subType] then
			groupedModels[subType] = {}
		end

		table.insert(groupedModels[subType], { Instance = child, Name = typeBox })
	end

	return groupedModels
end

function MainGuiManager.setupNavigation()
	for k, navButton in pairs(GUIReferences.NavButtons) do
		if k == "Close" then
			navButton.MouseButton1Click:Connect(function()
				MainGuiManager.hideGui()
			end)
		else
			local v4 = k .. "Page"

			if GUIReferences.getPage(v4) then
				navButton.MouseButton1Click:Connect(function()
					MainGuiManager.switchToPage(v4)
				end)
			end
		end
	end

	GUIReferences.ButtonSlots.MouseButton1Click:Connect(function()
		MainGuiManager.toggleGui()
	end)
end

function MainGuiManager.setupSearch()
	for k, searchComponent in pairs(GUIReferences.UIComponents.SearchComponents) do
		if not searchComponent.TextBox then
			continue
		end

		searchComponent.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			MainGuiManager.debouncedSearch(k, searchComponent.TextBox.Text)
		end)

		searchComponent.TextBox.FocusLost:Connect(function(_)
			if v.timer then
				task.cancel(v.timer)
				v.timer = nil
			end

			MainGuiManager.State.searchQueries[k] = searchComponent.TextBox.Text
			MainGuiManager.performSearch(k)
		end)
	end
end

function MainGuiManager.loadSearchQueryFromPage(p: string)
	local searchComponent = GUIReferences.UIComponents.SearchComponents[p]

	if searchComponent and searchComponent.TextBox then
		MainGuiManager.State.searchQueries[p] = searchComponent.TextBox.Text
		MainGuiManager.performSearch(p)
	end
end

function MainGuiManager.applyModelsFilter(p)
	local lower = (MainGuiManager.State.searchQueries[MainGuiManager.State.currentPage] or ""):lower()
	local selectedTypeOption = MainGuiManager.State.selectedTypeOption
	local sortBy = MainGuiManager.State.sortBy
	local scrollFrame = MainGuiManager.References.getScrollFrame(p)

	for _, frame in ipairs(scrollFrame:GetChildren()) do
		if not (frame:IsA("Frame") and frame.Name:find("Category_")) then
			continue
		end

		local v4 = frame.Name:gsub("Category_", "")
		local container = frame:FindFirstChild("Container")
		local visible2 = false

		local v5 = selectedTypeOption == "All" or v4 == selectedTypeOption

		if container then
			local frames = {}

			for _, frame2 in ipairs(container:GetChildren()) do
				if not (frame2:IsA("Frame") and frame2.Name ~= "TemplateItem") then
					continue
				end

				local text = frame2.Preview.ItemName.Text:lower()
				local v6 = lower == "" or text:find(lower)

				local visible3 = v5 and v6
				frame2.Visible = visible3

				if not visible3 then
					continue
				end

				table.insert(frames, frame2)
				visible2 = true
			end

			table.sort(frames, function(a, b): boolean
				if sortBy == "Z-A" then
					return a.Name > b.Name
				end

				return a.Name < b.Name
			end)

			for i, v6 in ipairs(frames) do
				v6.LayoutOrder = i
			end
		end

		frame.Visible = visible2
	end
end

function MainGuiManager.ShowSlotProperties(p, data)
	currentSlot = p

	local properties = GUIReferences.PageElements.DataSlotsPage.Properties
	local containers = properties.DataInfo.Containers
	local template = containers.Template

	properties.SlotName.Text = data.SlotName
	properties.BackgroundColor3 = Color3.new(unpack(data.SlotColor))

	for _, frame in ipairs(containers:GetChildren()) do
		if frame:IsA("Frame") and frame ~= template then
			frame:Destroy()
		end
	end

	if data.CountInfo and type(data.CountInfo) == "table" then
		for k, v4 in pairs(data.CountInfo) do
			local clone = template:Clone()
			clone.Parent = containers
			clone.Visible = true
			clone.Name = k

			clone.LabelInfo.Text = k
			clone.DataValue.Text = tostring(v4)
		end
	end
end

function MainGuiManager.UpdateDataSlotsPage(currentSlotMetadata)
	MainGuiManager.State.currentSlotMetadata = currentSlotMetadata
	local scrollFrame = GUIReferences.PageElements.DataSlotsPage.Containers.ScrollFrame
	local templateIndex = GUIReferences.PageElements.DataSlotsPage.Containers.TemplateIndex

	for _, frame in ipairs(scrollFrame:GetChildren()) do
		if frame:IsA("Frame") and frame ~= templateIndex then
			frame:Destroy()
		end
	end

	for k, v4 in pairs(currentSlotMetadata) do
		local layoutOrder = tonumber(k)
		local clone = templateIndex:Clone()
		clone.Name = "Slot_" .. k
		clone.Parent = scrollFrame
		clone.Visible = true

		local textButton = clone.TextButton
		local dataName = textButton.DataName
		local information = textButton.Information
		local favoriteIcon = textButton.FavoriteIcon

		local v5 = k == v2.slot

		local slotColor = v4.SlotColor

		if v5 then
			dataName.Text = "AutoSave"
			clone.LayoutOrder = 100

			textButton.BackgroundColor3 = Color3.fromRGB(84, 144, 62)
		else
			dataName.Text = tostring(layoutOrder) .. ". " .. (v4.SlotName or "Empty Slot")
			clone.LayoutOrder = layoutOrder
			textButton.BackgroundColor3 = Color3.new(slotColor[1], slotColor[2], slotColor[3])
		end

		information.Text = v4.LastSaved or "Never"

		if v5 then
			favoriteIcon:Destroy()
		else
			favoriteIcon.Image = v4.IsFavorite and "rbxassetid://131561400823936" or "rbxassetid://82281924279750"

			favoriteIcon.MouseButton1Click:Connect(function()
				v4.IsFavorite = not v4.IsFavorite
				favoriteIcon.Image = v4.IsFavorite and "rbxassetid://131561400823936" or "rbxassetid://82281924279750"
				MainGuiManager.State.currentSlotMetadata[tostring(layoutOrder)].IsFavorite = v4.IsFavorite
			end)
		end

		textButton.MouseButton1Click:Connect(function()
			MainGuiManager.ShowSlotProperties(k, v4)
		end)
		MainGuiManager.performSearch("DataSlotsPage")
	end
end

local Properties = GUIReferences.PageElements.ModelsPage.Properties
local Viewport = Properties.Preview.Viewport
local SpawnButton = Properties.SpawnButton
local camera = Instance.new("Camera")
camera.Parent = Viewport
Viewport.CurrentCamera = camera
local v4 = ""
local v5 = ViewportController.new(Viewport, camera)

function MainGuiManager.debouncedRefreshModelsPage()
	if v3.timer then
		task.cancel(v3.timer)
	end

	v3.changeCount += 1
	v3.pending = true

	v3.timer = task.delay(v3.debounceDelay, function()
		if v3.pending then
			if MainGuiManager.State.currentPage == "ModelsPage" then
				MainGuiManager.updateModelsPage()
				v3.lastRefreshTime = tick()
			end

			v3.pending = false
			v3.changeCount = 0
		end
	end)
end

function MainGuiManager.RefreshModelsPageFromRemote()
	v3.changeCount = 0
	v3.pending = false

	if v3.timer then
		task.cancel(v3.timer)
		v3.timer = nil
	end

	if MainGuiManager.State.currentPage == "ModelsPage" then
		MainGuiManager.updateModelsPage()
		v3.lastRefreshTime = tick()
	end
end

function MainGuiManager.debouncedSearch(p: string, p2: string)
	if v.timer then
		task.cancel(v.timer)
	end

	v.timer = task.delay(v.debounceDelay, function()
		MainGuiManager.State.searchQueries[p] = p2
		MainGuiManager.performSearch(p)
	end)
end

function MainGuiManager.updateModelsProperty(p)
	v4 = p.Name
	local child = SandBoxModels:FindFirstChild(p.Name)
	local containers = GUIReferences.PageElements.ModelsPage.Properties.DataInfo.Containers
	local template = containers.Template

	for _, model in ipairs(Viewport:GetChildren()) do
		if model:IsA("Model") then
			model:Destroy()
		end
	end

	for _, frame in ipairs(containers:GetChildren()) do
		if frame:IsA("Frame") and frame ~= template then
			frame:Destroy()
		end
	end

	Properties.ItemName.Text = p.Name

	if child then
		local v6 = {
			{
				Label = "Weight Of Models",
				Value = math.floor(Serializer.getmassdata(child.PrimaryPart) * 10 + 0.5) / 10 .. " Kg"
			},
			{
				Label = "Limit Count",
				Value = child.PrimaryPart:GetAttribute("CountLimits") or "Unlimited"
			}
		}

		for _, v7 in ipairs(v6) do
			local clone = template:Clone()
			clone.Name = v7.Label
			clone.LabelInfo.Text = v7.Label
			clone.DataValue.Text = tostring(v7.Value)
			clone.Visible = true
			clone.Parent = containers
		end

		local clone = child:Clone()
		clone.Parent = Viewport
		clone:PivotTo(CFrame.new(0, 0, 0))

		v5:SetTarget(clone:GetPivot().Position)
		v5.Distance = clone:GetExtentsSize().Magnitude * 1.5
		v5:UpdateCamera()
	end
end

function MainGuiManager.updateModelsPage()
	local scrollFrame = GUIReferences.PageElements.ModelsPage.Containers.ScrollFrame
	local templateCategoryContainer = scrollFrame.TemplateCategoryContainer

	local modelsPage = (MainGuiManager.State.searchQueries.ModelsPage or ""):lower()
	local selectedTypeOption = MainGuiManager.State.selectedTypeOption
	local sortBy = MainGuiManager.State.sortBy

	for _, frame in ipairs(scrollFrame:GetChildren()) do
		if frame:IsA("Frame") and frame ~= templateCategoryContainer then
			frame:Destroy()
		end
	end

	local groupedModels = MainGuiManager.getGroupedModels()

	for k, list in pairs(groupedModels) do
		if not (selectedTypeOption == "All" or k == selectedTypeOption) then
			continue
		end

		local v6 = {}

		for _, item in ipairs(list) do
			if modelsPage == "" or item.Name:lower():find(modelsPage) then
				table.insert(v6, item)
			end
		end

		if #v6 == 0 then
			continue
		end

		table.sort(v6, function(a, b): boolean
			if sortBy == "Z-A" then
				return a.Name:lower() > b.Name:lower()
			end

			return a.Name:lower() < b.Name:lower()
		end)

		local clone = templateCategoryContainer:Clone()
		clone.Name = "Category_" .. k
		clone.Parent = scrollFrame
		clone.Visible = true
		clone.CategoryName.Text = k

		local container = clone.Container
		local templateItem = container.TemplateItem
		templateItem.Visible = false

		for _, v7 in ipairs(v6) do
			local clone2 = templateItem:Clone()
			clone2.Name = v7.Name
			clone2.Parent = container
			clone2.Visible = true
			clone2.Preview.ItemName.Text = v7.Name
			local v8 = v7
			clone2.Preview.MouseButton1Click:Connect(function()
				MainGuiManager.updateModelsProperty(v8)
			end)
		end
	end
end

function MainGuiManager.SpawnModels()
	if v4 == "" then
		return
	end

	local child = SandBoxModels:FindFirstChild(v4)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (child and humanoidRootPart and visible) then
		NotificationModule.notify("Cannot be Spawned", "Cannot be spawned because it is not in the sandbox base", 7, 3)

		return
	end

	local clone = child:Clone()
	local v6 = humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * 4
	clone:PivotTo((CFrame.new(v6)))
	clone.Parent = workspace.SandBox
end
function MainGuiManager.UpdateGUI(p: string, _)
	if p == GUIReferences.Pages.DataSlotsPage then
		MainGuiManager.UpdateDataSlotsPage(p)
	end
end

function MainGuiManager.performSearch(p: string)
	local lower = (MainGuiManager.State.searchQueries[p] or ""):lower()

	if p == "ModelsPage" then
		MainGuiManager.applyModelsFilter("ModelsPage")
	elseif p == "DataSlotsPage" then
		local scrollFrame = GUIReferences.PageElements.DataSlotsPage.Containers.ScrollFrame
		local currentSlotMetadata = MainGuiManager.State.currentSlotMetadata

		for _, frame in ipairs(scrollFrame:GetChildren()) do
			if not (frame:IsA("Frame") and frame.Name:find("Slot_")) then
				continue
			end

			local v6 = currentSlotMetadata[frame.Name:gsub("Slot_", "")]

			if not v6 then
				continue
			end

			local slotName = (v6.SlotName or ""):lower()
			frame.Visible = lower == "" or slotName:find(lower)
		end
	end
end

function MainGuiManager.setupSort()
	for k, sortComponent in pairs(GUIReferences.UIComponents.SortComponents) do
		if sortComponent.Button then
			sortComponent.Button.MouseButton1Click:Connect(function()
				MainGuiManager.toggleSortContainer(k)
			end)
		end
	end
end

function MainGuiManager.toggleSortContainer(p: string)
	MainGuiManager.State.sortContainersVisible[p] = not MainGuiManager.State.sortContainersVisible[p]

	local sortComponent = GUIReferences.UIComponents.SortComponents[p]
	local scrollingFrame = sortComponent
		and sortComponent.Container
		and sortComponent.Container:FindFirstChildOfClass("ScrollingFrame")

	if scrollingFrame then
		sortComponent.Container.Visible = MainGuiManager.State.sortContainersVisible[p]

		if MainGuiManager.State.sortContainersVisible[p] then
			MainGuiManager.populateSortOptions(p, scrollingFrame)
		end

		if MainGuiManager.State.sortContainersVisible[p] then
			return
		end
	end
end

function MainGuiManager.isSortContainerVisible(p: string)
	return MainGuiManager.State.sortContainersVisible[p] or false
end

function MainGuiManager.closeAllSortContainers()
	for k in pairs(GUIReferences.UIComponents.SortComponents) do
		if MainGuiManager.State.sortContainersVisible[k] then
			MainGuiManager.toggleSortContainer(k)
		end
	end
end

function MainGuiManager.setupTypeFilter()
	if GUIReferences.UIComponents.TypeComponents then
		GUIReferences.UIComponents.TypeComponents.Button.MouseButton1Click:Connect(function()
			MainGuiManager.toggleTypeContainer()
		end)
	end
end

function MainGuiManager.toggleTypeContainer()
	MainGuiManager.State.typeContainerVisible = not MainGuiManager.State.typeContainerVisible

	local typeComponents = GUIReferences.UIComponents.TypeComponents
	local scrollingFrame = typeComponents
		and typeComponents.Container
		and typeComponents.Container:FindFirstChildOfClass("ScrollingFrame")

	if scrollingFrame then
		typeComponents.Container.Visible = MainGuiManager.State.typeContainerVisible

		if MainGuiManager.State.typeContainerVisible then
			MainGuiManager.populateTypeOptions(scrollingFrame)
		end

		if MainGuiManager.State.typeContainerVisible then
			return
		end
	end
end

function MainGuiManager.isTypeContainerVisible()
	return MainGuiManager.State.typeContainerVisible
end

function MainGuiManager.closeTypeContainer()
	if MainGuiManager.State.typeContainerVisible then
		MainGuiManager.toggleTypeContainer()
	end
end

function MainGuiManager.enhancedPageSwitching()
	local switchToPage = MainGuiManager.switchToPage

	function MainGuiManager.switchToPage(p: string)
		MainGuiManager.closeAllSortContainers()
		MainGuiManager.closeTypeContainer()

		return switchToPage(p)
	end
end

function MainGuiManager.setupClickOutsideDetection()
	local UserInputService = game:GetService("UserInputService")

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local flag = true

			for k, v6 in pairs(MainGuiManager.State.sortContainersVisible) do
				if not v6 then
					continue
				end

				local sortComponent = GUIReferences.UIComponents.SortComponents[k]

				if not (sortComponent and sortComponent.Container) then
					continue
				end

				local scrollingFrame = sortComponent.Container:FindFirstChildOfClass("ScrollingFrame")

				if scrollingFrame and MainGuiManager.isClickInsideGui(input, scrollingFrame) then
					flag = false
					break
				end
			end

			if MainGuiManager.State.typeContainerVisible then
				local typeComponents = GUIReferences.UIComponents.TypeComponents

				if typeComponents and typeComponents.Container then
					local scrollingFrame = typeComponents.Container:FindFirstChildOfClass("ScrollingFrame")

					if scrollingFrame and MainGuiManager.isClickInsideGui(input, scrollingFrame) then
						flag = false
					end
				end
			end

			if flag then
				MainGuiManager.closeAllSortContainers()
				MainGuiManager.closeTypeContainer()
			end
		end
	end)
end

function MainGuiManager.isClickInsideGui(p, p2): boolean
	local position = p.Position
	local absolutePosition = p2.AbsolutePosition
	local absoluteSize = p2.AbsoluteSize

	return position.X >= absolutePosition.X
		and position.X <= absolutePosition.X + absoluteSize.X
		and position.Y >= absolutePosition.Y
		and position.Y <= absolutePosition.Y + absoluteSize.Y
end

function MainGuiManager.initialize()
	MainGuiManager.switchToPage("ModelsPage")
	MainGuiManager.RequestMetaData()

	MainGuiManager.setupNavigation()
	MainGuiManager.setupSearch()
	MainGuiManager.setupSort()
	MainGuiManager.setupTypeFilter()

	MainGuiManager.enhancedPageSwitching()
	MainGuiManager.setupClickOutsideDetection()

	MainGuiManager.setupAutoDetectModelsChanges()

	MainGuiManager.setupAutoSave()
end

function MainGuiManager.setupAutoDetectModelsChanges()
	SandBoxModels.ChildAdded:Connect(function(_)
		MainGuiManager.debouncedRefreshModelsPage()
	end)

	SandBoxModels.ChildRemoved:Connect(function(_)
		MainGuiManager.debouncedRefreshModelsPage()
	end)
end

function MainGuiManager.setupAutoSave()
	if v2.running then
		return
	end

	v2.running = true

	task.spawn(function()
		while v2.running do
			task.wait(v2.interval)

			if not v2.running then
				break
			end

			MainGuiManager.PerformSaveWithSlot(v2.slot)
		end
	end)
end

function MainGuiManager.getAllPageNames()
	return {
		"ModelsPage",
		"DataSlotsPage",
		"TemplatePage",
		"ImagePage",
		"InfoPage",
		"SettingsPage"
	}
end

function MainGuiManager.isValidPage(p: string): boolean
	local allPageNames = MainGuiManager.getAllPageNames()

	for _, allPageName in ipairs(allPageNames) do
		if allPageName == p then
			return true
		end
	end

	return false
end

function MainGuiManager.getPageElement(p: string, p2: string, p3: string)
	local pageElements = GUIReferences.getPageElements(p)

	if pageElements and pageElements[p2] then
		return pageElements[p2][p3]
	end

	return nil
end

function MainGuiManager.updateSortCheckmarks(p: string, instance)
	for _, button in ipairs(instance:GetChildren()) do
		if not (button:IsA("TextButton") and button.Name:find("SortOption_")) then
			continue
		end

		local v6 = button.Name:sub(12)
		local checkMark = button:FindFirstChild("CheckMark")

		if checkMark then
			checkMark.Visible = MainGuiManager.State.selectedSortOptions[p] == v6
		end
	end
end

function MainGuiManager.updateTypeCheckmarks(instance)
	for _, button in ipairs(instance:GetChildren()) do
		if not (button:IsA("TextButton") and button.Name:find("TypeOption_")) then
			continue
		end

		local v6 = button.Name:sub(12)
		local checkMark = button:FindFirstChild("CheckMark")

		if checkMark then
			checkMark.Visible = MainGuiManager.State.selectedTypeOption == v6
		end
	end
end

function MainGuiManager.populateSortOptions(p: string, parent)
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name ~= "Template" and child.Name ~= "UICorner" and child.Name ~= "UIListLayout" then
			child:Destroy()
		end
	end

	local template = parent:FindFirstChild("Template")

	if not template then
		warn("Template not found in sort container for page: " .. p)
		return
	end

	template.Visible = false

	local v6 = ({
		ModelsPage = { "A-Z", "Z-A" },
		DataSlotsPage = { "A-Z", "Z-A", "Newest", "Older" },
		TemplatePage = { "A-Z", "Z-A", "Newest", "Older" },
		ImagePage = { "A-Z", "Z-A", "Newest", "Older" }
	})[p] or { "Name", "Date" }

	for _, text in ipairs(v6) do
		local clone = template:Clone()
		clone.Name = "SortOption_" .. text
		clone.Text = text
		clone.Visible = true
		clone.Parent = parent

		local checkMark = clone:FindFirstChild("CheckMark")

		if checkMark then
			checkMark.Visible = MainGuiManager.State.selectedSortOptions[p] == text
		end

		clone.MouseButton1Click:Connect(function()
			MainGuiManager.State.selectedSortOptions[p] = text
			MainGuiManager.setSortBy(text)
			MainGuiManager.updateSortCheckmarks(p, parent)
			MainGuiManager.toggleSortContainer(p)

			if p == "DataSlotsPage" then
				MainGuiManager.applySortToDataSlots(text)
			elseif p == "ModelsPage" then
				MainGuiManager.applyModelsFilter(p)
			end
		end)
	end
end

function MainGuiManager.applySortToDataSlots(p: string)
	local scrollFrame = GUIReferences.PageElements.DataSlotsPage.Containers.ScrollFrame
	local currentSlotMetadata = MainGuiManager.State.currentSlotMetadata

	local v6 = {}

	for k, v7 in pairs(currentSlotMetadata) do
		table.insert(v6, { Key = k, Data = v7 })
	end

	table.sort(v6, function(a, b): boolean
		if p == "A-Z" then
			return a.Data.SlotName:lower() < b.Data.SlotName:lower()
		elseif p == "Z-A" then
			return a.Data.SlotName:lower() > b.Data.SlotName:lower()
		elseif p == "Newest" then
			return a.Data.LastSaved > b.Data.LastSaved
		elseif p == "Older" then
			return a.Data.LastSaved < b.Data.LastSaved
		end

		return tonumber(a.Key) < tonumber(b.Key)
	end)

	for i, v7 in ipairs(v6) do
		local child = scrollFrame:FindFirstChild("Slot_" .. v7.Key)

		if child then
			child.LayoutOrder = i
		end
	end
end

function MainGuiManager.populateTypeOptions(parent)
	for _, uiListLayout in ipairs(parent:GetChildren()) do
		if uiListLayout.Name == "Template" or uiListLayout:IsA("UIListLayout") then
			continue
		end

		uiListLayout:Destroy()
	end

	local template = parent:FindFirstChild("Template")
	local groupedModels = MainGuiManager.getGroupedModels()

	local v6 = { "All" }

	for k in pairs(groupedModels) do
		table.insert(v6, k)
	end

	table.sort(v6)

	for _, v7 in ipairs(v6) do
		local clone = template:Clone()
		clone.Name = "TypeOption_" .. v7
		clone.Text = v7
		clone.Visible = true
		clone.Parent = parent

		local checkMark = clone:FindFirstChild("CheckMark")
		checkMark.Visible = MainGuiManager.State.selectedTypeOption == v7

		clone.MouseButton1Click:Connect(function()
			MainGuiManager.State.selectedTypeOption = v7
			MainGuiManager.setFilterType(v7)
			MainGuiManager.updateTypeCheckmarks(parent)
			MainGuiManager.toggleTypeContainer()

			MainGuiManager.updateModelsPage()
		end)
	end
end

local function round(p, value)
	local v6 = 10 ^ (value or 2)
	return math.floor(p * v6 + 0.5) / v6
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function setupdropdown(instance, p, p2)
	for _, uiListLayout in pairs(instance.Parent:GetChildren()) do
		if uiListLayout == instance or uiListLayout:IsA("UIListLayout") then
			continue
		end

		uiListLayout:Destroy()
	end

	local v6 = SettingsData.Get(p, p2) or {}
	local v7 = {}

	for _, v8 in pairs(Players:GetPlayers()) do
		if v6[v8.Name] == nil then
			v7[v8.Name] = v8 == LocalPlayer
		else
			v7[v8.Name] = v6[v8.Name]
		end
	end

	for k, _ in pairs(v7) do
		local clone = instance:Clone()
		clone.Name = "option" .. k
		clone.Text = k
		clone.Visible = true
		clone.Parent = instance.Parent

		local checkMark = clone:FindFirstChild("CheckMark")

		if checkMark then
			checkMark.Visible = v7[k]
		end

		clone.MouseButton1Click:Connect(function()
			v7[k] = not v7[k]

			if checkMark then
				checkMark.Visible = v7[k]
			end

			SettingsData.Set(p, p2, v7)
		end)
	end
end

function MainGuiManager.toogledropdown(p)
	if not p then
		return
	end

	p.Container.Visible = not p.Container.Visible
	return p.Container.Visible
end
function MainGuiManager.AddSettingsElements(text, text2, childName, p, p2)
	local scrollFrame = GUIReferences.PageElements.SettingsPage.Containers.ScrollFrame
	local templateSet = GUIReferences.PageElements.SettingsPage.Containers.TemplateSet
	local v6 = scrollFrame:FindFirstChild(childName)

	if not v6 then
		v6 = templateSet:Clone()
		v6.Parent = scrollFrame
		v6.Name = childName
		v6.Visible = true
		v6.TextLabel.Text = childName
	end

	local subCategory = v6:FindFirstChild("SubCategory")
	local template

	if subCategory then
		template = subCategory:FindFirstChild("Template")
	else
		template = nil
	end

	local function createNewSet()
		local clone = template:Clone()
		clone.Visible = true
		clone.Name = "Element_" .. text
		clone.Parent = subCategory
		clone.Header.Text = text
		clone.Info.Text = text2

		if p == 1 then
			clone.Indicator.Visible = true
			local switch = clone.Indicator.Switch
			local v7 = false
			switch.MouseButton1Click:Connect(function()
				v7 = not v7
				switch.Position = v7 and UDim2.new(0.5, 0, switch.Position.Y.Scale, switch.Position.Y.Offset)
					or UDim2.new(0, 0, switch.Position.Y.Scale, switch.Position.Y.Offset)
				switch.Parent.BackgroundColor3 = v7 and Color3.fromRGB(36, 227, 3) or Color3.fromRGB(214, 0, 0)
				SettingsData.Set(childName, text, v7)
			end)
		elseif p == 2 then
			clone.SliderBackGround.Visible = true
			local dragButton = clone.SliderBackGround.DragButton
			local v7 = tonumber(p2) or 0.1

			dragButton.UIDragDetector.DragContinue:Connect(function(p3)
				local sliderBackGround = clone.SliderBackGround
				local x = sliderBackGround.AbsolutePosition.X
				local x2 = sliderBackGround.AbsoluteSize.X
				local x3 = dragButton.AbsoluteSize.X

				local halfX3 = x3 / 2

				local v8 = x2 - halfX3
				local v9 = x2 - x3

				local v10 = math.clamp(math.round((math.clamp(p3.X - x, halfX3, v8) - halfX3) / v9 / v7) * v7, 0, 1)

				local v11 = (halfX3 + v10 * v9) / x2
				dragButton.Position = UDim2.new(v11, 0, 0.5, 0)

				local uiGradient = sliderBackGround:FindFirstChild("UIGradient")

				if uiGradient then
					local v12 = math.clamp(v10, 0, 1)
					local v13 = math.clamp(v10 + 0.02, 0, 1)
					uiGradient.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(v12, 0),
						NumberSequenceKeypoint.new(v13, 1),
						NumberSequenceKeypoint.new(1, 1)
					})
				end

				SettingsData.Set(childName, text, v10)
			end)
		elseif p == 3 then
			local dropDown = clone.DropDown
			dropDown.Text = "Players"
			local template2 = dropDown.Container.ScrollingFrame.Template
			dropDown.Visible = true
			clone.ZIndex = 10
			setupdropdown(template2, childName, text)
			Players.PlayerAdded:Connect(function()
				setupdropdown(template2, childName, text)
			end)

			Players.PlayerRemoving:Connect(function()
				setupdropdown(template2, childName, text)
			end)
			dropDown.MouseButton1Click:Connect(function()
				MainGuiManager.toogledropdown(dropDown)
			end)
		elseif p == 4 then
			local input = clone.Input
			input.Visible = true
			input:GetPropertyChangedSignal("Text"):Connect(function()
				SettingsData.Set(childName, text, input.Text)
			end)
		end
	end

	if template then
		createNewSet()
	end
end

function MainGuiManager.PerformSave()
	SaveModelsEvent:FireServer(SandboxScanner.ScanAll(SandBox), currentSlot, MainGuiManager.State.currentSlotMetadata)
end

function MainGuiManager.PerformSaveWithSlot(p)
	SaveModelsEvent:FireServer(SandboxScanner.ScanAll(SandBox), p, MainGuiManager.State.currentSlotMetadata)
end
function MainGuiManager.PerformLoad()
	LoadModelsEvents:FireServer(currentSlot)
end

function MainGuiManager.UpdateSandboxUI(_)
	GUIReferences.MainUi.SandBoxUI.Properties.Visible = visible
	GUIReferences.MainUi.SandBoxUI.Transform.Visible = visible
end

SpawnButton.MouseButton1Click:Connect(function()
	MainGuiManager.SpawnModels()
end)

function MainGuiManager.getSelectedSortOption(p: string)
	return MainGuiManager.State.selectedSortOptions[p] or "Name"
end

function MainGuiManager.getSelectedTypeOption()
	return MainGuiManager.State.selectedTypeOption or "All"
end

function MainGuiManager.setSelectedSortOption(p: string, p2: string)
	MainGuiManager.State.selectedSortOptions[p] = p2
	MainGuiManager.setSortBy(p2)
end

function MainGuiManager.setSelectedTypeOption(selectedTypeOption: string)
	MainGuiManager.State.selectedTypeOption = selectedTypeOption
	MainGuiManager.setFilterType(selectedTypeOption)
end

function MainGuiManager.setSortBy(sortBy: string)
	MainGuiManager.State.sortBy = sortBy
end

function MainGuiManager.setFilterType(filterType: string)
	MainGuiManager.State.filterType = filterType
end

function MainGuiManager.getSortBy()
	return MainGuiManager.State.sortBy
end

function MainGuiManager.getFilterType()
	return MainGuiManager.State.filterType
end

local SlotName = GUIReferences.PageElements.DataSlotsPage.Properties.SlotName
SlotName.FocusLost:Connect(function(p)
	if p then
		MainGuiManager.State.currentSlotMetadata[tostring(currentSlot)].SlotName = tostring(SlotName.Text)
	end
end)
return MainGuiManager