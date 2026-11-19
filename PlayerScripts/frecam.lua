local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")

local v = {
	toggleKey = Enum.KeyCode.F,
	rollLeftKey = Enum.KeyCode.Z,
	rollRightKey = Enum.KeyCode.C,
	rollResetKey = Enum.KeyCode.X,
	uiToggleKey = Enum.KeyCode.U,
	cursorToggleKey = Enum.KeyCode.M,
	speedIncreaseKey = Enum.KeyCode.Equals,
	speedDecreaseKey = Enum.KeyCode.Minus,
	speedResetKey = Enum.KeyCode.Zero,
	rollSpeedIncreaseKey = Enum.KeyCode.RightBracket,
	rollSpeedDecreaseKey = Enum.KeyCode.LeftBracket,
	boostKey = Enum.KeyCode.LeftShift,
	slowKey = Enum.KeyCode.LeftControl,
	baseSpeed = 60,
	minSpeed = 1,
	maxSpeed = 500,
	speedStep = 10,
	boostMultiplier = 3,
	slowMultiplier = 0.25,
	sensitivity = 0.12,
	rollSpeed = 1.3962634015954636,
	rollSpeedStep = 0.17453292519943295,
	minRollSpeed = 0.17453292519943295,
	maxRollSpeed = 3.141592653589793,
	pitchClamp = 1.4835298641951802,
	posSmooth = 10,
	rotSmooth = 12,
	fovSmooth = 12,
	defaultFov = 70,
	minFov = 3,
	maxFov = 120,
	zoomStep = 3
}

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local v2 = false

local v3 = v.baseSpeed
local v4 = v.defaultFov
local v5 = v.rollSpeed

local v6 = 0
local v7 = 0
local total = 0
local v8 = 0
local v9 = 0

local cframe = nil
local v10 = nil

local humanoid = nil
local v11 = {}
local flag = false
local v12 = false
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local v13 = false

local function getHumanoid() -- 2 equivalent calls inferred from this helper
	humanoid = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
end

getHumanoid() -- inferred equivalent call
LocalPlayer.CharacterAdded:Connect(function()
	getHumanoid() -- inferred equivalent call

	if v2 then
		local v14 = humanoid

		if v14 then
			v11.Humanoid = {
				WalkSpeed = v14.WalkSpeed,
				JumpPower = v14.JumpPower,
				JumpHeight = v14.JumpHeight,
				UseJumpPower = v14.UseJumpPower,
				AutoRotate = v14.AutoRotate
			}

			v14.WalkSpeed = 0

			if v14.UseJumpPower then
				v14.JumpPower = 0
			else
				v14.JumpHeight = 0
			end

			v14.AutoRotate = false
		end
	elseif flag then
		local v14 = humanoid
		local humanoid2 = v11.Humanoid

		if v14 and humanoid2 then
			v14.WalkSpeed = humanoid2.WalkSpeed
			v14.AutoRotate = humanoid2.AutoRotate
			v14.UseJumpPower = humanoid2.UseJumpPower

			if humanoid2.UseJumpPower then
				v14.JumpPower = humanoid2.JumpPower
			else
				v14.JumpHeight = humanoid2.JumpHeight
			end

			flag = false
		end
	end
end)

local v14 = {
	[Enum.KeyCode.W] = false,
	[Enum.KeyCode.A] = false,
	[Enum.KeyCode.S] = false,
	[Enum.KeyCode.D] = false,
	[Enum.KeyCode.Q] = false,
	[Enum.KeyCode.E] = false
}

local v15 = { [v.rollLeftKey] = false, [v.rollRightKey] = false }

local function bindInputs()
	ContextActionService:BindAction("FC_Move", function(_, p, p2)
		local keyCode = p2.KeyCode

		if v14[keyCode] ~= nil then
			if p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change then
				v14[keyCode] = true
			else
				v14[keyCode] = false
			end
		end

		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Q, Enum.KeyCode.E)

	ContextActionService:BindAction("FC_Roll", function(_, p, p2)
		local keyCode = p2.KeyCode

		if v15[keyCode] ~= nil then
			if p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change then
				v15[keyCode] = true
			else
				v15[keyCode] = false
			end
		end

		return Enum.ContextActionResult.Sink
	end, false, v.rollLeftKey, v.rollRightKey)
end

