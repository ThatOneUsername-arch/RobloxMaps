local Config = require(script.Parent.Data.GameConfig)
local Players = game:GetService("Players")
local SoundSystem = require(game.ReplicatedStorage.SoundSystem)

local unlockedPortals = {}
local portalClickConnections = {}

local function checkPortalUnlock(player)
	local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
	if not coins then return end

	if not unlockedPortals[player.UserId] then
		unlockedPortals[player.UserId] = {}
	end

	for portalName, portalData in pairs(Config.Portals) do
		if not portalData.Unlocked and portalData.RequiredCoins then
			if coins.Value >= portalData.RequiredCoins and not unlockedPortals[player.UserId][portalName] then
				unlockedPortals[player.UserId][portalName] = true
				SoundSystem.PlaySound("PortalUnlock")

				local portal = workspace.CentralIsland:FindFirstChild(portalName .. "Portal")
				if portal then
					portal.BrickColor = BrickColor.new("Bright green")

					local click = portal:FindFirstChildOfClass("ClickDetector")
					if not click then
						click = Instance.new("ClickDetector")
						click.Parent = portal
					end

					local connectionKey = player.UserId .. "_" .. portalName
					if not portalClickConnections[connectionKey] then
						portalClickConnections[connectionKey] = click.MouseClick:Connect(function(clickPlayer)
							if clickPlayer == player and clickPlayer.Character then
								clickPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(portalData.Destination)
							end
						end)
					end
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	local coinsConnection

	player.CharacterAdded:Connect(function()
		if coinsConnection then
			coinsConnection:Disconnect()
			coinsConnection = nil
		end

		local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
		if coins then
			coinsConnection = coins.Changed:Connect(function()
				checkPortalUnlock(player)
			end)
			checkPortalUnlock(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	unlockedPortals[player.UserId] = nil

	for key, connection in pairs(portalClickConnections) do
		if key:find(tostring(player.UserId) .. "_") then
			connection:Disconnect()
			portalClickConnections[key] = nil
		end
	end
end)
