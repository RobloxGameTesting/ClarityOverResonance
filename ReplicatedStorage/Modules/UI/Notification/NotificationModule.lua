local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local NotificationModule = {}

local notification = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UI"):WaitForChild("Notification")

local v = {
	{ Color = Color3.fromRGB(0, 170, 255), Image = "rbxassetid://95967056229276" },
	{ Color = Color3.fromRGB(0, 200, 120), Image = "rbxassetid://107193604067828" },
	{ Color = Color3.fromRGB(255, 170, 0), Image = "rbxassetid://103033046015925" },
	{ Color = Color3.fromRGB(255, 80, 80), Image = "rbxassetid://103033046015925" }
}

local function getGui() -- 1 equivalent call inferred from this helper
	return LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notification")
end

local function fadeOut(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("TextLabel") then
			TweenService:Create(descendant, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			TweenService:Create(descendant, TweenInfo.new(0.2), { ImageTransparency = 1 }):Play()
		elseif descendant:IsA("UIStroke") then
			TweenService:Create(descendant, TweenInfo.new(0.2), { Transparency = 1 }):Play()
		end
	end

	TweenService:Create(folder, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
end

function NotificationModule.notify(p, p2, value, value2)
	local gui = getGui() -- inferred equivalent call

	if not gui then
		return
	end

	local container = gui.Container
	local notif = container.Template:Clone()

	notif.Visible = true
	notif.Parent = container
	notif.Name = "Notif"

	notif.Header.Text = tostring(p)
	notif.SubHeader.Text = tostring(p2)

	local v2 = v[value2 or 1]

	if v2 then
		notif.ImageInfo.Image = v2.Image
		notif.UIStroke.Color = v2.Color
	end

	notif.AnchorPoint = Vector2.new(1, 0)
	notif.Position = UDim2.fromScale(1.2, notif.Position.Y.Scale)

	TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(1, notif.Position.Y.Scale)
	}):Play()

	local flag = false
	local function remove()
		if flag then
			return
		end

		flag = true
		fadeOut(notif)
		task.delay(0.2, function()
			notif:Destroy()
		end)
	end
	notif.CloseButton.MouseButton1Click:Connect(remove)

	task.delay(value or 3, remove)
end

notification.OnClientEvent:Connect(function(p, p2, p3, p4)
	NotificationModule.notify(p, p2, p3, p4)
end)

return NotificationModule