local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local dailyBonusStore = DataStoreService:GetDataStore("DailyBonusStore")
local BONUS_AMOUNT = 100
local COOLDOWN_HOURS = 24

local function getLastClaimTime(player)
	local success, lastClaim = pcall(function()
		return dailyBonusStore:GetAsync(player.UserId)
	end)
	return success and lastClaim or 0
end

local function setLastClaimTime(player)
	pcall(function()
		dailyBonusStore:SetAsync(player.UserId, os.time())
	end)
end

local function canClaimBonus(player)
	local lastClaim = getLastClaimTime(player)
	local timeSince = os.time() - lastClaim
	return timeSince >= (COOLDOWN_HOURS * 3600)
end

local function claimBonus(player)
	if not canClaimBonus(player) then
		return false, "Already claimed today!"
	end
	
	local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
	if not coins then return false, "Error" end
	
	coins.Value += BONUS_AMOUNT
	setLastClaimTime(player)
	return true, "Claimed " .. BONUS_AMOUNT .. " coins!"
end

local bonusRemote = Instance.new("RemoteFunction")
bonusRemote.Name = "ClaimDailyBonus"
bonusRemote.Parent = game.ReplicatedStorage

bonusRemote.OnServerInvoke = function(player)
	return claimBonus(player)
end

return {
	CanClaim = canClaimBonus,
	Claim = claimBonus
}
