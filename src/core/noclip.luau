local S = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/services.luau"))()

local Noclip = {}

function Noclip.Enable()
	for _, v in pairs(S.Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end

return Noclip
