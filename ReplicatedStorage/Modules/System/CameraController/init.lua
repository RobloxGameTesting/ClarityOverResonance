local CameraController = {}
CameraController.__index = CameraController

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
game:GetService("UserService")

local function isOnMobile() -- 1 equivalent call inferred from this helper
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local _ = {
	zoomSpeed = 6,
	wheelZoomSpeed = 2,
	ZoomPosSpeed = 0.2,
	panSpeed = 0.005,
	orbitSpeed = 0.005,
	pinchThreshold = 2,
	twoFingerDragThreshold = 2,
	maxInteractionTime = 120,
	minZoomDistance = -50,
	maxZoomDistance = 50,
	followLerpSpeed = 12,
	followPositionOffset = Vector3.new(0, 0, 0),
	minFOV = 10,
	maxFOV = 120,
	LERP_SPEED = 10
}

local v = {
	active = false,
	origCFrame = nil,
	origType = nil,
	origSubject = nil,
	origFOV = nil,
	connections = {},
	renderConn = nil,
	lastInteractionTime = 0,
	accumulatedZoom = 0,
	targetPart = nil,
	followTarget = nil,
	followDistance = 0,
	currentMode = nil,
	pinchStartDist = nil,
	twoFingerStart = nil,
	mouseDown = false,
	rightMouseDown = false,
	shiftDown = false,
	lastMousePos = nil,
	closebutton = nil,
	resetbutton = nil,
	fovPlusButton = nil,
	fovMinusButton = nil,
	fovPlusPressed = false,
	fovMinusPressed = false,
	lockbutton = nil,
	lockbuttonstate = false,
	interactingWithDragDetector = false,
	fov = 70,
	panOffset = Vector3.new(0, 0, 0),
	yaw = 0,
	pitch = 0,
	ZoomPosition = 0,
	curFov = 70,
	curYaw = 0,
	curPitch = 0,
	curPanOffset = Vector3.new(0, 0, 0),
	curZoomPosition = 10
}

local function disconnectAll()
	for _, connection in ipairs(v.connections) do
		if connection and connection.Disconnect then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	v.connections = {}

	if v.renderConn then
		pcall(function()
			v.renderConn:Disconnect()
		end)
		v.renderConn = nil
	end
end

local function clamp(p, p2, p3) -- 2 equivalent calls inferred from this helper
	if p < p2 then
		return p2
	end

	return if p3 < p then p3 else p
end

local function isOverDragDetector(p): boolean
	if not p then
		return false
	end

	local screenPointToRay = CurrentCamera:ScreenPointToRay(p.X, p.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	raycastParams.FilterDescendantsInstances = { workspace }

	local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * 1000, raycastParams)

	if not raycastResult then
		return false
	end

	local dragDetector = raycastResult.Instance

	while dragDetector do
		if dragDetector:FindFirstChild("DragDetector") or dragDetector:IsA("DragDetector") then
			return true
		end

		for _, dragDetector2 in ipairs(dragDetector:GetChildren()) do
			if dragDetector2:IsA("DragDetector") then
				return true
			end
		end

		dragDetector = dragDetector.Parent
	end

	return false
end

local function now() -- 8 equivalent calls inferred from this helper
	return tick()
end

local function initYawPitch()
	local eulerAnglesYXZ, yaw, _ = CurrentCamera.CFrame:ToEulerAnglesYXZ()
	v.pitch = eulerAnglesYXZ
	v.yaw = yaw
end
function CameraController.GetActiveInfo()
	return v.active
end

