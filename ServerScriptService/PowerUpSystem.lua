local Config = require(script.Parent.Data.GameConfig)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundSystem = require(game.ReplicatedStorage.SoundSystem)

local activePowerUps = {}

local function applySpeedBoost(player, duration, multiplier)
	local char = player.Character
	if not char then return end
	
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * multiplier
	
	task.delay(duration, function()
		if humanoid then
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
	
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local shield = Instance.new("ForceField")
	shield.Parent = char
	
	task.delay(duration, function()
		shield:Destroy()
		activePowerUps[player.UserId] = nil
	end)
end

local function activatePowerUp(player)
	local powerUpValue = player:FindFirstChild("PowerUp")
	if not powerUpValue or powerUpValue.Value == "None" then return end
	
	if activePowerUps[player.UserId] then return end
	
	local powerUpType = powerUpValue.Value
	local powerUpConfig = Config.PowerUps[powerUpType]
	if not powerUpConfig then return end
	
	SoundSystem.PlaySound("PowerUpActivate")
	
	if powerUpType == "SpeedBoost" then
		applySpeedBoost(player, powerUpConfig.Duration, powerUpConfig.Multiplier)
	elseif powerUpType == "DoubleDrops" then
		applyDoubleDrops(player, powerUpConfig.Duration)
	elseif powerUpType == "InstantMine" then
		applyInstantMine(player, powerUpConfig.Uses)
	elseif powerUpType == "Shield" then
		applyShield(player, powerUpConfig.Duration)
	end
	
	powerUpValue.Value = "None"
	activePowerUps[player.UserId] = {Type = powerUpType, Active = true}
end

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

return {
	ActivatePowerUp = activatePowerUp,
	GetActivePowerUp = function(player)
		return activePowerUps[player.UserId]
	end
}
