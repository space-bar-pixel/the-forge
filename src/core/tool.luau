local Tool = {}

function Tool.Pickaxe()
	game:GetService("ReplicatedStorage").Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
		:InvokeServer("Pickaxe")
end

return Tool