function CameraController:Enter()
	if v.active then
		return
	end

	v.active = true
	v.origCFrame = CurrentCamera.CFrame
	v.origType = CurrentCamera.CameraType
	v.origSubject = CurrentCamera.CameraSubject

	CurrentCamera.CameraType = Enum.CameraType.Scriptable
	v.lastInteractionTime = now() -- inferred equivalent call
	v.closebutton.Visible = v.active
	v.resetbutton.Visible = v.active
	v.lockbutton.Visible = v.active

	if v.fovPlusButton then
		v.fovPlusButton.Visible = v.active
	end

	if v.fovMinusButton then
		v.fovMinusButton.Visible = v.active
	end

	v.renderConn = RunService.RenderStepped:Connect(function(dt)
		if v.fovPlusPressed then
			self:ZoomFOV(30 * dt)
		end

		if v.fovMinusPressed then
			self:ZoomFOV(-30 * dt)
		end

		local v2 = 1 - math.exp(-10 * dt)
		v.curFov += (v.fov - v.curFov) * v2

		CurrentCamera.FieldOfView = v.curFov
		v.curYaw += (v.yaw - v.curYaw) * v2
		v.curPitch += (v.pitch - v.curPitch) * v2
		v.curZoomPosition += (v.ZoomPosition - v.curZoomPosition) * v2
		v.curPanOffset = v.curPanOffset:Lerp(v.panOffset, v2)

		if v.followTarget then
			local position = v.followTarget.Position
			local rotation = v.followTarget.CFrame.Rotation

			local v3 = rotation * (CFrame.Angles(0, v.curYaw, 0) * CFrame.Angles(v.curPitch, 0, 0))

			local vectorToWorldSpace = rotation:VectorToWorldSpace((Vector3.new(
				v.curPanOffset.X,
				v.curPanOffset.Y,
				v.curZoomPosition
			)))

			CurrentCamera.CFrame = CFrame.new(position + vectorToWorldSpace) * v3
		end
	end)
end

function CameraController:Exit(cameraSubject)
	if not v.active then
		return
	end

	disconnectAll()
	CurrentCamera.CameraType = v.origType or Enum.CameraType.Custom

	if cameraSubject then
		CurrentCamera.CameraSubject = cameraSubject
	else
		CurrentCamera.CameraSubject = v.origSubject or nil
	end

	if v.origCFrame then
		CurrentCamera.CFrame = v.origCFrame
	end

	v.active = false
	v.origFOV = nil
	v.currentMode = nil
	v.pinchStartDist = nil
	v.twoFingerStart = nil
	v.lastMousePos = nil
	v.targetPart = nil
	v.closebutton.Visible = v.active
	v.resetbutton.Visible = v.active
	v.lockbutton.Visible = v.active

	if v.fovPlusButton then
		v.fovPlusButton.Visible = v.active
	end

	if v.fovMinusButton then
		v.fovMinusButton.Visible = v.active
	end

	v.fovPlusPressed = false
	v.fovMinusPressed = false
end

function CameraController:ZoomPosition(p)
	v.ZoomPosition = clamp(v.ZoomPosition + -p * 0.2, -50, 50) -- inferred equivalent call
	v.lastInteractionTime = now() -- inferred equivalent call
end

function CameraController:ZoomFOV(p)
	v.fov = math.clamp(v.fov + p, 10, 120)
	v.lastInteractionTime = now() -- inferred equivalent call
end

function CameraController:Pan(p, p2)
	local v2 = -p * 0.005
	local v3 = p2 * 0.005
	v.panOffset += Vector3.new(v2, v3, 0)
	v.lastInteractionTime = now() -- inferred equivalent call
end

function CameraController:OrbitDelta(p, p2)
	v.yaw += p
	v.pitch = math.clamp(v.pitch + p2, -1.5533430342749532, 1.5533430342749532)
	v.lastInteractionTime = now() -- inferred equivalent call
end

function CameraController:OnMouseWheel(p)
	if v.lockbuttonstate then
		return
	end

	local z = p.Position and p.Position.Z or p.Z or 0

	if z == 0 then
		return
	end

	local v2 = -z * 2
	local v3 = z * 2 * 0.5

	if v.shiftDown then
		self:ZoomPosition(v3)
	else
		self:ZoomFOV(v2)
	end
end

function CameraController:OnMouseDown(p, lastMousePos)
	if v.lockbuttonstate then
		return
	end

	if p == Enum.UserInputType.MouseButton2 then
		v.rightMouseDown = true
		v.lastMousePos = lastMousePos
	elseif p == Enum.UserInputType.MouseButton1 then
		v.mouseDown = true
		v.lastMousePos = lastMousePos
	end

	v.lastInteractionTime = now() -- inferred equivalent call
end

