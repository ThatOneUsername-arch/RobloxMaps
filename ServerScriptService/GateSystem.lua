local Config = require(script.Parent.Data.GameConfig)
local Players = game:GetService("Players")

local GATE_POSITION = Vector3.new(120, 15, 0)
local UNLOCK_COST = Config.Gates.DeepTunnel.UnlockCost
local unlockedPlayers = {}

local startingIsland = workspace:FindFirstChild("StartingIsland")
if not startingIsland then
	warn("StartingIsland not found in workspace")
	return
end

local function createGateForPlayer(player)
	local gate = Instance.new("Part")
	gate.Name = "DeepTunnelGate_" .. player.UserId
	gate.Size = Vector3.new(10, 12, 2)
	gate.Position = GATE_POSITION
	gate.Anchored = true
	gate.BrickColor = BrickColor.new("Really red")
	gate.Parent = startingIsland
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Unlock Deep Tunnel"
	prompt.ObjectText = UNLOCK_COST .. " Coins"
	prompt.RequiresLineOfSight = false
	prompt.Parent = gate
	
	prompt.Triggered:Connect(function(triggerPlayer)
		if triggerPlayer ~= player then return end
		if unlockedPlayers[player.UserId] then return end
		
		local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
		if not coins then return end
		
		if coins.Value >= UNLOCK_COST then
			coins.Value -= UNLOCK_COST
			unlockedPlayers[player.UserId] = true
			gate:Destroy()
		end
	end)
	
	return gate
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		wait(1)
		if not unlockedPlayers[player.UserId] then
			createGateForPlayer(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local gate = startingIsland:FindFirstChild("DeepTunnelGate_" .. player.UserId)
	if gate then
		gate:Destroy()
	end
end)
