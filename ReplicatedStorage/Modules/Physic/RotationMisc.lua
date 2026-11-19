local function getRotationDelta(lastDragCF, dragFrame) -- 1 equivalent call inferred from this helper
	if not (lastDragCF and dragFrame) then
		return 0
	end

	local axisAngle, v = (lastDragCF:Inverse() * dragFrame):ToAxisAngle()

	if typeof(axisAngle) == "Vector3" then
		return v * (axisAngle.X >= 0 and 1 or -1)
	end

	return 0
end

return {
	initPot = function(self, min, max, object)
		local dragDetector = self.hitbox:WaitForChild("DragDetector")

		dragDetector.DragStart:Connect(function()
			self.lastDragCF = dragDetector.DragFrame
		end)

		dragDetector.DragContinue:Connect(function()
			local dragFrame = dragDetector.DragFrame

			if not (dragFrame and self.lastDragCF) then
				return
			end

			local rotationDelta = getRotationDelta(self.lastDragCF, dragFrame) -- inferred equivalent call
			self.lastDragCF = dragFrame

			self.currentAngle = math.clamp(self.currentAngle + rotationDelta, min, max)
			local cframe = CFrame.Angles(self.currentAngle, 0, 0)
			self.weld.C1 = cframe

			local v = math.clamp((self.currentAngle - min) / (max - min), 0, 1)

			if not self._cooldown then
				self._cooldown = true
				task.delay(0.05, function()
					object:FireServer(self.Output, v, self.weld, cframe)
					self._cooldown = false
				end)
			end
		end)

		dragDetector.DragEnd:Connect(function()
			self.lastDragCF = nil
		end)
	end
}