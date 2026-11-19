local TransformController = {}
TransformController.__index = TransformController

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local ignoreInstances = {}

local v = {}
local v2 = false
local v3 = { undo = 0, redo = 0 }
v3.undo = {}
v3.redo = {}
local v4 = {}
local v5 = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.IgnoreWater = true

local function shallowClone(attributes) -- 1 equivalent call inferred from this helper
	local result = {}

	for k, item in pairs(attributes) do
		result[k] = item
	end

	return result
end

local function pushHistory(p) -- 3 equivalent calls inferred from this helper
	table.insert(v3.undo, p)

	if #v3.undo > 50 then
		table.remove(v3.undo, 1)
	end

	v3.redo = {}
end

local function recordModelState(instance)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return nil
	end

	local v6 = { CFrame = primaryPart.CFrame, Size = primaryPart.Size, Attributes = {} }

	for k, v7 in pairs(primaryPart:GetAttributes()) do
		v6.Attributes[k] = v7
	end

	local body = instance:FindFirstChild("Body")

	if not body then
		return v6
	end

	v6.Parts = {}

	for _, part in ipairs(body:GetChildren()) do
		if not (part:IsA("BasePart") or part:IsA("MeshPart")) then
			continue
		end

		local parts = v6.Parts
		local name = part.Name
		parts[name] = {
			CFrame = part.CFrame,
			Size = part.Size,
			Attributes = shallowClone(part:GetAttributes()) -- inferred equivalent call
		}
	end

	return v6
end

local function applyModelState(modelRef, instance)
	if not (modelRef and instance) then
		return
	end

	local primaryPart = modelRef.PrimaryPart

	if primaryPart and instance.CFrame then
		primaryPart.CFrame = instance.CFrame
	end

	if primaryPart and instance.Size then
		primaryPart.Size = instance.Size
	end

	if instance.Attributes and primaryPart then
		for k, attribute in pairs(instance.Attributes) do
			primaryPart:SetAttribute(k, attribute)
		end
	end

	local body = instance.Parts and modelRef:FindFirstChild("Body")

	if body then
		for childName, part in pairs(instance.Parts) do
			local child = body:FindFirstChild(childName)

			if not child then
				continue
			end

			if part.CFrame then
				child.CFrame = part.CFrame
			end

			if part.Size then
				child.Size = part.Size
			end

			if not part.Attributes then
				continue
			end

			for k, attribute in pairs(part.Attributes) do
				child:SetAttribute(k, attribute)
			end
		end
	end
end

local function applyAction(data, p) -- 1 equivalent call inferred from this helper
	if data.type == "Delete" then
		if p then
			if data.extra and data.extra.StoredClone then
				data.extra.StoredClone.Parent = data.extra.Parent or workspace
			end
		elseif data.extra and data.extra.StoredClone then
			local storedClone = data.extra.StoredClone

			if storedClone and storedClone.Parent then
				storedClone:Destroy()
			end
		elseif data.modelRef and data.modelRef.Parent then
			data.modelRef:Destroy()
		end
	elseif data.type == "Duplicate" then
		if p then
			if data.extra and data.extra.DuplicateModel and data.extra.DuplicateModel.Parent then
				data.extra.DuplicateModel:Destroy()
			end
		elseif data.extra and data.extra.DuplicateModel then
			data.extra.DuplicateModel.Parent = data.extra.Parent or workspace
		end
	elseif data.modelRef and data.modelRef.Parent then
		if p then
			applyModelState(data.modelRef, data.oldState)
		else
			applyModelState(data.modelRef, data.newState)
		end
	end
end

function TransformController.Undo()
	local v6 = table.remove(v3.undo)

	if not v6 then
		return
	end

	applyAction(v6, true) -- inferred equivalent call
	table.insert(v3.redo, v6)
end

function TransformController.Redo()
	local v6 = table.remove(v3.redo)

	if not v6 then
		return
	end

	applyAction(v6, false)
	table.insert(v3.undo, v6)
end

function TransformController.OnTransformStart(instance, actionType)
	if instance and instance.PrimaryPart then
		v4[instance] = { actionType = actionType, oldState = recordModelState(instance) }
	end
end

function TransformController.OnTransformEnd(instance, value)
	if not (instance and instance.PrimaryPart) then
		return
	end

	local v6 = v4[instance]

	if not v6 then
		return
	end

	local newState = recordModelState(instance)

	if v6.oldState and newState and (v6.oldState.CFrame ~= newState.CFrame or v6.oldState.Size ~= newState.Size) then
		pushHistory({ -- inferred equivalent call
			type = value or "Transform",
			modelRef = instance,
			oldState = v6.oldState,
			newState = newState,
			extra = {}
		})
	end

	v4[instance] = nil
end

function TransformController.DuplicateModel(instance)
	if not instance then
		return
	end

	local clone = instance:Clone()

	local highlight = clone:FindFirstChild("Highlight")

	if highlight then
		highlight:Destroy()
	end

	clone.Parent = instance.Parent or workspace

	pushHistory({ -- inferred equivalent call
		type = "Duplicate",
		modelRef = clone,
		oldState = nil,
		newState = recordModelState(clone),
		extra = { DuplicateModel = clone, Parent = clone.Parent }
	})

	return clone
end

function TransformController.DeleteModel(instance)
	if not instance then
		return
	end

	local clone = instance:Clone()
	clone.Parent = nil
	local parent = instance.Parent

	instance:Destroy()
	pushHistory({ -- inferred equivalent call
		type = "Delete",
		modelRef = instance,
		oldState = nil,
		newState = nil,
		extra = { StoredClone = clone, Parent = parent }
	})
