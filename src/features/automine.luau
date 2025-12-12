local S = require(script.Parent.Parent.lib.services)
local Movement = require(script.Parent.Parent.lib.movement)
local Tool = require(script.Parent.Parent.lib.tool)
local Noclip = require(script.Parent.Parent.lib.noclip)
local Taiteen = require(script.Parent.Parent.lib.taiteen)
local Settings = getgenv()
local RocksTable = require(script.Parent.Parent.config.rocks)

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
