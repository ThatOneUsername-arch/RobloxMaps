-- MiningSystem: Handles crystal mining, damage, rewards, and respawn
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local economy = ServerStorage:WaitForChild("Economy")
local pickaxesFolder = economy:WaitForChild("Pickaxes")
local crystalsFolder = economy:WaitForChild("Crystals")

local miningPlayers = {}
local crystalStates = {}

local function getPickaxeDamage(player)
	local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
	if not tool then return 1 end

	for _, pickaxe in ipairs(pickaxesFolder:GetChildren()) do
		if tool.Name:find(pickaxe.Name) then
			return pickaxe:WaitForChild("Damage").Value
		end
	end
	return 1
end

local function getCrystalConfig(typeName)
	local folder = crystalsFolder:FindFirstChild(typeName)
	if not folder then return nil end
	return {
		Value = folder:WaitForChild("Value").Value,
		Health = folder:WaitForChild("Health").Value,
		RespawnTime = folder:WaitForChild("RespawnTime").Value,
		Color = folder:WaitForChild("Color").Value
	}
end

local function createMiningEffect(crystal)
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Color = ColorSequence.new(crystal.Color)
	particle.Rate = 50
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(5, 10)
	particle.Parent = crystal

	task.delay(0.3, function()
		if particle.Parent then
			particle:Destroy()
		end
	end)
end

local function respawnCrystal(state)
	local config = getCrystalConfig(state.Type)
	if not config then return end

	task.wait(config.RespawnTime)

	local parent = workspace:FindFirstChild(state.Area) or workspace
	local crystal = Instance.new("Part")
	crystal.Name = state.Type .. "Crystal"
	crystal.Size = Vector3.new(3, 3, 3)
	crystal.Position = state.Position
	crystal.Anchored = true
	crystal.Material = Enum.Material.Neon
	crystal.Color = config.Color
	crystal.Parent = parent

	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = crystal

	local healthValue = Instance.new("IntValue")
	healthValue.Name = "Health"
	healthValue.Value = config.Health
	healthValue.Parent = crystal

	local typeValue = Instance.new("StringValue")
	typeValue.Name = "CrystalType"
	typeValue.Value = state.Type
	typeValue.Parent = crystal

	crystalStates[crystal] = {
		MaxHealth = config.Health,
		OriginalSize = crystal.Size,
		Position = state.Position,
		Type = state.Type,
		Area = state.Area
	}
end

local function damageCrystal(crystal, player)
	local health = crystal:FindFirstChild("Health")
	local crystalType = crystal:FindFirstChild("CrystalType")
	if not health or not crystalType then return end

	local damage = getPickaxeDamage(player)
	health.Value = math.max(0, health.Value - damage)

	local state = crystalStates[crystal]
	if state then
		local healthPercent = health.Value / state.MaxHealth
		crystal.Size = state.OriginalSize * math.max(0.3, healthPercent)
	end

	createMiningEffect(crystal)

	if health.Value <= 0 then
		local config = getCrystalConfig(crystalType.Value)
		local coinValue = config and config.Value or 10
		local leaderstats = player:FindFirstChild("leaderstats")
		local coins = leaderstats and leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Value = coins.Value + coinValue
		end

		local respawnState = {
			Type = crystalType.Value,
			Position = state and state.Position or crystal.Position,
			Area = state and state.Area or "StartingIsland"
		}

		crystalStates[crystal] = nil
		crystal:Destroy()

		task.spawn(function()
			respawnCrystal(respawnState)
		end)
	end
end

local function setupCrystalEvents(crystal)
	local clickDetector = crystal:FindFirstChildOfClass("ClickDetector")
	if not clickDetector then return end

	local typeName = crystal:FindFirstChild("CrystalType")
	local config = typeName and getCrystalConfig(typeName.Value)
	local maxHealth = crystal:FindFirstChild("Health") and crystal.Health.Value or 3

	crystalStates[crystal] = {
		MaxHealth = maxHealth,
		OriginalSize = crystal.Size,
		Position = crystal.Position,
		Type = typeName and typeName.Value or "Starter",
		Area = crystal.Parent and crystal.Parent.Name or "StartingIsland"
	}

	clickDetector.MouseClick:Connect(function(player)
		miningPlayers[player] = nil
		damageCrystal(crystal, player)
	end)

	clickDetector.RightMouseClick:Connect(function(player)
		miningPlayers[player] = crystal
		task.spawn(function()
			while miningPlayers[player] == crystal and crystal.Parent do
				damageCrystal(crystal, player)
				task.wait(0.5)
			end
		end)
	end)
end

workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("Part") and obj.Name:find("Crystal") then
		task.wait(0.1)
		setupCrystalEvents(obj)
	end
end)

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Part") and obj.Name:find("Crystal") then
		setupCrystalEvents(obj)
	end
end

Players.PlayerRemoving:Connect(function(player)
	miningPlayers[player] = nil
end)