function CameraController:OnMouseUp(p)
	if v.lockbuttonstate then
		return
	end

	if p == Enum.UserInputType.MouseButton2 then
		v.rightMouseDown = false
	elseif p == Enum.UserInputType.MouseButton1 then
		v.mouseDown = false
	end

	v.currentMode = nil
	v.lastMousePos = nil
end

function CameraController:OnMouseMove(lastMousePos)
	if v.lockbuttonstate then
		return
	end

	if not v.lastMousePos then
		v.lastMousePos = lastMousePos
		return
	end

	local v2 = lastMousePos.X - v.lastMousePos.X
	local v3 = lastMousePos.Y - v.lastMousePos.Y

	if v.interactingWithDragDetector then
		return
	end

	if v.rightMouseDown then
		if v.shiftDown then
			self:Pan(v2, v3)
			v.currentMode = "pan"
		else
			self:OrbitDelta(-v2 * 0.005, -v3 * 0.005)
		end
	elseif v.mouseDown then
		self:Pan(v2, v3)
		v.currentMode = "pan"
	end

	v.lastMousePos = lastMousePos
	v.lastInteractionTime = now() -- inferred equivalent call
end

function CameraController:OnInputChanged(p)
	if v.lockbuttonstate then
		return
	end

	if p.UserInputType == Enum.UserInputType.MouseMovement then
		self:OnMouseMove(UserInputService:GetMouseLocation())
		return
	end

	if p.UserInputType ~= Enum.UserInputType.MouseWheel then
		return
	end

	self:OnMouseWheel(p)
end

function CameraController:BindInputs()
	disconnectAll()

	table.insert(v.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or v.lockbuttonstate then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local mouseLocation = UserInputService:GetMouseLocation()

			if isOverDragDetector(mouseLocation) then
				v.interactingWithDragDetector = true
				return
			end

			v.interactingWithDragDetector = false
			self:OnMouseDown(input.UserInputType, mouseLocation)
		end

		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			v.shiftDown = true
		end
	end))

	table.insert(v.connections, UserInputService.InputEnded:Connect(function(input, _)
		if v.lockbuttonstate then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			v.interactingWithDragDetector = false
			self:OnMouseUp(input.UserInputType)
		end

		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			v.shiftDown = false
		end

		v.pinchStartDist = nil
		v.twoFingerStart = nil
	end))

	table.insert(v.connections, UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed or v.lockbuttonstate then
			return
		end

		self:OnInputChanged(input)
	end))

	local mouse = LocalPlayer:GetMouse()

	if mouse then
		table.insert(v.connections, mouse.Move:Connect(function()
			if v.lockbuttonstate then
				return
			end

			self:OnMouseMove(UserInputService:GetMouseLocation())
		end))
	end
end

function CameraController.UnbindInputs(_)
	disconnectAll()
end
function CameraController.ResetParameters()
	v.fov = 70
	v.panOffset = Vector3.new(0, 0, 0)
	v.yaw = 0
	v.pitch = 0
	v.ZoomPosition = 0

	v.curFov = 70
	v.curYaw = 0
	v.curPitch = 0
	v.curPanOffset = Vector3.new(0, 0, 0)
	v.curZoomPosition = 10
end

function CameraController:ResetOrientation()
	v.panOffset = Vector3.new(0, 0, 0)
	v.yaw = 0
	v.pitch = 0
	v.ZoomPosition = 0
	v.curPanOffset = Vector3.new(0, 0, 0)
	v.curYaw = 0
	v.curPitch = 0
	v.curZoomPosition = 10
end

function CameraController:ActivateForPart(part)
	if not part then
		return
	end

	local followTarget

	if part:IsA("BasePart") then
		followTarget = part
	end

	if not followTarget then
		return
	end

	v.targetPart = part
	v.followTarget = followTarget

	self:ResetOrientation()
	v.followDistance = 0
	self:BindInputs()
	self:Enter()
end

function CameraController.GetOriginalFOV(_)
	return v.origFOV
end

