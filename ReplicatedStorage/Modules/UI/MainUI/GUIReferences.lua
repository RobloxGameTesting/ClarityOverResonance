local GUIReferences = {}

local Players = game:GetService("Players")
GUIReferences.MainUi = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUi")
GUIReferences.Main = GUIReferences.MainUi:WaitForChild("Main")
GUIReferences.MainFrame = GUIReferences.Main:WaitForChild("Main")

GUIReferences.NavBar = GUIReferences.MainFrame:WaitForChild("NavBar")
GUIReferences.NavButtons = {
	DataSlots = GUIReferences.NavBar:WaitForChild("DataSlots"),
	Models = GUIReferences.NavBar:WaitForChild("Models"),
	Template = GUIReferences.NavBar:WaitForChild("Template"),
	ImageCatalog = GUIReferences.NavBar:WaitForChild("ImageCatalog"),
	Info = GUIReferences.NavBar:WaitForChild("Info"),
	Settings = GUIReferences.NavBar:WaitForChild("Settings"),
	Close = GUIReferences.NavBar:WaitForChild("Close")
}

GUIReferences.Page = GUIReferences.MainFrame:WaitForChild("Page")
GUIReferences.Pages = {
	ModelsPage = GUIReferences.Page:WaitForChild("ModelsPage"),
	DataSlotsPage = GUIReferences.Page:WaitForChild("DataSlotsPage"),
	TemplatePage = GUIReferences.Page:WaitForChild("TemplatePage"),
	ImageCatalogPage = GUIReferences.Page:WaitForChild("ImageCatalogPage"),
	InfoPage = GUIReferences.Page:WaitForChild("InfoPage"),
	SettingsPage = GUIReferences.Page:WaitForChild("Settings")
}

GUIReferences.ButtonSlots = GUIReferences.Main:WaitForChild("btn_Slots")

GUIReferences.SendDataScript = GUIReferences.Main:WaitForChild("SendData")

GUIReferences.PageElements = {}

GUIReferences.PageElements.ModelsPage = {
	Containers = {
		ScrollFrame = GUIReferences.Pages.ModelsPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"),
		Frame = GUIReferences.Pages.ModelsPage:WaitForChild("Containers"):WaitForChild("Frame")
	},
	Properties = {
		DataInfo = GUIReferences.Pages.ModelsPage:WaitForChild("Properties"):WaitForChild("DataInfo"),
		SpawnButton = GUIReferences.Pages.ModelsPage:WaitForChild("Properties"):WaitForChild("SpawnButton"),
		ItemName = GUIReferences.Pages.ModelsPage:WaitForChild("Properties"):WaitForChild("ItemName"),
		Preview = GUIReferences.Pages.ModelsPage:WaitForChild("Properties"):WaitForChild("Preview")
	},
	Search = {
		TextBox = GUIReferences.Pages.ModelsPage:WaitForChild("Search"),
		Icon = GUIReferences.Pages.ModelsPage:WaitForChild("Search"):WaitForChild("Icon")
	},
	Sort = {
		Button = GUIReferences.Pages.ModelsPage:WaitForChild("Sort"),
		Image = GUIReferences.Pages.ModelsPage:WaitForChild("Sort"):WaitForChild("Image"),
		Container = GUIReferences.Pages.ModelsPage:WaitForChild("Sort"):WaitForChild("Container")
	},
	Type = {
		Button = GUIReferences.Pages.ModelsPage:WaitForChild("Type"),
		Image = GUIReferences.Pages.ModelsPage:WaitForChild("Type"):WaitForChild("Image"),
		Container = GUIReferences.Pages.ModelsPage:WaitForChild("Type"):WaitForChild("Container")
	}
}

