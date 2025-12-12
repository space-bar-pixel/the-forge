--# selene: allow(undefined_global)
print("PIZZAHUB LOADING...")

-- ===============================
-- CONFIGURATION MODULES
-- ===============================

-- Config: Settings
getgenv().AutoMine = false
getgenv().SelectRocks = ""
getgenv().TweenSpeed = 50

-- Config: Rocks
local RocksTable = {}

local function InitRocks()
    for name in pairs(game:GetService("ReplicatedStorage").Shared.Data.Ore) do
        table.insert(RocksTable, name)
    end
end

InitRocks()

-- ===============================
-- LIBRARY MODULES
-- ===============================

-- Lib: Services
local Services = {
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
}

Services.LocalPlayer = Services.Players.LocalPlayer
Services.Character = Services.LocalPlayer.Character
Services.RootPart = Services.Character.HumanoidRootPart

-- Lib: Movement
local Movement = {}

function Movement.Tween(Target, Speed)
	local Dis = (Target.Position - Services.RootPart.Position).Magnitude
	Services.TweenService:Create(Services.RootPart, TweenInfo.new(Dis / Speed, Enum.EasingStyle.Linear), { CFrame = Target }):Play()
end

-- Lib: Noclip
local Noclip = {}

function Noclip.Enable()
	for _, v in pairs(Services.Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end

-- Lib: Taiteen
local Taiteen = {}

local part = workspace:FindFirstChild("TaiTeen")

if not part then
	part = Instance.new("Part")
	part.Name = "TaiTeen"
	part.Parent = workspace
	part.Anchored = true
	part.Transparency = 1
	part.Size = Vector3.new(30, 0.5, 30)
end

function Taiteen.Update()
	if Services.RootPart then
		part.CFrame = Services.RootPart.CFrame * CFrame.new(0, -3, 0)
	end
end

-- Lib: Tool
local Tool = {}

function Tool.Pickaxe()
	game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
		:InvokeServer("Pickaxe")
end

-- ===============================
-- FEATURE MODULES
-- ===============================

-- Features: AutoMine
local AutoMine = {}

function AutoMine.Start()
	task.spawn(function()
		while task.wait() do
			if getgenv().AutoMine then
				for _, Rocks in pairs(workspace.Rocks:GetChildren()) do
					if not getgenv().AutoMine then
						break
					end

					for _, part in pairs(Rocks:GetChildren()) do
						if part:IsA("Part") and part.Name == "SpawnLocation" then
							local Model = part:FindFirstChildOfClass("Model")
							if Model and Model.Parent and table.find(RocksTable, Model.Name) then
								repeat
									task.wait()

									if not getgenv().AutoMine then
										workspace.Camera.CameraSubject = Services.RootPart
										break
									end

									local HP = tonumber(Model:GetAttribute("Health"))
									if HP <= 0 or not Model.Parent then
										break
									end

									Movement.Tween(Model.Hitbox.CFrame * CFrame.new(0, -4, 0), getgenv().TweenSpeed)

									Tool.Pickaxe()
									Noclip.Enable()
									Taiteen.Update()

									if (Model.Hitbox.Position - Services.RootPart.Position).Magnitude <= 6 then
										workspace.Camera.CameraSubject = Model.Hitbox
									else
										workspace.Camera.CameraSubject = Services.RootPart
									end

								until not Model.Parent or HP <= 0 or not getgenv().AutoMine
							end
						end
					end
				end
			end
		end
	end)
end

-- ===============================
-- UI MODULES
-- ===============================

-- UI: Menu
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "PIZZAHUB THE FORGE",
	Icon = "door-open",
	Author = "TEST",
	OpenButton = {
		Title = "Open Ai",
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
		getgenv().SelectRocks = v
	end,
})

Tab:Toggle({
	Title = "Auto Mine",
	Value = false,
	Callback = function(v)
		getgenv().AutoMine = v
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
		Default = getgenv().TweenSpeed,
	},
	Callback = function(v)
		getgenv().TweenSpeed = v
	end,
})

print("PIZZAHUB LOADED...")
