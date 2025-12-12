local S = require(script.Parent.services)

local Movement = {}

function Movement.Tween(Target, Speed)
	local Dis = (Target.Position - S.RootPart.Position).Magnitude
	S.TweenService:Create(S.RootPart, TweenInfo.new(Dis / Speed, Enum.EasingStyle.Linear), { CFrame = Target }):Play()
end

return Movement
