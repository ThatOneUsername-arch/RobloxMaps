local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeaderboardSystem = require(script.Parent.LeaderboardSystem)

local updateRemote = Instance.new("RemoteEvent")
updateRemote.Name = "UpdateLeaderboard"
updateRemote.Parent = ReplicatedStorage

local function updateAllPlayers()
	local topPlayers = LeaderboardSystem.GetTopPlayers(10)

	for _, entry in ipairs(topPlayers) do
		local success, username = pcall(function()
			return Players:GetNameFromUserIdAsync(entry.UserId)
		end)
		entry.Name = success and username or "Unknown"
	end

	for _, player in ipairs(Players:GetPlayers()) do
		updateRemote:FireClient(player, topPlayers)
	end
end

task.spawn(function()
	task.wait(2)
	while true do
		updateAllPlayers()
		task.wait(30)
	end
end)

Players.PlayerAdded:Connect(function(player)
	task.wait(3)
	updateAllPlayers()
end)
