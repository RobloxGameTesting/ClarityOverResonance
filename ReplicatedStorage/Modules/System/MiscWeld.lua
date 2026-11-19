local MiscWeld = {}

function MiscWeld.MakeWeld(p, part, p2, name, maxVelocity)
	local v = p2 == nil and "Weld" or p2
	local instance = Instance.new(v)
	instance.Part0 = p
	instance.Part1 = part
	instance.C0 = p.CFrame:Inverse() * p.CFrame
	instance.C1 = part.CFrame:Inverse() * p.CFrame
	instance.Parent = p

	if v == "Motor" and maxVelocity ~= nil then
		instance.MaxVelocity = maxVelocity
	end

	if name then
		instance.Name = name
	end

	return instance
end

function MiscWeld.ModelWeld(instance, p)
	if instance:IsA("BasePart") then
		MiscWeld.MakeWeld(p, instance, "Weld")
	elseif instance:IsA("Model") then
		for _, child in pairs(instance:GetChildren()) do
			MiscWeld.ModelWeld(child, p)
		end
	end
end
function MiscWeld.FindObject(childName, p, value)
	if not (childName and p) then
		error("err on searhc")
		return nil
	end

	local parent = p.Parent

	for _ = 1, value or 10 do
		if not parent then
			break
		end

		local child = parent:FindFirstChild(childName)

		if child then
			return child
		end

		parent = parent.Parent
	end

	return nil
end

function MiscWeld.FindDriveSeat(instance, value)
	if not instance then
		error("err on find DR")
		return nil
	end

	for _ = 1, value or 7 do
		if instance:FindFirstChild("DriveSeat") then
			return instance.DriveSeat
		end

		instance = instance.Parent
	end

	return nil
end

function MiscWeld.generateRandomName(p)
	local randomName = ""

	for _ = 1, p do
		local v = math.random(1, 62)
		randomName ..= ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"):sub(v, v)
	end

	return randomName
end

return MiscWeld