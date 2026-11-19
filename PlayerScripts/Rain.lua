local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local rain = ReplicatedStorage:WaitForChild("Asset"):WaitForChild("Rain")
local rainSky = rain:WaitForChild("RainSky")
local rain2 = rain:WaitForChild("Rain")
local sound = rain2:WaitForChild("Rain_Fall"):WaitForChild("Sound")
local Clouds = Workspace.Terrain:WaitForChild("Clouds")
local Atmosphere = Lighting:WaitForChild("Atmosphere")
local sky = Lighting:FindFirstChildWhichIsA("Sky")
local SunRays = Lighting:WaitForChild("SunRays")

local v = {
	TransisiKeHujan = 40,
	TransisiKeCerah = 40,
	RainFallHeightOffset = 20,
	RainSpreadSize = Vector3.new(180, 1, 180),
	RainForwardOffset = 0,
	MaxRateRainFall = 300,
	MaxRateRainSplash = 300,
	MinIntensityScale = 0.15,
	RainSettings = {
		Brightness = 0,
		OutdoorAmbient = Color3.fromRGB(49, 44, 36),
		Ambient = Color3.fromRGB(56, 42, 25),
		FogColor = Color3.fromRGB(110, 120, 130),
		FogEnd = 150,
		CloudCover = 0.4,
		CloudDensity = 0.85,
		AtmoDensity = 0.45,
		AtmoOffset = 0,
		AtmoColor = Color3.fromRGB(105, 118, 128),
		AtmoDecay = Color3.fromRGB(70, 80, 90),
		AtmoHaze = 0
	},
	GantiSkyboxSaatHujan = true,
	TanahRayLength = 500
}

local v2 = {
	Brightness = Lighting.Brightness,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Ambient = Lighting.Ambient,
	FogColor = Lighting.FogColor,
	FogEnd = Lighting.FogEnd,
	CloudCover = Clouds.Cover,
	CloudDensity = Clouds.Density,
	AtmoDensity = Atmosphere.Density,
	AtmoOffset = Atmosphere.Offset,
	AtmoColor = Atmosphere.Color,
	AtmoDecay = Atmosphere.Decay,
	AtmoHaze = Atmosphere.Haze
}

local function getServerNow() -- 2 equivalent calls inferred from this helper
	return os.time()
end

local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}

local function collectEmitters(folder, descendants)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Sparkles") then
			table.insert(descendants, descendant)
		end
	end
end

