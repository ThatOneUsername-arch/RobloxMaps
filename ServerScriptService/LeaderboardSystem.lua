-- LeaderboardSystem: DataStore tracking and top 10 broadcast
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

ServerStorage:WaitForChild("GameReady")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateRemote = remotes:WaitForChild("UpdateLeaderboard")

local SAVE_INTERVAL = 10
local UPDATE_INTERVAL = 30
local pendingSaves = {}

-- Graceful DataStore handling (won't work in Studio without API enabled)
local leaderboardStore
local datastoreEnabled = false

local ok, store = pcall(function()
	return DataStoreService:GetOrderedDataStore("CrystalMinerLeaderboard")
end)
if ok and store then
	leaderboardStore = store
	datastoreEnabled = true
else
	warn("[LeaderboardSystem] DataStore unavailable - leaderboard will use local data only")
end

local function flushPlayerSave(player)
	if not datastoreEnabled then return end
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return end

	pcall(function()
		leaderboardStore:SetAsync(tostring(player.UserId), coins.Value)
	end)
end

local function getTopPlayers(count)
	if datastoreEnabled then
		local success, pages = pcall(function()
			return leaderboardStore:GetSortedAsync(false, count or 10)
		end)

		if success and pages then
			local topPlayers = {}
			local ok2, entries = pcall(function()
				return pages:GetCurrentPage()
			end)

			if ok2 and entries then
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
		end
	end

	-- Fallback: use current players as leaderboard
	local topPlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		local coins = leaderstats and leaderstats:FindFirstChild("Coins")
		if coins then
			table.insert(topPlayers, {Name = player.Name, Coins = coins.Value})
		end
	end
	table.sort(topPlayers, function(a, b) return a.Coins > b.Coins end)
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
