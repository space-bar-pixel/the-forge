local S = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/services.luau"))()

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
	if S.RootPart then
		part.CFrame = S.RootPart.CFrame * CFrame.new(0, -3, 0)
	end
end

return Taiteen
