-- GateSystem: Blocks Deep Tunnel access until player pays
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

ServerStorage:WaitForChild("GameReady")

local economy = ServerStorage.Economy
local UNLOCK_COST = economy.Gates.DeepTunnelCost.Value

economy.Gates.DeepTunnelCost.Changed:Connect(function(newCost)
	UNLOCK_COST = newCost
end)

local GATE_POSITION = Vector3.new(120, 15, 0)
local unlockedPlayers = {}

local function createGateForPlayer(player)
	local startingIsland = workspace:FindFirstChild("StartingIsland")
	if not startingIsland then return end

	local gate = Instance.new("Part")
	gate.Name = "DeepTunnelGate_" .. player.UserId
	gate.Size = Vector3.new(10, 12, 2)
	gate.Position = GATE_POSITION
	gate.Anchored = true
	gate.BrickColor = BrickColor.new("Really red")
	gate.Material = Enum.Material.DiamondPlate
	gate.Parent = startingIsland

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Unlock Deep Tunnel"
	prompt.ObjectText = UNLOCK_COST .. " Coins"
	prompt.RequiresLineOfSight = false
	prompt.Parent = gate

	prompt.Triggered:Connect(function(triggerPlayer)
		if triggerPlayer ~= player then return end
		if unlockedPlayers[player.UserId] then return end

		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then return end
		local coins = leaderstats:FindFirstChild("Coins")
		if not coins then return end

		if coins.Value >= UNLOCK_COST then
			coins.Value = coins.Value - UNLOCK_COST
			unlockedPlayers[player.UserId] = true
			gate:Destroy()
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1.5)
		if not unlockedPlayers[player.UserId] then
			createGateForPlayer(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local startingIsland = workspace:FindFirstChild("StartingIsland")
	if startingIsland then
		local gate = startingIsland:FindFirstChild("DeepTunnelGate_" .. player.UserId)
		if gate then
			gate:Destroy()
		end
	end
end)
