-- DailyBonusSystem: Awards coins daily
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

ServerStorage:WaitForChild("GameReady")

local economy = ServerStorage.Economy
local dailyConfig = economy.DailyBonus
local BONUS_AMOUNT = dailyConfig.Amount.Value
local COOLDOWN_HOURS = dailyConfig.CooldownHours.Value

dailyConfig.Amount.Changed:Connect(function(val) BONUS_AMOUNT = val end)
dailyConfig.CooldownHours.Changed:Connect(function(val) COOLDOWN_HOURS = val end)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local bonusRemote = remotes:WaitForChild("ClaimDailyBonus")

-- Graceful DataStore handling
local dailyBonusStore
local datastoreEnabled = false

local ok, store = pcall(function()
	return DataStoreService:GetDataStore("DailyBonusStore")
end)
if ok and store then
	dailyBonusStore = store
	datastoreEnabled = true
else
	warn("[DailyBonusSystem] DataStore unavailable - daily bonus will always be claimable")
end

local function getLastClaimTime(player)
	if not datastoreEnabled then return 0 end
	local success, lastClaim = pcall(function()
		return dailyBonusStore:GetAsync(tostring(player.UserId))
	end)
	return success and lastClaim or 0
end

local function setLastClaimTime(player)
	if not datastoreEnabled then return end
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
