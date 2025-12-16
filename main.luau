--# selene: allow(undefined_global)
--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                      PIZZAHUB THE FORGE                       ║
    ╠═══════════════════════════════════════════════════════════════╣
    ║  Structure:                                                   ║
    ║    1. SERVICES      - Game services                           ║
    ║    2. CONFIG        - Global settings                         ║
    ║    3. DATA          - Dynamic data (rocks, mobs, tools)       ║
    ║    4. LIBRARIES     - Utility modules                         ║
    ║    5. FEATURES      - Feature modules (AutoMine, AutoMod)     ║
    ║    6. UI            - User interface                          ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

print("PIZZAHUB LOADING...")

--------------------------------------------------------------------------------
-- LOADING SCREEN (from mainUi)
--------------------------------------------------------------------------------

local WindUI
do
    local ok, result = pcall(function()
        return require("./mainUi")
    end)
    
    if ok then
        WindUI = result
    else 
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/mainUi.luau"))()
    end
end

local LoadingScreen = WindUI.LoadingScreen:Create()

local function UpdateProgress(percent, statusText)
    LoadingScreen:Update(percent, statusText)
end

UpdateProgress(0, "Starting...")

--------------------------------------------------------------------------------
-- [1] SERVICES
--------------------------------------------------------------------------------

UpdateProgress(5, "Loading Services...")

local Services = {
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
}

Services.LocalPlayer = Services.Players.LocalPlayer
Services.Character = Services.LocalPlayer.Character or Services.LocalPlayer.CharacterAdded:Wait()
Services.RootPart = Services.Character:WaitForChild("HumanoidRootPart")
Services.Humanoid = Services.Character:WaitForChild("Humanoid")

-- Store feature states to restore after respawn
local SavedStates = {
    AutoMine = false,
    AutoMod = false,                                            
}

-- Forward reference for movement stop (defined in Lib section)
local StopAllMovement = nil

-- Function to reset camera (always gets fresh humanoid reference)
local function ResetCamera()
    local char = Services.LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            workspace.Camera.CameraSubject = humanoid
        end
    end
end

-- Function to handle death
local function OnDeath()
    SavedStates.AutoMine = getgenv().AutoMine
    SavedStates.AutoMod = getgenv().AutoMod
    
    -- Stop movement tween
    if StopAllMovement then
        StopAllMovement()
    end
    
    ResetCamera()
end

-- Handle character respawn
local function OnCharacterAdded(char)
    Services.Character = char
    Services.RootPart = char:WaitForChild("HumanoidRootPart")
    Services.Humanoid = char:WaitForChild("Humanoid")
    
    -- Stop any active movement
    if StopAllMovement then
        StopAllMovement()
    end
    
    -- Reset camera
    ResetCamera()
    
    -- Restore saved states after small delay for character to fully load
    task.delay(0.5, function()
        getgenv().AutoMine = SavedStates.AutoMine
        getgenv().AutoMod = SavedStates.AutoMod
    end)
    
    -- Handle death
    Services.Humanoid.Died:Connect(OnDeath)
end

-- Connect respawn handler
Services.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Handle death for current character
if Services.Humanoid then
    Services.Humanoid.Died:Connect(OnDeath)
end

UpdateProgress(15, "Loaded Services")

--------------------------------------------------------------------------------
-- [2] CONFIG
-- Add new settings here - they will be available via getgenv()
--------------------------------------------------------------------------------

local Config = {
    AutoMine = false,
    AutoMod = false,
    AutoDodge = false,
    SelectTools = "",
    SelectRocks = {},
    SelectMods = {},
    TweenSpeed = 50,
}

-- Apply config to global environment
for key, value in pairs(Config) do
    getgenv()[key] = value
end

UpdateProgress(20, "Loaded Configuration")

--------------------------------------------------------------------------------
-- [3] DATA
-- Tables that store dynamic game data
--------------------------------------------------------------------------------

local Data = {
    Rocks = {},
    RocksSet = {},
    Mods = {},
    ModsSet = {},
    Tools = {},
}

-- Initialize Rocks Data
local function InitRocks()
    table.clear(Data.Rocks)
    table.clear(Data.RocksSet)

    for _, island in pairs(workspace.Rocks:GetChildren()) do
        for _, rocks in pairs(island:GetChildren()) do
            for _, rock in pairs(rocks:GetChildren()) do
                if rock:IsA("Model") and rock:FindFirstChild("Hitbox") then
                    if not Data.RocksSet[rock.Name] then
                        Data.RocksSet[rock.Name] = true
                        table.insert(Data.Rocks, rock.Name)
                    end
                end
            end
        end
    end
end