local function bindExtraControls() -- 1 equivalent call inferred from this helper
	ContextActionService:BindAction("FC_Extra", function(_, p, p2)
		if p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Sink
		end

		if p2.KeyCode == v.speedIncreaseKey then
			v3 = math.min(v.maxSpeed, v3 + v.speedStep)
		elseif p2.KeyCode == v.speedDecreaseKey then
			v3 = math.max(v.minSpeed, v3 - v.speedStep)
		elseif p2.KeyCode == v.speedResetKey then
			v3 = v.baseSpeed
		end

		if p2.KeyCode == v.rollResetKey then
			total = 0
		end

		if p2.KeyCode == v.rollSpeedIncreaseKey then
			v5 = math.min(v.maxRollSpeed, v5 + v.rollSpeedStep)
		elseif p2.KeyCode == v.rollSpeedDecreaseKey then
			v5 = math.max(v.minRollSpeed, v5 - v.rollSpeedStep)
		end

		return Enum.ContextActionResult.Sink
	end, false, v.speedDecreaseKey, v.speedResetKey, v.rollResetKey, v.rollSpeedIncreaseKey, v.rollSpeedDecreaseKey)
end

local function unbindInputs()
	ContextActionService:UnbindAction("FC_Move")
	ContextActionService:UnbindAction("FC_Roll")
	ContextActionService:UnbindAction("FC_Extra")

	for k in pairs(v14) do
		v14[k] = false
	end

	for k in pairs(v15) do
		v15[k] = false
	end
end

local function captureCoreGuiState()
	local result = {}

	for _, v16 in ipairs(Enum.CoreGuiType:GetEnumItems()) do
		local success, result2 = pcall(function()
			return StarterGui:GetCoreGuiEnabled(v16)
		end)

		if success then
			result[v16] = result2
		end
	end

	return result
end

local function applyCoreGuiState(p, p2)
	for _, v16 in ipairs(Enum.CoreGuiType:GetEnumItems()) do
		local v17

		if p2 == nil then
			v17 = p and p[v16]
		else
			v17 = p2
		end

		if v17 ~= nil then
			pcall(function()
				StarterGui:SetCoreGuiEnabled(v16, v17)
			end)
		end
	end
end

local function capturePlayerGuiState()
	local enabledsByScreenGui = {}

	for _, screenGui in ipairs(PlayerGui:GetDescendants()) do
		if screenGui:IsA("ScreenGui") then
			enabledsByScreenGui[screenGui] = screenGui.Enabled
		end
	end

	return enabledsByScreenGui
end

local function applyPlayerGuiState(options, enabled)
	for screenGui, enabled2 in pairs(options or {}) do
		if not (screenGui and screenGui.Parent and screenGui:IsA("ScreenGui")) then
			continue
		end

		if enabled == nil then
			screenGui.Enabled = enabled2
		else
			screenGui.Enabled = enabled
		end
	end

	if enabled ~= nil then
		for _, screenGui in ipairs(PlayerGui:GetDescendants()) do
			if screenGui:IsA("ScreenGui") then
				screenGui.Enabled = enabled
			end
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == v.toggleKey then
		v2 = not v2

		if v2 then
			v11 = {
				Camera = {
					CFrame = CurrentCamera.CFrame,
					Type = CurrentCamera.CameraType,
					Fov = CurrentCamera.FieldOfView,
					Subject = CurrentCamera.CameraSubject
				},
				Humanoid = humanoid and {
					WalkSpeed = humanoid.WalkSpeed,
					JumpPower = humanoid.JumpPower,
					JumpHeight = humanoid.JumpHeight,
					UseJumpPower = humanoid.UseJumpPower,
					AutoRotate = humanoid.AutoRotate
				} or nil,
				Mouse = {
					Behavior = UserInputService.MouseBehavior,
					Icon = UserInputService.MouseIconEnabled
				},
				CoreGui = captureCoreGuiState(),
				PlayerGui = capturePlayerGuiState()
			}

			v7, v6 = CurrentCamera.CFrame:ToOrientation()
			total = 0
			v9 = v7
			v8 = v6

			if humanoid then
				humanoid.WalkSpeed = 0

				if humanoid.UseJumpPower then
					humanoid.JumpPower = 0
				else
					humanoid.JumpHeight = 0
				end

				humanoid.AutoRotate = false
			end

			CurrentCamera.CameraType = Enum.CameraType.Scriptable
			CurrentCamera.FieldOfView = v.defaultFov
			v4 = v.defaultFov

			cframe = CurrentCamera.CFrame
			v10 = CurrentCamera.CFrame

			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false
			v13 = false
			bindExtraControls() -- inferred equivalent call
			bindInputs()
		else
			unbindInputs()

			if v11.Camera then
				CurrentCamera.CameraType = v11.Camera.Type
				CurrentCamera.CFrame = v11.Camera.CFrame
				CurrentCamera.FieldOfView = v11.Camera.Fov
				CurrentCamera.CameraSubject = v11.Camera.Subject
			end

			if humanoid and v11.Humanoid then
				humanoid.WalkSpeed = v11.Humanoid.WalkSpeed
				humanoid.AutoRotate = v11.Humanoid.AutoRotate
				humanoid.UseJumpPower = v11.Humanoid.UseJumpPower

				if v11.Humanoid.UseJumpPower then
					humanoid.JumpPower = v11.Humanoid.JumpPower
				else
					humanoid.JumpHeight = v11.Humanoid.JumpHeight
				end
			elseif v11.Humanoid and not humanoid then
				flag = true
			end

			task.defer(function()
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true

				task.wait()
				UserInputService.MouseBehavior = v11.Mouse and v11.Mouse.Behavior or Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = not v11.Mouse or v11.Mouse.Icon ~= false
			end)

			if v12 then
				v12 = false
				task.defer(function()
					applyCoreGuiState(v11.CoreGui, nil)
					local playerGui = v11.PlayerGui

					for screenGui, enabled in pairs(playerGui or {}) do
						if screenGui and screenGui.Parent and screenGui:IsA("ScreenGui") then
							screenGui.Enabled = enabled
						end
					end
				end)
			end

			v13 = false
		end
	else
		if not v2 then
			return
		end

		if input.KeyCode == v.cursorToggleKey then
			v13 = not v13

			if v13 then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			else
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				UserInputService.MouseIconEnabled = false
			end
		else
			if input.KeyCode ~= v.uiToggleKey then
				return
			end

			v12 = not v12
			task.defer(function()
				if v12 then
					applyCoreGuiState(nil, false)
					applyPlayerGuiState(nil, false)
				else
					applyCoreGuiState(v11.CoreGui, nil)
					local playerGui = v11.PlayerGui

					for screenGui, enabled in pairs(playerGui or {}) do
						if screenGui and screenGui.Parent and screenGui:IsA("ScreenGui") then
							screenGui.Enabled = enabled
						end
					end
				end
			end)
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if v2 and input.UserInputType == Enum.UserInputType.MouseWheel then
		v4 = math.clamp(v4 - input.Position.Z * v.zoomStep, v.minFov, v.maxFov)
	end
