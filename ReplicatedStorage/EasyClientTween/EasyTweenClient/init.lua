local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local value = script:WaitForChild("Module", 3.5) and script.Module.Value
	or ReplicatedStorage:WaitForChild("EasyClientTween")

local TickSyncer = require(value:WaitForChild("TickSyncer"))
local value2 = script:WaitForChild("Event", 3) and script.Event.Value or value:WaitForChild("Communicate")

if not value2 then
	return warn("No event found")
end

value2.OnClientEvent:Connect(function(instance, list, goal, p, p2, p3)
	local v = nil
	local _ = TickSyncer:GetTime() - p2

	local tweenInfo = TweenInfo.new(unpack(list))

	local success, _ = pcall(function()
		v = TweenService:Create(instance, tweenInfo, goal)
	end)

	if not (success and v) and p.PrintErrors then
		return warn("Check passed properties for tween: [" .. goal .. "]")
	end

	v:Play()

	local onClientEventConnection = nil
	local function cancelTween(p4)
		if instance == p4 then
			if onClientEventConnection then
				onClientEventConnection:Disconnect()
				onClientEventConnection = nil
			end

			v:Cancel()
			v = nil
		end
	end

	if p3 then
		onClientEventConnection = p3.OnClientEvent:Connect(cancelTween)

		if tweenInfo.RepeatCount >= 0 then
			for _ = 1, 1 + tweenInfo.RepeatCount do
				wait(tweenInfo.Part)
			end

			if onClientEventConnection then
				onClientEventConnection:Disconnect()
				onClientEventConnection = nil
			end
		end
	end
end)