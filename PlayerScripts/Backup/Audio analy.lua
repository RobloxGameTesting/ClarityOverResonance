local audioAnalyzer = game.Workspace:WaitForChild("Emmitaudio"):WaitForChild("AudioAnalyzer")

local v = {}
local v2 = {}

for i = 1, 100 do
	table.insert(v, game.Workspace.FolderBarUtama:WaitForChild("Bar" .. i))
	table.insert(v2, game.Workspace.FolderBarPeak:WaitForChild("Bar" .. i))
end

local function updateBars()
	local spectrum = audioAnalyzer:GetSpectrum()

	for i, v3 in ipairs(spectrum) do
		local v4 = v[i]
		local v5 = v2[i]

		if not (v4 and v5) then
			continue
		end

		local v6 = math.clamp(v3 * 20, 0.2, 10)
		v4.Size = Vector3.new(v4.Size.X, v6, v4.Size.Z)
		v4.Position = Vector3.new(v4.Position.X, v6 / 2, v4.Position.Z)

		if v5.Position.Y < v4.Position.Y + v6 / 2 then
			v5.Position = Vector3.new(v5.Position.X, v4.Position.Y + v6 / 2 + 1, v5.Position.Z)
		else
			v5.Position = Vector3.new(v5.Position.X, v5.Position.Y - 0.1, v5.Position.Z)
		end
	end
end

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(updateBars)