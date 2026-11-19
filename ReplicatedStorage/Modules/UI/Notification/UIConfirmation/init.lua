game:GetService("Players")
local Promise = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("System"):WaitForChild("Promise"))

local ConfFrame = script:WaitForChild("ConfFrame")

local v = {}
local flag = false

local function processRequest(data) -- 1 equivalent call inferred from this helper
	return Promise.new(function(callback)
		local clone = ConfFrame:Clone()
		clone.Visible = true
		clone.Parent = data.parent

		clone.Title.Text = data.title
		clone.Desc.Text = data.description

		local mouseButton1ClickConnection = nil
		local mouseButton1ClickConnection2 = nil

		local function cleanup() -- 2 equivalent calls inferred from this helper
			mouseButton1ClickConnection:Disconnect()
			mouseButton1ClickConnection2:Disconnect()
			clone:Destroy()
		end

		mouseButton1ClickConnection = clone.YesButton.MouseButton1Click:Connect(function()
			cleanup() -- inferred equivalent call
			callback(true)
		end)

		mouseButton1ClickConnection2 = clone.NoButton.MouseButton1Click:Connect(function()
			cleanup() -- inferred equivalent call
			callback(false)
		end)
	end)
end

local function runQueue()
	if flag then
		return
	end

	flag = true

	while #v > 0 do
		local v2 = table.remove(v, 1)

		processRequest(v2):andThen(function(p) -- inferred equivalent call
			v2.resolve(p)
		end)
	end

	flag = false
end

return {
	Ask = function(_, title, description, parent)
		assert(parent, "Parent harus diberikan")

		return Promise.new(function(resolve)
			table.insert(v, {
				title = title,
				description = description,
				parent = parent,
				resolve = resolve
			})

			runQueue()
		end)
	end
}