end)

UserInputService.WindowFocusReleased:Connect(function()
	if not v2 then
		return
	end

	for k in pairs(v14) do
		v14[k] = false
	end

	for k in pairs(v15) do
		v15[k] = false
	end
end)

local function smooth(p, p2) -- 3 equivalent calls inferred from this helper
	return 1 - math.exp(-p * p2)
end

RunService.RenderStepped:Connect(function(dt)
	if not v2 then
		return
	end

	local v16 = dt > 0.05 and 0.05 or dt
	local mouseDelta = UserInputService:GetMouseDelta()
	v8 -= mouseDelta.X * v.sensitivity * 0.01
	v9 -= mouseDelta.Y * v.sensitivity * 0.01
	v9 = math.clamp(v9, -v.pitchClamp, v.pitchClamp)

	local v17 = smooth(v.rotSmooth, v16) -- inferred equivalent call
	v6 += (v8 - v6) * v17
	v7 += (v9 - v7) * v17

	local v18 = (v15[v.rollRightKey] and 1 or 0) - (v15[v.rollLeftKey] and 1 or 0)
	total += v18 * v5 * v16

	local cframe2 = CFrame.Angles(0, v6, 0) * CFrame.Angles(v7, 0, 0) * CFrame.Angles(0, 0, total)

	local vector3 = Vector3.new(
		(v14[Enum.KeyCode.D] and 1 or 0) - (v14[Enum.KeyCode.A] and 1 or 0),
		(v14[Enum.KeyCode.E] and 1 or 0) - (v14[Enum.KeyCode.Q] and 1 or 0),
		(v14[Enum.KeyCode.S] and 1 or 0) - (v14[Enum.KeyCode.W] and 1 or 0)
	)
	local v19

	if vector3.Magnitude > 0 then
		local v20 = v3

		if UserInputService:IsKeyDown(v.boostKey) then
			v20 *= v.boostMultiplier
		elseif UserInputService:IsKeyDown(v.slowKey) then
			v20 *= v.slowMultiplier
		end

		v19 = cframe2:VectorToWorldSpace(vector3.Unit) * v20 * v16
	else
		v19 = Vector3.new(0, 0, 0)
	end

	v10 = CFrame.new(v10.Position + v19) * cframe2
	cframe = cframe:Lerp(v10, smooth(v.posSmooth, v16)) -- inferred equivalent call
	CurrentCamera.CFrame = cframe
	CurrentCamera.FieldOfView += (v4 - CurrentCamera.FieldOfView) * smooth(v.fovSmooth, v16) -- inferred equivalent call
end)

print("Hi!")