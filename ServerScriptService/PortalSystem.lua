-- PortalSystem: Unlocks portals when player earns enough coins
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

ServerStorage:WaitForChild("GameReady")

local economy = ServerStorage.Economy
local portalsFolder = economy.Portals

local unlockedPortals = {}

local function tryUnlockPortals(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return end

	if not unlockedPortals[player.UserId] then
		unlockedPortals[player.UserId] = {}
	end

	local centralIsland = workspace:FindFirstChild("CentralIsland")
	if not centralIsland then return end

	for _, portalConfig in ipairs(portalsFolder:GetChildren()) do
		local portalName = portalConfig.Name
		local required = portalConfig.RequiredCoins.Value
		local destination = portalConfig.Destination.Value

		if coins.Value >= required and not unlockedPortals[player.UserId][portalName] then
			unlockedPortals[player.UserId][portalName] = true

			local portal = centralIsland:FindFirstChild(portalName .. "Portal")
			if portal then
				portal.Color = Color3.fromRGB(0, 255, 100)

				local click = portal:FindFirstChildOfClass("ClickDetector")
				if not click then
					click = Instance.new("ClickDetector")
					click.MaxActivationDistance = 12
					click.Parent = portal
				end

				click.MouseClick:Connect(function(clickPlayer)
					if clickPlayer == player and clickPlayer.Character then
						clickPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(destination + Vector3.new(0, 5, 0))
					end
				end)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then return end
	local coins = leaderstats:WaitForChild("Coins", 5)
	if not coins then return end

	coins.Changed:Connect(function()
		tryUnlockPortals(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	unlockedPortals[player.UserId] = nil
end)
