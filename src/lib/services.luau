local Services = {
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    Players = game:GetService("Players"),
}

Services.LocalPlayer = Services.Players.LocalPlayer
Services.Character = Services.LocalPlayer.Character
Services.RootPart = Services.Character.HumanoidRootPart

return Services
