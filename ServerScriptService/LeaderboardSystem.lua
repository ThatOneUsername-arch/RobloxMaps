-- LeaderboardSystem: Tracks coins in DataStore and broadcasts top 10
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local leaderboardStore = DataStoreService:GetOrderedDataStore("CrystalMinerLeaderboard")

local SAVE_INTERVAL = 10
local UPDATE_INTERVAL = 30
local pendingSaves = {}

local updateRemote = Instance.new("RemoteEvent")
updateRemote.Name = "UpdateLeaderboard"
updateRemote.Parent = ReplicatedStorage

local function flushPlayerSave(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return end

	pcall(function()
		leaderboardStore:SetAsync(tostring(player.UserId), coins.Value)
	end)
end

local function getTopPlayers(count)
	local success, pages = pcall(function()
		return leaderboardStore:GetSortedAsync(false, count or 10)
	end)

	if not success or not pages then return {} end

	local topPlayers = {}
	local ok, entries = pcall(function()
		return pages:GetCurrentPage()
	end)

	if not ok or not entries then return {} end

	for _, entry in ipairs(entries) do
		local userId = tonumber(entry.key)
		local nameSuccess, username = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		table.insert(topPlayers, {
			Name = nameSuccess and username or "Unknown",
			Coins = entry.value
		})
	end

	return topPlayers
end

local function broadcastLeaderboard()
	local topPlayers = getTopPlayers(10)
	for _, player in ipairs(Players:GetPlayers()) do
		updateRemote:FireClient(player, topPlayers)
	end
end

-- Batch save loop
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

-- Broadcast loop
task.spawn(function()
	task.wait(5)
	while true do
		broadcastLeaderboard()
		task.wait(UPDATE_INTERVAL)
	end
end)

-- Track coin changes per player
Players.PlayerAdded:Connect(function(player)
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if not leaderstats then return end
	local coins = leaderstats:WaitForChild("Coins", 5)
	if not coins then return end

	coins.Changed:Connect(function()
		pendingSaves[player.UserId] = player
	end)

	task.wait(3)
	broadcastLeaderboard()
end)

Players.PlayerRemoving:Connect(function(player)
	pendingSaves[player.UserId] = nil
	flushPlayerSave(player)
end)
