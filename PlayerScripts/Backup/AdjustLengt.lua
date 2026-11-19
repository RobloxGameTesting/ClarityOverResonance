wait(3)
local RunService = game:GetService("RunService")

local descendants = {}

for _, descendant in pairs(workspace.MovingHeadBeam:GetDescendants()) do
	table.insert(descendants, descendant)
end

local Light = workspace.MovingHeadBeam.Head.Glow.Light
local Start = Light.Parent.Start
local v = Light.Parent.End
local light = Light.Parent.Parent.Light

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function castRay()
	local worldPosition = Start.WorldPosition
	local v2 = Start.WorldCFrame.LookVector * 1000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = descendants

	local raycastResult = workspace:Raycast(worldPosition, v2, raycastParams)

	if raycastResult then
		v.WorldPosition = raycastResult.Position
	else
		v.WorldPosition = worldPosition + v2
	end

	Light.Width1 = 2 + 18 * math.clamp(((Start.WorldPosition - v.WorldPosition).Magnitude - 20) / 980, 0, 1)

	light.Position = v.WorldPosition - Start.WorldCFrame.LookVector * 5
end

RunService.RenderStepped:Connect(function()
	castRay()
end)