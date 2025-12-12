local Settings = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/settings.luau"))()
local RocksTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/rocks.luau"))()
local AutoMine = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/features/automine.luau"))()

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "NOOBHUB",
	Icon = "door-open",
	Author = "TEST",
	OpenButton = {
		Title = "Open Example UI",
		Icon = "monitor",
		CornerRadius = UDim.new(0, 16),
		StrokeThickness = 2,
		Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
		OnlyMobile = false,
		Enabled = true,
		Draggable = true,
	},
})

local Tab = Window:Tab({
	Title = "Main",
	Icon = "bird",
})
Tab:Select()

Tab:Dropdown({
	Title = "Select Rocks",
	Values = RocksTable,
	Multi = true,
	AllowNone = true,
	Callback = function(v)
		Settings.SelectRocks = v
	end,
})

Tab:Toggle({
	Title = "Auto Mine",
	Value = false,
	Callback = function(v)
		Settings.AutoMine = v
		if v then
			AutoMine.Start()
		end
	end,
})

Tab:Slider({
	Title = "TweenSpeed",
	Step = 1,
	Value = {
		Min = 1,
		Max = 50,
		Default = Settings.TweenSpeed,
	},
	Callback = function(v)
		Settings.TweenSpeed = v
	end,
})
