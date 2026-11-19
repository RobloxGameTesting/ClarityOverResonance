require(script.Parent.Parent.Types)

return function(p, data)
	local v = {
		hasState = false,
		hasChildren = false,
		Args = {
			Image = 1,
			Size = 2,
			Rect = 3,
			ScaleType = 4,
			ResampleMode = 5,
			TileSize = 6,
			SliceCenter = 7,
			SliceScale = 8
		},
		Discard = function(p2)
			p2.Instance:Destroy()
		end
	}

	p.WidgetConstructor("Image", data.extend(v, {
		Events = {
			hovered = data.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local iris_Image = Instance.new("ImageLabel")
			iris_Image.Name = "Iris_Image"
			iris_Image.BackgroundTransparency = 1
			iris_Image.BorderSizePixel = 0
			iris_Image.ImageColor3 = p._config.ImageColor
			iris_Image.ImageTransparency = p._config.ImageTransparency
			iris_Image.LayoutOrder = p2.ZIndex

			data.applyFrameStyle(iris_Image, true)

			return iris_Image
		end,
		Update = function(p2)
			local instance = p2.Instance

			instance.Image = p2.arguments.Image or data.ICONS.UNKNOWN_TEXTURE
			instance.Size = p2.arguments.Size

			if p2.arguments.ScaleType then
				instance.ScaleType = p2.arguments.ScaleType

				if p2.arguments.ScaleType == Enum.ScaleType.Tile and p2.arguments.TileSize then
					instance.TileSize = p2.arguments.TileSize
				elseif p2.arguments.ScaleType == Enum.ScaleType.Slice then
					if p2.arguments.SliceCenter then
						instance.SliceCenter = p2.arguments.SliceCenter
					end

					if p2.arguments.SliceScale then
						instance.SliceScale = p2.arguments.SliceScale
					end
				end
			end

			if p2.arguments.Rect then
				instance.ImageRectOffset = p2.arguments.Rect.Min
				instance.ImageRectSize = Vector2.new(p2.arguments.Rect.Width, p2.arguments.Rect.Height)
			end

			if p2.arguments.ResampleMode then
				instance.ResampleMode = p2.arguments.ResampleMode
			end
		end
	}))

	p.WidgetConstructor("ImageButton", data.extend(v, {
		Events = {
			["clicked"] = data.EVENTS.click(function(p2)
				return p2.Instance
			end),
			rightClicked = data.EVENTS.rightClick(function(p2)
				return p2.Instance
			end),
			doubleClicked = data.EVENTS.doubleClick(function(p2)
				return p2.Instance
			end),
			ctrlClicked = data.EVENTS.ctrlClick(function(p2)
				return p2.Instance
			end),
			hovered = data.EVENTS.hover(function(p2)
				return p2.Instance
			end)
		},
		Generate = function(p2)
			local iris_ImageButton = Instance.new("ImageButton")
			iris_ImageButton.Name = "Iris_ImageButton"
			iris_ImageButton.AutomaticSize = Enum.AutomaticSize.XY
			iris_ImageButton.BackgroundColor3 = p._config.FrameBgColor
			iris_ImageButton.BackgroundTransparency = p._config.FrameBgTransparency
			iris_ImageButton.BorderSizePixel = 0
			iris_ImageButton.Image = ""
			iris_ImageButton.ImageTransparency = 1
			iris_ImageButton.LayoutOrder = p2.ZIndex
			iris_ImageButton.AutoButtonColor = false

			data.applyFrameStyle(iris_ImageButton, true)
			data.UIPadding(iris_ImageButton, Vector2.new(p._config.ImageBorderSize, p._config.ImageBorderSize))

			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "ImageLabel"
			imageLabel.BackgroundTransparency = 1
			imageLabel.BorderSizePixel = 0
			imageLabel.ImageColor3 = p._config.ImageColor
			imageLabel.ImageTransparency = p._config.ImageTransparency
			imageLabel.Parent = iris_ImageButton

			data.applyInteractionHighlights("Background", iris_ImageButton, iris_ImageButton, {
				Color = p._config.FrameBgColor,
				Transparency = p._config.FrameBgTransparency,
				HoveredColor = p._config.FrameBgHoveredColor,
				HoveredTransparency = p._config.FrameBgHoveredTransparency,
				ActiveColor = p._config.FrameBgActiveColor,
				ActiveTransparency = p._config.FrameBgActiveTransparency
			})

			return iris_ImageButton
		end,
		Update = function(p2)
			local imageLabel = p2.Instance.ImageLabel

			imageLabel.Image = p2.arguments.Image or data.ICONS.UNKNOWN_TEXTURE
			imageLabel.Size = p2.arguments.Size

			if p2.arguments.ScaleType then
				imageLabel.ScaleType = p2.arguments.ScaleType

				if p2.arguments.ScaleType == Enum.ScaleType.Tile and p2.arguments.TileSize then
					imageLabel.TileSize = p2.arguments.TileSize
				elseif p2.arguments.ScaleType == Enum.ScaleType.Slice then
					if p2.arguments.SliceCenter then
						imageLabel.SliceCenter = p2.arguments.SliceCenter
					end

					if p2.arguments.SliceScale then
						imageLabel.SliceScale = p2.arguments.SliceScale
					end
				end
			end

			if p2.arguments.Rect then
				imageLabel.ImageRectOffset = p2.arguments.Rect.Min
				imageLabel.ImageRectSize = Vector2.new(p2.arguments.Rect.Width, p2.arguments.Rect.Height)
			end

			if p2.arguments.ResampleMode then
				imageLabel.ResampleMode = p2.arguments.ResampleMode
			end
		end
	}))
end