local Config = require(script.Parent.Data.GameConfig)
local CrystalSystem = require(script.Parent.CrystalSystem)
local PowerUpSystem = require(script.Parent.PowerUpSystem)
local SoundSystem = require(game.ReplicatedStorage.SoundSystem)

local miningPlayers = {}

local function getPickaxeDamage(player)
	local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
	if not tool then return 1 end
	
	for pickaxeName, pickaxeData in pairs(Config.Pickaxes) do
		if tool.Name:find(pickaxeName) then
			return pickaxeData.Damage
		end
	end
	return 1
end

local function createMiningEffect(crystal)
	local particle = Instance.new("ParticleEmitter")
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Color = ColorSequence.new(crystal.BrickColor.Color)
	particle.Rate = 50
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(5, 10)
	particle.Parent = crystal
	
	task.delay(0.2, function()
		particle:Destroy()
	end)
end

local function damageCrystal(crystal, player)
	local health = crystal:FindFirstChild("Health")
	local crystalType = crystal:FindFirstChild("CrystalType")
	if not health or not crystalType then return end
	
	local damage = getPickaxeDamage(player)
	local powerUp = PowerUpSystem.GetActivePowerUp(player)
	
	if powerUp and powerUp.Type == "InstantMine" and powerUp.Uses > 0 then
		health.Value = 0
		powerUp.Uses -= 1
		if powerUp.Uses <= 0 then
			powerUp = nil
		end
	else
		health.Value = math.max(0, health.Value - damage)
	end
	
	local state = CrystalSystem.GetCrystalState(crystal)
	if state then
		local healthPercent = health.Value / state.MaxHealth
		crystal.Size = state.OriginalSize * healthPercent
	end
	
	createMiningEffect(crystal)
	SoundSystem.PlaySound("MineHit")
	
	if health.Value <= 0 then
		local crystalConfig = Config.Crystals[crystalType.Value]
		local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
		if coins and crystalConfig then
			local value = crystalConfig.Value
			if powerUp and powerUp.Type == "DoubleDrops" then
				value = value * powerUp.Multiplier
			end
			coins.Value += value
			SoundSystem.PlaySound("CoinCollect")
		end
		
		SoundSystem.PlaySound("CrystalBreak")
		
		local respawnData = {
			Type = crystalType.Value,
			Position = crystal.Position,
			RespawnTime = crystalConfig.RespawnTime
		}
		local area = state.Area
		
		crystal:Destroy()
		task.spawn(function()
			CrystalSystem.RespawnCrystal(respawnData, area)
		end)
	end
end

local function setupCrystalEvents(crystal)
	local clickDetector = crystal:FindFirstChildOfClass("ClickDetector")
	if not clickDetector then return end
	
	clickDetector.MouseClick:Connect(function(player)
		damageCrystal(crystal, player)
	end)
	
	clickDetector.RightMouseClick:Connect(function(player)
		if not miningPlayers[player] then
			miningPlayers[player] = crystal
			task.spawn(function()
				while miningPlayers[player] == crystal and crystal.Parent do
					damageCrystal(crystal, player)
					wait(0.5)
				end
			end)
		end
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

game.Players.PlayerRemoving:Connect(function(player)
	miningPlayers[player] = nil
end)