GUIReferences.PageElements.DataSlotsPage = {
	Containers = {
		ScrollFrame = GUIReferences.Pages.DataSlotsPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"),
		Frame = GUIReferences.Pages.DataSlotsPage:WaitForChild("Containers"):WaitForChild("Frame"),
		TemplateIndex = GUIReferences.Pages.DataSlotsPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"):WaitForChild("Template")
	},
	Properties = {
		DataInfo = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("DataInfo"),
		Spawn = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("Spawn"),
		Delete = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("Delete"),
		Export = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("Export"),
		Save = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("Save"),
		Load = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("Load"),
		SlotName = GUIReferences.Pages.DataSlotsPage:WaitForChild("Properties"):WaitForChild("SlotName")
	},
	Search = {
		TextBox = GUIReferences.Pages.DataSlotsPage:WaitForChild("Search"),
		Icon = GUIReferences.Pages.DataSlotsPage:WaitForChild("Search"):WaitForChild("Icon")
	},
	Sort = {
		Button = GUIReferences.Pages.DataSlotsPage:WaitForChild("Sort"),
		Image = GUIReferences.Pages.DataSlotsPage:WaitForChild("Sort"):WaitForChild("Image"),
		Container = GUIReferences.Pages.DataSlotsPage:WaitForChild("Sort"):WaitForChild("Container")
	}
}

GUIReferences.PageElements.TemplatePage = {
	Containers = {
		ScrollFrame = GUIReferences.Pages.TemplatePage:WaitForChild("Containers"):WaitForChild("ScrollFrame"),
		Frame = GUIReferences.Pages.TemplatePage:WaitForChild("Containers"):WaitForChild("Frame")
	},
	Properties = {
		Load = GUIReferences.Pages.TemplatePage:WaitForChild("Properties"):WaitForChild("Load"),
		SlotName = GUIReferences.Pages.TemplatePage:WaitForChild("Properties"):WaitForChild("SlotName"),
		Report = GUIReferences.Pages.TemplatePage:WaitForChild("Properties"):WaitForChild("Report"),
		ByUser = GUIReferences.Pages.TemplatePage:WaitForChild("Properties"):WaitForChild("ByUser"),
		Date = GUIReferences.Pages.TemplatePage:WaitForChild("Properties"):WaitForChild("Date"),
		MCounts = GUIReferences.Pages.TemplatePage:WaitForChild("Properties"):WaitForChild("MCounts")
	},
	Search = {
		TextBox = GUIReferences.Pages.TemplatePage:WaitForChild("Search"),
		Icon = GUIReferences.Pages.TemplatePage:WaitForChild("Search"):WaitForChild("Icon")
	},
	Sort = {
		Button = GUIReferences.Pages.TemplatePage:WaitForChild("Sort"),
		Image = GUIReferences.Pages.TemplatePage:WaitForChild("Sort"):WaitForChild("Image"),
		Container = GUIReferences.Pages.TemplatePage:WaitForChild("Sort"):WaitForChild("Container")
	}
}

GUIReferences.PageElements.ImageCatalogPage = {
	Containers = {
		ScrollFrame = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"),
		Frame = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Containers"):WaitForChild("Frame")
	},
	Properties = {
		ImageName = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Properties"):WaitForChild("ImageName"),
		Report = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Properties"):WaitForChild("Report"),
		ByUser = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Properties"):WaitForChild("ByUser"),
		Date = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Properties"):WaitForChild("Date"),
		IDImage = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Properties"):WaitForChild("IDImage"),
		ImageLabel = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Properties"):WaitForChild("ImageLabel")
	},
	Search = {
		TextBox = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Search"),
		Icon = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Search"):WaitForChild("Icon")
	},
	Sort = {
		Button = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Sort"),
		Image = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Sort"):WaitForChild("Image"),
		Container = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Sort"):WaitForChild("Container")
	},
	Upload = GUIReferences.Pages.ImageCatalogPage:WaitForChild("Upload")
}

GUIReferences.PageElements.InfoPage = {
	Containers = {
		ScrollFrame = GUIReferences.Pages.InfoPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"),
		Frame = GUIReferences.Pages.InfoPage:WaitForChild("Containers"):WaitForChild("Frame")
	}
}

GUIReferences.PageElements.SettingsPage = {
	Containers = {
		ScrollFrame = GUIReferences.Pages.SettingsPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"),
		Frame = GUIReferences.Pages.SettingsPage:WaitForChild("Containers"):WaitForChild("Frame"),
		TemplateSet = GUIReferences.Pages.SettingsPage:WaitForChild("Containers"):WaitForChild("ScrollFrame"):WaitForChild("Category")
	},
	Search = {
		TextBox = GUIReferences.Pages.SettingsPage:WaitForChild("Search"),
		Icon = GUIReferences.Pages.SettingsPage:WaitForChild("Search"):WaitForChild("Icon")
	},
	TextLabel = GUIReferences.Pages.SettingsPage:WaitForChild("TextLabel"),
	ImageLabel = GUIReferences.Pages.SettingsPage:WaitForChild("ImageLabel")
}

