local Lighting = game:GetService("Lighting")

local function updateLightingTime()
	while true do
		if game.ReplicatedStorage:WaitForChild("RunTime").Value then
			local v = os.date("*t")
			Lighting.ClockTime = v.hour + v.min / 60
		end

		wait(60)
	end
end

task.spawn(updateLightingTime)