local color = Color3.fromRGB(255, 0, 0)

return {
	hb = { Label = "High Beam", Color = "HeadlightColor", Range = 60 },
	lb = { Label = "Low Beam", Color = "HeadlightColor", Range = 48 },
	rl = { Label = "Running Light/DRL", Color = "RunningLightColor", Range = 30 },
	fog = { Label = "Fog Light", Color = "FogLightColor", Range = 48 },
	tail = { Label = "Rear / Tail", Color = "RearLightColor", Range = 25, LightColor = color },
	brk = { Label = "Brake", Color = "BrakeLightColor", Range = 38, LightColor = color },
	rev = { Label = "Reverse", Color = "ReverseLightColor", Range = 38 },
	indleft = { Label = "Indicator Left (front/side)", Color = "FrontIndicatorColor", Range = 16 },
	indright = { Label = "Indicator Right (front/side)", Color = "FrontIndicatorColor", Range = 16 },
	rindleft = { Label = "Indicator Left (rear)", Color = "RearIndicatorColor", Range = 16 },
	rindright = { Label = "Indicator Right (rear)", Color = "RearIndicatorColor", Range = 16 },
	plate = { Label = "License Plate", Color = "PlateLightColor", Range = 1 },
	intc = { Label = "Interior Center", Color = "InteriorLightColor", Range = 9 },
	intf = { Label = "Interior Front", Color = "InteriorLightColor", Range = 9 },
	refo = { Label = "Reflector Orange", Color = "OrangeReflectorColor", Range = 0 },
	refr = { Label = "Reflector Red", Color = "RedReflectorColor", Range = 0 }
}