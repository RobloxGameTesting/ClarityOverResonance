local ViewportController = {}
ViewportController.__index = ViewportController

local UserInputService = game:GetService("UserInputService")

function ViewportController.new(viewport, camera)
	local self = setmetatable({}, ViewportController)

	self.Viewport = viewport
	self.Camera = camera

	self.Target = Vector3.new(0, 0, 0)
	self.Distance = 10
	self.Sensitivity = 0.5
	self.ZoomSensitivity = 2

	self.AngleX = 0
	self.AngleY = 0

	self:Init()
	return self
end

function ViewportController:UpdateCamera()
	local cframe = CFrame.fromEulerAnglesYXZ(math.rad(self.AngleY), math.rad(self.AngleX), 0)
	self.Camera.CFrame = CFrame.new(self.Target) * cframe * CFrame.new(0, 0, self.Distance)
	self.Camera.Focus = CFrame.new(self.Target)
end

function ViewportController:Init()
	self.Viewport.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		then
			self.AngleX -= input.Delta.X * self.Sensitivity
			self.AngleY = math.clamp(self.AngleY - input.Delta.Y * self.Sensitivity, -80, 80)
			self:UpdateCamera()
		end
	end)

	self.Viewport.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self.Distance = math.clamp(self.Distance - input.Position.Z * self.ZoomSensitivity, 2, 50)
			self:UpdateCamera()
		end
	end)

	self:UpdateCamera()
end

function ViewportController:SetTarget(target)
	self.Target = target
	self:UpdateCamera()
end

return ViewportController