-- Initialize Mods Data
local function InitMods()
    table.clear(Data.Mods)
    table.clear(Data.ModsSet)

    for _, model in pairs(workspace.Living:GetChildren()) do
        if model:IsA("Model")
            and model:FindFirstChild("HumanoidRootPart")
            and not Services.Players:GetPlayerFromCharacter(model) then

            local cleanName = model.Name:gsub("%d+$", "")
            if not Data.ModsSet[cleanName] then
                Data.ModsSet[cleanName] = true
                table.insert(Data.Mods, cleanName)
            end
        end
    end
end

-- Initialize Tools Data
local function InitTools()
    table.clear(Data.Tools)

    local toolsFrame = Services.LocalPlayer.PlayerGui
        .Menu.Frame.Frame.Menus.Tools.Frame

    for _, slot in pairs(toolsFrame:GetChildren()) do
        if slot.Name == "EmptySlot" then continue end
        if slot:IsA("Frame") then
            local viewport = slot:FindFirstChild("ViewportFrame")
            if viewport then
                for _, obj in pairs(viewport:GetChildren()) do
                    if obj:IsA("Model") then
                        table.insert(Data.Tools, obj.Name)
                    end
                end
            end
        end
    end
end

-- Run initializers
InitRocks()
InitMods()
InitTools()

UpdateProgress(30, "Loaded Data")

--------------------------------------------------------------------------------
-- [4] LIBRARIES
-- Reusable utility modules
--------------------------------------------------------------------------------

local Lib = {}

--[[ Helper Functions ]]--
Lib.Helper = {}

function Lib.Helper.Map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

--[[ Noclip ]]--
Lib.Noclip = {}

