local HitboxService = {}
HitboxService.__index = HitboxService

local RunService = game:GetService("RunService")

function HitboxService.new(part, value)
	local self = setmetatable({}, HitboxService)

	self.Part = part
	self.Interval = value or 0.1
	self.IsInside = false
	self.Active = false

	self.OnEntry = nil
	self.OnExit = nil

	return self
end

function HitboxService:Start()
	if self.Active then
		return
	end

	self.Active = true

	local localPlayer = game.Players.LocalPlayer
	local total = 0

	self.Connection = RunService.Heartbeat:Connect(function(dt)
		total += dt

		if total >= self.Interval then
			total = 0

			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				overlapParams.FilterDescendantsInstances = { humanoidRootPart }

				local isInside = #workspace:GetPartBoundsInBox(self.Part.CFrame, self.Part.Size, overlapParams) > 0

				if isInside ~= self.IsInside then
					self.IsInside = isInside

					if self.IsInside then
						if self.OnEntry then
							self.OnEntry()
						end
					elseif self.OnExit then
						self.OnExit()
					end
				end
			end
		end
	end)
end

function HitboxService.CheckOnce(p): boolean
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { humanoidRootPart }

	return #workspace:GetPartBoundsInBox(p.Part.CFrame, p.Part.Size, overlapParams) > 0
end

function HitboxService:Stop()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	self.Active = false
end

return HitboxService