function CameraController.SetupCloseButton(p)
	local closeButton = script:FindFirstChild("CloseButton")
	local resetButton = script:FindFirstChild("ResetButton")
	local fovPlusButton = script:FindFirstChild("FOVPlusButton")
	local fovMinusButton = script:FindFirstChild("FOVMinusButton")
	local lockButton = script:FindFirstChild("LockButton")

	if closeButton and p then
		v.closebutton = closeButton
		closeButton.Parent = p.MainUi
		closeButton.MouseButton1Click:Connect(function()
			CameraController:Exit()
		end)
	end

	if resetButton and p then
		v.resetbutton = resetButton
		resetButton.Parent = p.MainUi
		resetButton.MouseButton1Click:Connect(function()
			CameraController.ResetParameters()
		end)
	end

	if lockButton and p then
		v.lockbutton = lockButton
		lockButton.Parent = p.MainUi

		local backgroundColor3 = lockButton.BackgroundColor3
		local color = Color3.fromRGB(0, 170, 0)
		lockButton.MouseButton1Click:Connect(function()
			v.lockbuttonstate = not v.lockbuttonstate

			if not v.lockbuttonstate then
				lockButton.BackgroundColor3 = backgroundColor3

				return
			end

			lockButton.BackgroundColor3 = color

			v.mouseDown = false
			v.rightMouseDown = false
			v.lastMousePos = nil
			v.currentMode = nil
			v.pinchStartDist = nil
			v.twoFingerStart = nil
			v.interactingWithDragDetector = false
		end)
	end

	if isOnMobile() then -- inferred equivalent call
		if fovPlusButton and p then
			v.fovPlusButton = fovPlusButton
			fovPlusButton.Parent = p.MainUi
			fovPlusButton.Visible = false

			fovPlusButton.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch then
					v.fovPlusPressed = true
				end
			end)

			fovPlusButton.InputEnded:Connect(function(input, _)
				if input.UserInputType == Enum.UserInputType.Touch then
					v.fovPlusPressed = false
				end
			end)
		end

		if fovMinusButton and p then
			v.fovMinusButton = fovMinusButton
			fovMinusButton.Parent = p.MainUi
			fovMinusButton.Visible = false

			fovMinusButton.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end

				if input.UserInputType == Enum.UserInputType.Touch then
					v.fovMinusPressed = true
				end
			end)

			fovMinusButton.InputEnded:Connect(function(input, _)
				if input.UserInputType == Enum.UserInputType.Touch then
					v.fovMinusPressed = false
				end
			end)
		end
	end
end

function CameraController.SetFOV(_, p)
	CurrentCamera.FieldOfView = clamp(p, 10, 120) -- inferred equivalent call
	v.lastInteractionTime = now() -- inferred equivalent call
end
UserInputService.TouchPinch:Connect(function(list, p, _, p2)
	if v.active and p2 ~= Enum.UserInputState.End and not v.lockbuttonstate then
		if p2 == Enum.UserInputState.Begin then
			if list[1] and isOverDragDetector(list[1]) then
				v.interactingWithDragDetector = true
				return
			end

			v.interactingWithDragDetector = false
		end

		if v.interactingWithDragDetector then
			return
		end

		if p2 == Enum.UserInputState.Change then
			CameraController:ZoomPosition((p - 1) * 0.2)

			v.currentMode = "zoom"
		end
	else
		v.pinchStartDist = nil
		v.interactingWithDragDetector = false
	end
end)

UserInputService.TouchPan:Connect(function(list, _, _, p)
	if v.active and p ~= Enum.UserInputState.End and not v.lockbuttonstate then
		if p == Enum.UserInputState.Begin then
			if list[1] and isOverDragDetector(list[1]) then
				v.interactingWithDragDetector = true
				return
			end

			v.interactingWithDragDetector = false
		end

		if v.interactingWithDragDetector then
			return
		end

		if not v.lastTouchPos then
			v.lastTouchPos = list[1]
			return
		end

		local v2 = list[1].X - v.lastTouchPos.X
		local v3 = list[1].Y - v.lastTouchPos.Y

		if #list == 1 then
			CameraController:OrbitDelta(-v2 * 0.005, -v3 * 0.005)
		end

		if #list == 2 then
			CameraController:Pan(v2 * 0.6, v3 * 0.6)
			v.currentMode = "pan"
		end

		v.lastTouchPos = list[1]
	else
		v.lastTouchPos = nil
		v.currentMode = nil
		v.interactingWithDragDetector = false
	end
end)
return CameraController