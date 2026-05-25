local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local leaderboardStore = DataStoreService:GetOrderedDataStore("CrystalMinerLeaderboard")

local SAVE_INTERVAL = 10
local pendingSaves = {}

local function flushPlayerSave(player)
	local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
	if not coins then return end

	local success, err = pcall(function()
		leaderboardStore:SetAsync(player.UserId, coins.Value)
	end)

	if not success then
		warn("Failed to update leaderboard:", err)
	end
end

task.spawn(function()
	while true do
		task.wait(SAVE_INTERVAL)
		for userId, player in pairs(pendingSaves) do
			if player.Parent then
				flushPlayerSave(player)
			end
			pendingSaves[userId] = nil
		end
	end
end)

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
				pendingSaves[player.UserId] = player
			end)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	pendingSaves[player.UserId] = nil
	flushPlayerSave(player)
end)

return {
	GetTopPlayers = function(count)
		local success, pages = pcall(function()
			return leaderboardStore:GetSortedAsync(false, count or 10)
		end)

		if not success then return {} end

		local topPlayers = {}
		local entries = pages:GetCurrentPage()

		for _, entry in ipairs(entries) do
			table.insert(topPlayers, {
				UserId = entry.key,
				Coins = entry.value
			})
		end

		return topPlayers
	end
}
