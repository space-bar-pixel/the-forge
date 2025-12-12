local S = require(script.Parent.services)

local Noclip = {}

function Noclip.Enable()
	for _, v in pairs(S.Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end

return Noclip
