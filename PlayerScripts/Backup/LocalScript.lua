wait(2)
local RunService = game:GetService("RunService")

local descendants = {}

for _, descendant in pairs(workspace.Spotlight:GetDescendants()) do
	table.insert(descendants, descendant)
end

print(descendants)
local Light = workspace.Spotlight.Arm.Head.LensBEAM.AttG.Attachment.Light
local AttT = Light.Parent.Parent.Parent.AttT
local v = Light.Parent.Parent

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function castRay()
	local worldPosition = AttT.WorldPosition
	local v2 = AttT.WorldCFrame.LookVector * 1000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = descendants

	local raycastResult = workspace:Raycast(worldPosition, v2, raycastParams)

	if raycastResult then
		v = raycastResult.Position
	else
		v = worldPosition + v2
	end

	Light.Width1 = 2 + 18 * math.clamp(((AttT.WorldPosition - v.Position).Magnitude - 20) / 980, 0, 1)
end

RunService.RenderStepped:Connect(function()
	castRay()
end)