function Lib.Noclip.Enable()
    for _, v in pairs(Services.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

--[[ Taiteen - Ground Part ]]--
Lib.Taiteen = {}

do
    local part = workspace:FindFirstChild("UnderFeetPart")
    if not part then
        part = Instance.new("Part")
        part.Name = "UnderFeetPart"
        part.Parent = workspace
        part.Anchored = true
        part.Transparency = 1
        part.Size = Vector3.new(30, 0.5, 30)
    end
    Lib.Taiteen._part = part
end

function Lib.Taiteen.Update()
    if Services.RootPart then
        Lib.Taiteen._part.CFrame = Services.RootPart.CFrame * CFrame.new(0, -3, 0)
    end
end

--[[ Movement ]]--
Lib.Movement = {
    _activeTween = nil,
}

function Lib.Movement.Tween(TargetCF, Speed)
    -- Cancel previous tween if exists
    if Lib.Movement._activeTween then
        Lib.Movement._activeTween:Cancel()
    end
    
    local pos = TargetCF.Position
    local dis = (pos - Services.RootPart.Position).Magnitude
    local tween = Services.TweenService:Create(
        Services.RootPart,
        TweenInfo.new(dis / Speed, Enum.EasingStyle.Linear),
        { CFrame = TargetCF }
    )
    Lib.Noclip.Enable()
    tween:Play()
    Lib.Movement._activeTween = tween
    return tween
end

function Lib.Movement.Stop()
    if Lib.Movement._activeTween then
        Lib.Movement._activeTween:Cancel()
        Lib.Movement._activeTween = nil
    end
end

-- Assign forward reference for death/respawn handlers
StopAllMovement = Lib.Movement.Stop

--[[ Tool Activation ]]--
Lib.Tool = {}

local ToolServiceRF = Services.ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF

function Lib.Tool.Pickaxe()
    ToolServiceRF.ToolActivated:InvokeServer("Pickaxe")
end

function Lib.Tool.Weapon()
    ToolServiceRF.ToolActivated:InvokeServer("Weapon")
end

UpdateProgress(45, "Loaded Libraries")

--------------------------------------------------------------------------------
-- [5] FEATURES
-- Add new features here following the template
--------------------------------------------------------------------------------

local Features = {}

--[[ 
    FEATURE TEMPLATE:
    
    Features.YourFeature = {
        _running = false,
    }
    
    function Features.YourFeature.Start()
        Features.YourFeature._running = true
        task.spawn(function()
            while Features.YourFeature._running do
                -- Your logic here
                task.wait()
            end
        end)
    end
    
    function Features.YourFeature.Stop()
        Features.YourFeature._running = false
    end
]]--

--[[ AutoMine Feature ]]--
Features.AutoMine = {
    _running = false,
}

function Features.AutoMine.GetNearestRock()
    local nearest = nil
    local nearestDist = math.huge

    for _, island in pairs(workspace.Rocks:GetChildren()) do
        for _, rocks in pairs(island:GetChildren()) do
            for _, rock in pairs(rocks:GetChildren()) do
                if rock:IsA("Model") and rock:FindFirstChild("Hitbox") then
                    -- Filter by selected rocks
                    if #getgenv().SelectRocks > 0 and
                        not table.find(getgenv().SelectRocks, rock.Name) then
                        continue
                    end

                    local HP = tonumber(rock:GetAttribute("Health"))
                    if not HP or HP <= 0 then continue end

                    local dist = (rock.Hitbox.Position - Services.RootPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = rock
                    end
                end
            end
        end
    end

    return nearest
end

function Features.AutoMine.Start()
    Features.AutoMine._running = true
    
    task.spawn(function()
        local currentRock = nil

        while Features.AutoMine._running do
            task.wait()

            if not getgenv().AutoMine then
                currentRock = nil
                ResetCamera()
                continue
            end

            local nearest = Features.AutoMine.GetNearestRock()
            if not nearest then
                currentRock = nil
                continue
            end

            if currentRock ~= nearest then
                currentRock = nearest
            end

            if not currentRock or not currentRock.Parent then
                currentRock = nil
                continue
            end

            local Hitbox = currentRock.Hitbox
            Lib.Movement.Tween(Hitbox.CFrame * CFrame.new(0, 0, 3), getgenv().TweenSpeed)
            Lib.Tool.Pickaxe()
            Lib.Noclip.Enable()

            if (Hitbox.Position - Services.RootPart.Position).Magnitude <= 6 then
                workspace.Camera.CameraSubject = Hitbox
            else
                workspace.Camera.CameraSubject = Services.RootPart
            end
        end
    end)
end

function Features.AutoMine.Stop()
    Features.AutoMine._running = false
    Lib.Movement.Stop()
    ResetCamera()
end

--[[ AutoMod Feature ]]--
Features.AutoMod = {
    _running = false,
    _currentTarget = nil,
    _cameraLocked = false,
}

function Features.AutoMod.GetNearestMod()
    local nearest = nil
    local nearestDist = math.huge

    for _, model in pairs(workspace.Living:GetChildren()) do
        if model:IsA("Model")
            and model:FindFirstChild("HumanoidRootPart")
            and not Services.Players:GetPlayerFromCharacter(model) then

            local cleanName = model.Name:gsub("%d+$", "")
            
            -- Filter by selected mods
            if #getgenv().SelectMods > 0 and
                not table.find(getgenv().SelectMods, cleanName) then
                continue
            end

            -- Check if mob is alive (has Humanoid with health > 0)
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                continue
            end

            local dist = (model.HumanoidRootPart.Position - Services.RootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = model
            end
        end
    end

    return nearest
end

function Features.AutoMod.Start()
    Features.AutoMod._running = true
    Features.AutoMod._cameraLocked = false
    print("AutoMod Started")
    
    task.spawn(function()
        while Features.AutoMod._running do
            task.wait()
            
            -- Check if disabled - reset camera immediately
            if not getgenv().AutoMod then
                Features.AutoMod._currentTarget = nil
                if Features.AutoMod._cameraLocked then
                    Features.AutoMod._cameraLocked = false
                    ResetCamera()
                end
                continue
            end

            local nearest = Features.AutoMod.GetNearestMod()
            if not nearest then
                Features.AutoMod._currentTarget = nil
                if Features.AutoMod._cameraLocked then
                    Features.AutoMod._cameraLocked = false
                    ResetCamera()
                end
                continue
            end

            -- Update current target
            if Features.AutoMod._currentTarget ~= nearest then
                Features.AutoMod._currentTarget = nearest
            end

            -- Validate target still exists
            if not Features.AutoMod._currentTarget or not Features.AutoMod._currentTarget.Parent then
                Features.AutoMod._currentTarget = nil
                continue
            end

            local targetPart = Features.AutoMod._currentTarget:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local dist = (targetPart.Position - Services.RootPart.Position).Magnitude
                
                -- Auto Dodge: Move under feet when close to avoid attacks
                if getgenv().AutoDodge and dist <= 15 then
                    Lib.Taiteen.Update()
                    Lib.Movement.Tween(targetPart.CFrame * CFrame.new(0, -6, 0), getgenv().TweenSpeed)
                else
                    Lib.Movement.Tween(targetPart.CFrame * CFrame.new(0, 0, 3), getgenv().TweenSpeed)
                end
                
                Lib.Tool.Weapon()
                Lib.Noclip.Enable()

                -- Camera follows target when close
                if dist <= 10 then
                    Features.AutoMod._cameraLocked = true
                    workspace.Camera.CameraSubject = targetPart
                else
                    if Features.AutoMod._cameraLocked then
                        Features.AutoMod._cameraLocked = false
                        ResetCamera()
                    end
                end
            end
        end
    end)
end

function Features.AutoMod.Stop()
    Features.AutoMod._running = false
    Features.AutoMod._currentTarget = nil
    Features.AutoMod._cameraLocked = false
    Lib.Movement.Stop()
    ResetCamera()
    print("AutoMod Stopped")
end

UpdateProgress(65, "Loaded Features")

--------------------------------------------------------------------------------
-- [6] UI
-- Window, Tabs, and Controls
--------------------------------------------------------------------------------

UpdateProgress(75, "Loading UI...")

local UI = {}

-- Create Window
UI.Window = WindUI:CreateWindow({
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

UI.Window:SetToggleKey(Enum.KeyCode.H)

UpdateProgress(80, "Creating Tabs...")

--------------------------------------------------------------------------------
-- [6.1] TABS
-- Add new tabs here
--------------------------------------------------------------------------------

UI.Tabs = {}

--[[ Main Tab ]]--
UI.Tabs.Main = UI.Window:Tab({
    Title = "Main",
    Icon = "bird",
})
UI.Tabs.Main:Select()

--[[ Teleport Tab ]]--
UI.Tabs.Teleport = UI.Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
})

UpdateProgress(85, "Creating Controls...")

--------------------------------------------------------------------------------
-- [6.2] CONTROLS
-- Add UI controls for each tab
--------------------------------------------------------------------------------

UI.Controls = {}

--[[ Main Tab Controls ]]--

UI.Controls.SelectRocksDropdown = UI.Tabs.Main:Dropdown({
    Title = "Select Rocks",
    Values = Data.Rocks,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        getgenv().SelectRocks = v
    end,
})

UI.Controls.AutoMineToggle = UI.Tabs.Main:Toggle({
    Title = "Auto Mine",
    Value = false,
    Callback = function(v)
        getgenv().AutoMine = v
        if v then
            Features.AutoMine.Start()
        else
            Features.AutoMine.Stop()
        end
    end,
})

UI.Controls.TweenSpeedSlider = UI.Tabs.Main:Slider({
    Title = "TweenSpeed",
    Step = 1,
    Value = {
        Min = 1,
        Max = 100,
        Default = getgenv().TweenSpeed,
    },
    Callback = function(v)
        v = Lib.Helper.Map(v, 1, 100, 1, 70)
        getgenv().TweenSpeed = v
    end,
})

UI.Controls.SelectModsDropdown = UI.Tabs.Main:Dropdown({
    Title = "Select Mods",
    Values = Data.Mods,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        getgenv().SelectMods = v
    end,
})

UI.Controls.AutoModToggle = UI.Tabs.Main:Toggle({
    Title = "Auto Kill Mods",
    Value = false,
    Callback = function(v)
        getgenv().AutoMod = v
        if v then
            Features.AutoMod.Start()
        else
            Features.AutoMod.Stop()
        end
    end,
})

UI.Controls.AutoDodgeToggle = UI.Tabs.Main:Toggle({
    Title = "Auto Dodge",
    Desc = "Move under mobs feet to avoid attacks",
    Value = false,
    Callback = function(v)
        getgenv().AutoDodge = v
    end,
})

UpdateProgress(92, "Creating Teleport Buttons...")

--------------------------------------------------------------------------------
-- [6.3] TELEPORT LOCATIONS
-- Add new teleport locations here easily
--------------------------------------------------------------------------------

local TeleportLocations = {
    { Name = "The Forge", Desc = "Teleport To The Forge Button", Position = CFrame.new(-192.859421, 29.473900, 161.837708) },
    { Name = "Maria's Shop", Desc = "Teleport To The Maria's Shop (Buy Potion)", Position =  CFrame.new(-153.684372, 27.992077, 116.789757)},
    { Name = "Miner Fred's Shop", Desc = "Teleport To The Miner Fred's Shop (Buy Pickaxe)", Position =  CFrame.new(-90.084885, 28.556253, 93.203156)},
    { Name = "Marbles's Shop", Desc = "Teleport To The Marbles's Shop (Sell Weapon)", Position =  CFrame.new(-180.319489, 28.606251, 14.146764)},
    { Name = "Enchancer", Desc = "Teleport To The Enchancer (Enchance Your Tool)", Position =  CFrame.new(-259.868988, 19.755627, 33.584000)},
    { Name = "Rune Maker", Desc = "Teleport To The Rune Maker", Position =  CFrame.new(-271.891724, 20.315151, 143.179520)},
}

-- Auto-generate teleport buttons from table
for _, loc in ipairs(TeleportLocations) do
    UI.Tabs.Teleport:Button({
        Title = loc.Name,
        Desc = loc.Desc or "Teleport to " .. loc.Name,
        Locked = false,
        Callback = function()
            Lib.Movement.Tween(loc.Position, 70)
        end,
    })
end

UpdateProgress(100, "Loaded")

--------------------------------------------------------------------------------
-- DONE
--------------------------------------------------------------------------------

print("PIZZAHUB LOADED...")
