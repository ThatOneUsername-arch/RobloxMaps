-- PowerUpSystem: Manages power-up activation and effects
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local economy = ServerStorage:WaitForChild("Economy")
local powerUpsFolder = economy:WaitForChild("PowerUps")

local activePowerUps = {}

local function getPowerUpConfig(name)
	local folder = powerUpsFolder:FindFirstChild(name)
	if not folder then return nil end
	local config = {}
	local duration = folder:FindFirstChild("Duration")
	local multiplier = folder:FindFirstChild("Multiplier")
	local uses = folder:FindFirstChild("Uses")
	if duration then config.Duration = duration.Value end
	if multiplier then config.Multiplier = multiplier.Value end
	if uses then config.Uses = uses.Value end
	return config
end

local function applySpeedBoost(player, duration, multiplier)
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * multiplier

	task.delay(duration, function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = originalSpeed
		end
		activePowerUps[player.UserId] = nil
	end)
end

local function applyDoubleDrops(player, duration)
	activePowerUps[player.UserId] = {Type = "DoubleDrops", Multiplier = 2}
	task.delay(duration, function()
		activePowerUps[player.UserId] = nil
	end)
end

local function applyInstantMine(player, uses)
	activePowerUps[player.UserId] = {Type = "InstantMine", Uses = uses}
end

local function applyShield(player, duration)
	local char = player.Character
	if not char then return end

	local shield = Instance.new("ForceField")
	shield.Parent = char

	task.delay(duration, function()
		if shield and shield.Parent then
			shield:Destroy()
		end
		activePowerUps[player.UserId] = nil
	end)
end

local function activatePowerUp(player)
	local powerUpValue = player:FindFirstChild("PowerUp")
	if not powerUpValue or powerUpValue.Value == "None" then return end
	if activePowerUps[player.UserId] then return end

	local powerUpType = powerUpValue.Value
	local config = getPowerUpConfig(powerUpType)
	if not config then return end

	if powerUpType == "SpeedBoost" then
		applySpeedBoost(player, config.Duration, config.Multiplier)
	elseif powerUpType == "DoubleDrops" then
		applyDoubleDrops(player, config.Duration)
	elseif powerUpType == "InstantMine" then
		applyInstantMine(player, config.Uses)
	elseif powerUpType == "Shield" then
		applyShield(player, config.Duration)
	end

	powerUpValue.Value = "None"
end

-- Create RemoteEvent
local powerUpRemote = Instance.new("RemoteEvent")
powerUpRemote.Name = "ActivatePowerUp"
powerUpRemote.Parent = ReplicatedStorage

powerUpRemote.OnServerEvent:Connect(function(player)
	activatePowerUp(player)
end)

-- Cleanup
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			activePowerUps[player.UserId] = nil
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	activePowerUps[player.UserId] = nil
end)
