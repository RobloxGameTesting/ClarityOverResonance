local DMXType = script.Parent:WaitForChild("DMXType")

local modules = {
	["ClaraS14"] = require(DMXType:WaitForChild("ClaraS14", 10)),
	Blinder_4X100 = require(DMXType:WaitForChild("Blinder_4X100", 10)),
	Parled = require(DMXType:WaitForChild("Parled", 10)),
	STROBE_1000W = require(DMXType:WaitForChild("STROBE_1000W", 10)),
	Windmill_DMX = require(DMXType:WaitForChild("Windmill_DMX", 10)),
	RetroHex_DMX = require(DMXType:WaitForChild("RetroHex_DMX", 10)),
	Wallwasher_24X3W = require(DMXType:WaitForChild("Wallwasher_24X3W", 10)),
	DMX_Flower_180W = require(DMXType:WaitForChild("DMX_Flower_180W", 10)),
	DMX_900W_Fogger = require(DMXType:WaitForChild("DMX_900W_Fogger", 10)),
	DMX_3MappleLeaf = require(DMXType:WaitForChild("DMX_3MappleLeaf", 10)),
	Pixel_Beam_Bar_12x60W = require(DMXType:WaitForChild("Pixel_Beam_Bar_12x60W", 10)),
	StrobeBar_192_Segment = require(DMXType:WaitForChild("StrobeBar_192_Segment", 10)),
	Mini_3LED = require(DMXType:WaitForChild("Mini_3LED", 10))
}

local v = {}
local DMXManager = {}

function DMXManager.RegisterPlayer(p, instance)
	local v2 = { Fixtures = {}, Universes = {}, LastFrames = {}, ZeroBuffers = {} }

	v[p] = v2

	for _, value in ipairs(instance:GetChildren()) do
		if value:IsA("ObjectValue") then
			value = value.Value
		end

		if not (value and value:IsA("Model")) then
			continue
		end

		local boundingBox = value:WaitForChild("BoundingBox", 10)
		local body = value:WaitForChild("Body", 10)

		if not (boundingBox and body) then
			continue
		end

		local typeBox = boundingBox:GetAttribute("TypeBox")

		if not typeBox then
			continue
		end

		local v3 = modules[typeBox]

		if v3 then
			local fixtureChannel = v3.FixtureChannel or v3.Channels

			if type(fixtureChannel) == "number" and not (fixtureChannel <= 0) then
				local channels = math.floor(fixtureChannel)

				if channels > 512 then
					warn("channel melebihi 512", (tostring(typeBox)))
				else
					local dmxAddress = boundingBox:GetAttribute("DMXAddress")
					local dmxUniverse = boundingBox:GetAttribute("DMXUniverse")

					local v4 = type(dmxAddress) ~= "number" and 1 or dmxAddress

					local v5 = type(dmxUniverse) ~= "number" and 1 or dmxUniverse

					local v6 = math.floor(v4)
					local v7 = math.floor(v5)

					local universe = math.clamp(v7, 1, 8)
					local address = math.clamp(v6, 1, 513 - channels)

					if v6 ~= address then
						warn(string.format(
							"DMX address %d '%s' (%d ch) dikoreksi menjadi %d",
							v6,
							typeBox,
							channels,
							address
						))
					end

					if v7 ~= universe then
						warn(string.format("DMX universe %d '%s' dikoreksi menjadi %d", v7, typeBox, universe))
					end

					local v8 = {
						Instance = body,
						Address = address,
						Universe = universe,
						Type = typeBox,
						Channels = channels
					}

					table.insert(v2.Fixtures, v8)

					if not v2.Universes[universe] then
						v2.Universes[universe] = {}
					end

					table.insert(v2.Universes[universe], v8)
				end
			else
				warn("channel gak valid", (tostring(typeBox)))
			end
		else
			warn("fixture gak ketemu", (tostring(typeBox)))
		end
	end

	local count = 0

	for k, univers in pairs(v2.Universes) do
		count += 1
		print(string.format("DMX Universe %d: %d fixture", k, #univers))
	end

	print(string.format("Player %s: %d fixture, %d universe aktif", tostring(p), #v2.Fixtures, count))
end

function DMXManager.Process(p, value, p2)
	local v2 = v[p]

	if not v2 then
		return
	end

	local v3 = typeof(value) == "buffer" and { value } or type(value) ~= "table" and {} or value

	for k, list in pairs(v2.Universes) do
		local v4 = v3[k]

		if typeof(v4) == "buffer" then
			local v5 = buffer.len(v4)
			local buf = buffer.create(v5)
			buffer.copy(buf, 0, v4, 0, v5)

			v2.LastFrames[k] = buf
		else
			v4 = v2.LastFrames[k] or v2.ZeroBuffers[k]

			if not v4 then
				v4 = buffer.create(512)
				v2.ZeroBuffers[k] = v4
			end
		end

		for _, item in ipairs(list) do
			if not (item.Instance and item.Instance.Parent) then
				continue
			end

			local v5 = modules[item.Type]

			if v5 and v5.Update then
				task.spawn(v5.Update, item, v4, p2)
			end
		end
	end
end

function DMXManager.CleanUp(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	for _, fixture in ipairs(v2.Fixtures) do
		if not (fixture.Instance and fixture.Instance.Parent) then
			continue
		end

		local v3 = modules[fixture.Type]

		if v3 and v3.CleanUp then
			task.spawn(v3.CleanUp, fixture)
		end
	end

	v[p] = nil
end

return DMXManager