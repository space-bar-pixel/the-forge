local S = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/lib/services.luau")
)()

local Movement = {}

function Movement.Tween(Target, Speed)
	local Dis = (Target.Position - S.RootPart.Position).Magnitude
	S.TweenService:Create(S.RootPart, TweenInfo.new(Dis / Speed, Enum.EasingStyle.Linear), { CFrame = Target }):Play()
end

return Movement