local function buildRig()
	table.clear(v3)
	table.clear(v4)
	table.clear(v5)
	table.clear(v6)

	for _, part in ipairs(rain2:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local name = part.Name

		if name == "Rain_Fall" then
			table.insert(v3, part)
			collectEmitters(part, v4)
		elseif name == "Rain_Splash" then
			table.insert(v3, part)
			collectEmitters(part, v5)
		end
	end

	if #v3 == 0 and rain2:IsA("BasePart") then
		table.insert(v3, rain2)
		collectEmitters(rain2, v4)
	end

	assert(#v3 > 0, "[RainClient] Part 'Rain_Fall'/'Rain_Splash' tidak ditemukan di dalam Rain object!")
end

local function resetEmitters(enabled) -- 1 equivalent call inferred from this helper
	for _, list in ipairs({ v4, v5 }) do
		for _, item in ipairs(list) do
			item.Enabled = enabled

			if not enabled then
				item:Emit(0)
			end
		end
	end
end

local function applyIntensity(intensity)
	local v7 = math.clamp(intensity, v.MinIntensityScale, 1)

	for _, v8 in ipairs(v4) do
		v8.Rate = v.MaxRateRainFall * v7
	end

	for _, v8 in ipairs(v5) do
		v8.Rate = v.MaxRateRainSplash * v7
	end
end

local renderSteppedConnection = nil

local function findGroundY(position)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { Players.LocalPlayer.Character, rain2 }
	local raycastResult = Workspace:Raycast(
		position + Vector3.new(0, 5, 0),
		Vector3.new(0, -v.TanahRayLength, 0),
		raycastParams
	)

	if raycastResult then
		return raycastResult.Position.Y
	end

	return position.Y - 5
end

local function startCameraFollow()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local currentCamera = Workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local position = currentCamera.CFrame.Position

		for _, v7 in ipairs(v3) do
			if v7.Name == "Rain_Fall" then
				v7.CFrame = CFrame.new(position.X, position.Y + v.RainFallHeightOffset, position.Z)
			elseif v7.Name == "Rain_Splash" then
				local v8 = v6[v7]

				if not v8 then
					v8 = findGroundY(position)
					v6[v7] = v8
				end

				v7.CFrame = CFrame.new(position.X, v8, position.Z)
			end
		end
	end)
end

local function stopCameraFollow() -- 1 equivalent call inferred from this helper
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local function lerpColor(data, data2, p) -- 5 equivalent calls inferred from this helper
	return Color3.new(data.R + (data2.R - data.R) * p, data.G + (data2.G - data.G) * p, data.B + (data2.B - data.B) * p)
end

local function lerpNumber(p, p2, p3) -- 7 equivalent calls inferred from this helper
	return p + (p2 - p) * p3
end

local v7 = 0

local function applyVisualState(p)
	v7 = p
	local rainSettings = v.RainSettings
	local v8 = v2

	Lighting.Brightness = lerpNumber(v8.Brightness, rainSettings.Brightness, p) -- inferred equivalent call
	Lighting.OutdoorAmbient = lerpColor(v8.OutdoorAmbient, rainSettings.OutdoorAmbient, p) -- inferred equivalent call
	Lighting.Ambient = lerpColor(v8.Ambient, rainSettings.Ambient, p) -- inferred equivalent call
	Lighting.FogColor = lerpColor(v8.FogColor, rainSettings.FogColor, p) -- inferred equivalent call
	Lighting.FogEnd = lerpNumber(v8.FogEnd, rainSettings.FogEnd, p) -- inferred equivalent call

	Clouds.Cover = lerpNumber(v8.CloudCover, rainSettings.CloudCover, p) -- inferred equivalent call
	Clouds.Density = lerpNumber(v8.CloudDensity, rainSettings.CloudDensity, p) -- inferred equivalent call

	Atmosphere.Density = lerpNumber(v8.AtmoDensity, rainSettings.AtmoDensity, p) -- inferred equivalent call
	Atmosphere.Offset = lerpNumber(v8.AtmoOffset, rainSettings.AtmoOffset, p) -- inferred equivalent call
	Atmosphere.Color = lerpColor(v8.AtmoColor, rainSettings.AtmoColor, p) -- inferred equivalent call
	Atmosphere.Decay = lerpColor(v8.AtmoDecay, rainSettings.AtmoDecay, p) -- inferred equivalent call
	Atmosphere.Haze = lerpNumber(v8.AtmoHaze, rainSettings.AtmoHaze, p) -- inferred equivalent call
end

local count = 0
local function transitionTo(p, p2)
	count += 1
	local v8 = count
	local v9 = v7

	local v10 = math.max(p2, 0.05)
	local total = 0

	while total < v10 do
		if v8 ~= count then
			return
		end

		total += RunService.RenderStepped:Wait()
		local v11 = total / v10

		local v12 = (1 - math.cos(3.141592653589793 * v11)) / 2
		applyVisualState(v9 + (p - v9) * v12)
	end

	applyVisualState(p)
end

local function setSkybox(p) -- 3 equivalent calls inferred from this helper
	if not v.GantiSkyboxSaatHujan then
		return
	end

	if p then
		if sky and sky.Parent == Lighting then
			sky.Parent = rain
		end

		if rainSky.Parent ~= Lighting then
			rainSky.Parent = Lighting
		end
	else
		if rainSky.Parent == Lighting then
			rainSky.Parent = rain
		end

		if sky and sky.Parent ~= Lighting then
			sky.Parent = Lighting
		end
	end
end

local flag = false
local thread = nil

local endRain

local function beginRain(data)
	buildRig()
	local serverNow = getServerNow() -- inferred equivalent call
	local v8 = math.max(data.startTime - serverNow, 0)
	local transisiKeHujan = v.TransisiKeHujan

	flag = true

	if v8 == 0 then
		local v9 = math.max(serverNow - data.startTime, 0)

		if transisiKeHujan <= v9 then
			applyVisualState(1)
		else
			transitionTo(1, transisiKeHujan - v9)
		end
	else
		task.delay(v8, function()
			if flag then
				transitionTo(1, transisiKeHujan)
			end
		end)
	end

	local v9 = math.max(data.startTime + transisiKeHujan * 0.6 - serverNow, 0)
	task.delay(v9, function()
		if not flag then
			return
		end

		rain2.Parent = Workspace
		SunRays.Enabled = false
		sound:Play()

		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local currentCamera = Workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local position = currentCamera.CFrame.Position

			for _, v10 in ipairs(v3) do
				if v10.Name == "Rain_Fall" then
					v10.CFrame = CFrame.new(position.X, position.Y + v.RainFallHeightOffset, position.Z)
				elseif v10.Name == "Rain_Splash" then
					local v11 = v6[v10]

					if not v11 then
						v11 = findGroundY(position)
						v6[v10] = v11
					end

					v10.CFrame = CFrame.new(position.X, v11, position.Z)
				end
			end
		end)
		resetEmitters(true) -- inferred equivalent call
		applyIntensity(data.intensity)
		setSkybox(true) -- inferred equivalent call
	end)
	local v10 = data.startTime + data.duration - getServerNow() -- inferred equivalent call

	if thread then
		task.cancel(thread)
	end

	thread = task.delay(math.max(v10, 0), function()
		endRain()
	end)
end

endRain = function()
	if not flag then
		return
	end

	flag = false

	if thread then
		task.cancel(thread)
		thread = nil
	end

	resetEmitters(false)
	stopCameraFollow() -- inferred equivalent call
	transitionTo(0, v.TransisiKeCerah)
	setSkybox(false) -- inferred equivalent call
	sound:Stop()
	SunRays.Enabled = true
	rain2.Parent = rain
end

local RainSystem = ReplicatedStorage:WaitForChild("RainSystem")
local OnRainStart = RainSystem:WaitForChild("OnRainStart")
local OnRainEnd = RainSystem:WaitForChild("OnRainEnd")

OnRainStart.OnClientEvent:Connect(function(p)
	beginRain(p)
end)

OnRainEnd.OnClientEvent:Connect(function()
	endRain()
end)
setSkybox(false) -- inferred equivalent call