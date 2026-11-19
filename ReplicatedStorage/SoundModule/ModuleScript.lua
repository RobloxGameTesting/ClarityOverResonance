local v = {}

local function getSortedBars(instance)
	local parts = {}

	for _, part in ipairs(instance:GetChildren()) do
		if part:IsA("BasePart") and part.Name:match("^S%d+$") then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b): boolean
		return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
	end)

	return parts
end

local function updateBars(sortedBars, p)
	local v2 = #sortedBars

	for i, item in ipairs(sortedBars) do
		if i / v2 <= p then
			item.Material = Enum.Material.Neon
		else
			item.Material = Enum.Material.SmoothPlastic
		end
	end
end

local function disableBars(sortedBars) -- 2 equivalent calls inferred from this helper
	for _, item in ipairs(sortedBars) do
		item.Material = Enum.Material.SmoothPlastic
	end
end

local function handleChannel(instance, p, p2, p3, p4)
	local sortedBars = getSortedBars(instance)
	local fullName = instance:GetFullName()

	local function onChanged()
		if v[fullName] and tick() < v[fullName] then
			return
		end

		if p3.Value then
			local v2 = p.Value * p2

			if not (v2 > 1) then
				updateBars(sortedBars, v2)
				return
			end

			if p4 then
				p4.Value = true
			end

			v[fullName] = tick() + 5
			disableBars(sortedBars) -- inferred equivalent call
		else
			disableBars(sortedBars) -- inferred equivalent call
		end
	end

	p.Changed:Connect(onChanged)

	onChanged()
end

return handleChannel