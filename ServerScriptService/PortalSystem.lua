local Config = require(script.Parent.Data.GameConfig)

local centralIsland = workspace:FindFirstChild("CentralIsland")
if not centralIsland then
	warn("CentralIsland not found in workspace")
	return
end

for name, data in pairs(Config.Portals) do
	local portal = Instance.new("Part")
	portal.Name = name .. "Portal"
	portal.Size = Vector3.new(6, 10, 1)
	portal.Position = data.Position
	portal.Anchored = true
	portal.CanCollide = false
	portal.BrickColor = data.Unlocked and BrickColor.new("Bright green") or BrickColor.new("Really red")
	portal.Transparency = 0.5
	portal.Parent = centralIsland
	
	if data.Unlocked then
		local click = Instance.new("ClickDetector")
		click.Parent = portal
		
		click.MouseClick:Connect(function(player)
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(data.Destination or Vector3.new(100, 20, 0))
			end
		end)
	end
end