end

local function addToSelection(p)
	if not p then
		return
	end

	v[p] = true

	if TransformController.OnSelectionChanged then
		TransformController.OnSelectionChanged(v)
	end
end

local function removeFromSelection(k) -- 1 equivalent call inferred from this helper
	if not k then
		return
	end

	v[k] = nil

	if TransformController.OnSelectionChanged then
		TransformController.OnSelectionChanged(v)
	end
end

local function clearSelection() -- 4 equivalent calls inferred from this helper
	for k, _ in pairs(v) do
		v[k] = nil
	end

	if TransformController.OnSelectionChanged then
		TransformController.OnSelectionChanged(v)
	end
end

function TransformController.ToggleMultiSelect(p)
	p = p == nil and not v2 or p
	v2 = p

	if TransformController.OnMultiSelectToggled then
		TransformController.OnMultiSelectToggled(v2)
	end
end

function TransformController.SelectByRay(p, p2)
	raycastParams.Blacklist = ignoreInstances
	local raycastResult = workspace:Raycast(p.Position, p2.Unit * 1000, raycastParams)

	if raycastResult and raycastResult.Instance then
		local model = raycastResult.Instance:FindFirstAncestorWhichIsA("Model")

		if model then
			if not v2 then
				clearSelection() -- inferred equivalent call
			end

			if v[model] then
				if not model then
					return model
				end

				v[model] = nil

				if TransformController.OnSelectionChanged then
					TransformController.OnSelectionChanged(v)
					return model
				end
			else
				if not model then
					return model
				end

				v[model] = true

				if TransformController.OnSelectionChanged then
					TransformController.OnSelectionChanged(v)
				end
			end

			return model
		end
	elseif not v2 then
		clearSelection() -- inferred equivalent call
	end

	return nil
end

local lastTime = nil
local vector2 = nil
local heartbeatConnection = nil

local function onTouchStarted(p, p2)
	if p2 then
		return
	end

	lastTime = tick()
	vector2 = Vector2.new(p.Position.X, p.Position.Y)

	heartbeatConnection = RunService.Heartbeat:Connect(function(_)
		if not lastTime then
			return
		end

		if tick() - lastTime >= 2 then
			clearSelection() -- inferred equivalent call

			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			lastTime = nil
		end
	end)
end

local function onTouchEnded(p, _)
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if not lastTime then
		return
	end

	local v6 = tick() - lastTime
	lastTime = nil

	if v6 < 2 then
		local screenPointToRay = workspace.CurrentCamera:ScreenPointToRay(p.Position.X, p.Position.Y)
		TransformController.SelectByRay(screenPointToRay.Origin, screenPointToRay.Direction)
	end
end

local function onMouseButton1Down() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera
	local mouse = LocalPlayer:GetMouse()
	local screenPointToRay = currentCamera:ScreenPointToRay(mouse.X, mouse.Y)
	TransformController.SelectByRay(screenPointToRay.Origin, screenPointToRay.Direction)
end

local function checkDistanceAndDeselect()
	if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local position = LocalPlayer.Character.HumanoidRootPart.Position

	for k, _ in pairs(v) do
		if k and k.PrimaryPart and (position - k.PrimaryPart.Position).Magnitude > 100 then
			removeFromSelection(k) -- inferred equivalent call
		end
	end
end

function TransformController.Init(options)
	local v6 = options or {}

	local ui = v6.Ui
	local handlesFolder = v6.HandlesFolder

	if handlesFolder then
		ignoreInstances = { handlesFolder }
	end

	if v6.IgnoreInstances and type(v6.IgnoreInstances) == "table" then
		for _, ignoreInstance in ipairs(v6.IgnoreInstances) do
			table.insert(ignoreInstances, ignoreInstance)
		end
	end

	if UserInputService.TouchEnabled then
		v5.touchStarted = UserInputService.TouchStarted:Connect(onTouchStarted)
		v5.touchEnded = UserInputService.TouchEnded:Connect(onTouchEnded)
	else
		v5.mouseDown = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				onMouseButton1Down() -- inferred equivalent call
			end
		end)
	end

	v5.heartbeat = RunService.Heartbeat:Connect(checkDistanceAndDeselect)

	if ui then
		if ui.UndoButton then
			ui.UndoButton.MouseButton1Click:Connect(function()
				TransformController.Undo()
			end)
		end

		if ui.RedoButton then
			ui.RedoButton.MouseButton1Click:Connect(function()
				TransformController.Redo()
			end)
		end

		if ui.MultiSelectToggle then
			ui.MultiSelectToggle.MouseButton1Click:Connect(function()
				TransformController.ToggleMultiSelect()
				ui.MultiSelectToggle.BackgroundColor3 = v2 and Color3.fromRGB(114, 218, 45)
					or Color3.fromRGB(104, 104, 104)
			end)
		end
	end
end

function TransformController.Cleanup()
	for k, connection in pairs(v5) do
		if connection and connection.Disconnect then
			connection:Disconnect()
		end

		v5[k] = nil
	end

	clearSelection() -- inferred equivalent call
	v3 = { undo = {}, redo = {} }
	v4 = {}
end

function TransformController.GetSelection()
	local selection = {}

	for k, _ in pairs(v) do
		table.insert(selection, k)
	end

	return selection
end

function TransformController.IsMultiSelectEnabled()
	return v2
end

return TransformController