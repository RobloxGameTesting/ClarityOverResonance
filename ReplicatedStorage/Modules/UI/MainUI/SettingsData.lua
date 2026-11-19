local SettingsData = {}

SettingsData.values = {}

local bindableEvent = Instance.new("BindableEvent")
SettingsData.Changed = bindableEvent.Event

function SettingsData.Set(p, p2, p3)
	if not SettingsData.values[p] then
		SettingsData.values[p] = {}
	end

	local _ = SettingsData.values[p][p2]

	SettingsData.values[p][p2] = p3
	bindableEvent:Fire(p, p2, p3)
end

function SettingsData.Get(p, p2)
	return SettingsData.values[p] and SettingsData.values[p][p2]
end

return SettingsData