GUIReferences.UIComponents = {}

GUIReferences.UIComponents.NavButtons = {}

for k, navButton in pairs(GUIReferences.NavButtons) do
	GUIReferences.UIComponents.NavButtons[k] = {
		Button = navButton,
		UICorner = navButton:FindFirstChild("UICorner"),
		UIStroke = navButton:FindFirstChild("UIStroke"),
		UIGradient = navButton:FindFirstChild("UIGradient"),
		UIAspectRatioConstraint = navButton:FindFirstChild("UIAspectRatioConstraint")
	}
end

GUIReferences.UIComponents.ButtonSlots = {
	Button = GUIReferences.ButtonSlots,
	ImageLabel = GUIReferences.ButtonSlots:FindFirstChild("ImageLabel"),
	TextLabel = GUIReferences.ButtonSlots:FindFirstChild("TextLabel"),
	UICorner = GUIReferences.ButtonSlots:FindFirstChild("UICorner"),
	UIGradient = GUIReferences.ButtonSlots:FindFirstChild("UIGradient"),
	UIStroke = GUIReferences.ButtonSlots:FindFirstChild("UIStroke")
}

GUIReferences.UIComponents.SearchComponents = {}

local function setupSearchComponents(p, p2)
	if p2.Search then
		GUIReferences.UIComponents.SearchComponents[p] = {
			TextBox = p2.Search.TextBox,
			Icon = p2.Search.Icon,
			UICorner = p2.Search.TextBox:FindFirstChild("UICorner"),
			UIStroke = p2.Search.TextBox:FindFirstChild("UIStroke"),
			UIGradient = p2.Search.TextBox:FindFirstChild("UIGradient")
		}
	end
end

setupSearchComponents("ModelsPage", GUIReferences.PageElements.ModelsPage)
setupSearchComponents("DataSlotsPage", GUIReferences.PageElements.DataSlotsPage)
setupSearchComponents("TemplatePage", GUIReferences.PageElements.TemplatePage)
setupSearchComponents("ImageCatalogPage", GUIReferences.PageElements.ImageCatalogPage)
setupSearchComponents("SettingsPage", GUIReferences.PageElements.SettingsPage)

GUIReferences.UIComponents.SortComponents = {}

local function setupSortComponents(p, p2)
	if p2.Sort then
		GUIReferences.UIComponents.SortComponents[p] = {
			Button = p2.Sort.Button,
			Image = p2.Sort.Image,
			Container = p2.Sort.Container,
			UICorner = p2.Sort.Button:FindFirstChild("UICorner"),
			UIStroke = p2.Sort.Button:FindFirstChild("UIStroke"),
			UIGradient = p2.Sort.Button:FindFirstChild("UIGradient")
		}
	end
end

setupSortComponents("ModelsPage", GUIReferences.PageElements.ModelsPage)
setupSortComponents("DataSlotsPage", GUIReferences.PageElements.DataSlotsPage)
setupSortComponents("TemplatePage", GUIReferences.PageElements.TemplatePage)
setupSortComponents("ImageCatalogPage", GUIReferences.PageElements.ImageCatalogPage)

if GUIReferences.PageElements.ModelsPage.Type then
	GUIReferences.UIComponents.TypeComponents = {
		Button = GUIReferences.PageElements.ModelsPage.Type.Button,
		Image = GUIReferences.PageElements.ModelsPage.Type.Image,
		Container = GUIReferences.PageElements.ModelsPage.Type.Container,
		UICorner = GUIReferences.PageElements.ModelsPage.Type.Button:FindFirstChild("UICorner"),
		UIStroke = GUIReferences.PageElements.ModelsPage.Type.Button:FindFirstChild("UIStroke"),
		UIGradient = GUIReferences.PageElements.ModelsPage.Type.Button:FindFirstChild("UIGradient")
	}
end

GUIReferences.UIComponents.UploadComponents = {}

