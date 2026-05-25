-- DailyBonusSystem: Awards coins daily
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local economy = ServerStorage:WaitForChild("Economy")
local dailyConfig = economy:WaitForChild("DailyBonus")
local BONUS_AMOUNT = dailyConfig:WaitForChild("Amount").Value
local COOLDOWN_HOURS = dailyConfig:WaitForChild("CooldownHours").Value

-- React to live value changes
dailyConfig.Amount.Changed:Connect(function(val)
	BONUS_AMOUNT = val
end)
dailyConfig.CooldownHours.Changed:Connect(function(val)
	COOLDOWN_HOURS = val
end)

local dailyBonusStore = DataStoreService:GetDataStore("DailyBonusStore")

local bonusRemote = Instance.new("RemoteFunction")
bonusRemote.Name = "ClaimDailyBonus"
bonusRemote.Parent = ReplicatedStorage

local function getLastClaimTime(player)
	local success, lastClaim = pcall(function()
		return dailyBonusStore:GetAsync(tostring(player.UserId))
	end)
	return success and lastClaim or 0
end

local function setLastClaimTime(player)
	pcall(function()
		dailyBonusStore:SetAsync(tostring(player.UserId), os.time())
	end)
end

bonusRemote.OnServerInvoke = function(player)
	local lastClaim = getLastClaimTime(player)
	local timeSince = os.time() - (lastClaim or 0)

	if timeSince < (COOLDOWN_HOURS * 3600) then
		return false, "Already claimed today!"
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return false, "Error" end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return false, "Error" end

	coins.Value = coins.Value + BONUS_AMOUNT
	setLastClaimTime(player)
	return true, "Claimed " .. BONUS_AMOUNT .. " coins!"
end
