local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local leaderboardStore = DataStoreService:GetOrderedDataStore("CrystalMinerLeaderboard")

local function updateLeaderboard(player)
	local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
	if not coins then return end
	
	local success, err = pcall(function()
		leaderboardStore:SetAsync(player.UserId, coins.Value)
	end)
	
	if not success then
		warn("Failed to update leaderboard:", err)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
		if coins then
			coins.Changed:Connect(function()
				updateLeaderboard(player)
			end)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	updateLeaderboard(player)
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