if GUIReferences.PageElements.TemplatePage.Upload then
	GUIReferences.UIComponents.UploadComponents.TemplatePage = {
		Button = GUIReferences.PageElements.TemplatePage.Upload,
		UICorner = GUIReferences.PageElements.TemplatePage.Upload:FindFirstChild("UICorner"),
		UIStroke = GUIReferences.PageElements.TemplatePage.Upload:FindFirstChild("UIStroke"),
		UIGradient = GUIReferences.PageElements.TemplatePage.Upload:FindFirstChild("UIGradient")
	}
end

if GUIReferences.PageElements.ImageCatalogPage.Upload then
	GUIReferences.UIComponents.UploadComponents.ImageCatalogPage = {
		Button = GUIReferences.PageElements.ImageCatalogPage.Upload,
		UICorner = GUIReferences.PageElements.ImageCatalogPage.Upload:FindFirstChild("UICorner"),
		UIStroke = GUIReferences.PageElements.ImageCatalogPage.Upload:FindFirstChild("UIStroke"),
		UIGradient = GUIReferences.PageElements.ImageCatalogPage.Upload:FindFirstChild("UIGradient")
	}
end

GUIReferences.UIComponents.ContainerComponents = {}

local function setupContainerComponents(p, p2)
	if p2.Containers then
		GUIReferences.UIComponents.ContainerComponents[p] = {
			ScrollFrame = p2.Containers.ScrollFrame,
			Frame = p2.Containers.Frame,
			UICorner = p2.Containers.ScrollFrame:FindFirstChild("UICorner"),
			UIStroke = p2.Containers.ScrollFrame:FindFirstChild("UIStroke"),
			UIGradient = p2.Containers.Frame:FindFirstChild("UIGradient")
		}
	end
end

setupContainerComponents("ModelsPage", GUIReferences.PageElements.ModelsPage)
setupContainerComponents("DataSlotsPage", GUIReferences.PageElements.DataSlotsPage)
setupContainerComponents("TemplatePage", GUIReferences.PageElements.TemplatePage)
setupContainerComponents("ImageCatalogPage", GUIReferences.PageElements.ImageCatalogPage)
setupContainerComponents("InfoPage", GUIReferences.PageElements.InfoPage)
setupContainerComponents("SettingsPage", GUIReferences.PageElements.SettingsPage)

function GUIReferences.getPage(p: string)
	return GUIReferences.Pages[p]
end

function GUIReferences.getNavButton(p: string)
	return GUIReferences.NavButtons[p]
end

function GUIReferences.getPageElements(p: string)
	return GUIReferences.PageElements[p]
end

function GUIReferences.getUIComponents(p: string, p2: string?)
	if p2 then
		return GUIReferences.UIComponents[p][p2]
	end

	return GUIReferences.UIComponents[p]
end

function GUIReferences.hideAllPages()
	for _, page in pairs(GUIReferences.Pages) do
		page.Visible = false
	end
end

function GUIReferences.showPage(p: string)
	GUIReferences.hideAllPages()
	local page = GUIReferences.getPage(p)

	if page then
		page.Visible = true
	end
end

function GUIReferences.getScrollFrame(p: string)
	local pageElements = GUIReferences.getPageElements(p)

	if pageElements and pageElements.Containers then
		return pageElements.Containers.ScrollFrame
	end

	return nil
end

function GUIReferences.getSearchBox(p: string)
	local uiComponents = GUIReferences.getUIComponents("SearchComponents", p)

	return if uiComponents then uiComponents.TextBox else nil
end

function GUIReferences.getProperties(p: string)
	local pageElements = GUIReferences.getPageElements(p)

	if pageElements and pageElements.Properties then
		return pageElements.Properties
	end

	return nil
end

function GUIReferences.getStylingComponents(instance)
	return {
		UICorner = instance:FindFirstChild("UICorner"),
		UIStroke = instance:FindFirstChild("UIStroke"),
		UIGradient = instance:FindFirstChild("UIGradient"),
		UIAspectRatioConstraint = instance:FindFirstChild("UIAspectRatioConstraint"),
		UITextSizeConstraint = instance:FindFirstChild("UITextSizeConstraint")
	}
end

return GUIReferences