local S = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/services.luau"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/movement.luau"))()
local Tool = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/tool.luau"))()
local Noclip = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/noclip.luau"))()
local Taiteen = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/taiteen.luau"))()
local Settings = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/settings.luau"))()
local RocksTable = loadstring(game:HttpGet("https://raw.githubusercontent.com/space-bar-pixel/the-forge/main/src/core/rocks.luau"))()

local AutoMine = {}

function AutoMine.Start()
	task.spawn(function()
		while task.wait() do
			if Settings.AutoMine then
				for _, Rocks in pairs(workspace.Rocks:GetChildren()) do
					if not Settings.AutoMine then
						break
					end

					for _, part in pairs(Rocks:GetChildren()) do
						if part:IsA("Part") and part.Name == "SpawnLocation" then
							local Model = part:FindFirstChildOfClass("Model")
							if Model and Model.Parent and table.find(RocksTable, Model.Name) then
								repeat
									task.wait()

									if not Settings.AutoMine then
										workspace.Camera.CameraSubject = S.RootPart
										break
									end

									local HP = tonumber(Model:GetAttribute("Health"))
									if HP <= 0 or not Model.Parent then
										break
									end

									Movement.Tween(Model.Hitbox.CFrame * CFrame.new(0, -4, 0), Settings.TweenSpeed)

									Tool.Pickaxe()
									Noclip.Enable()
									Taiteen.Update()

									if (Model.Hitbox.Position - S.RootPart.Position).Magnitude <= 6 then
										workspace.Camera.CameraSubject = Model.Hitbox
									else
										workspace.Camera.CameraSubject = S.RootPart
									end

								until not Model.Parent or HP <= 0 or not Settings.AutoMine
							end
						end
					end
				end
			end
		end
	end)
end

return AutoMine
