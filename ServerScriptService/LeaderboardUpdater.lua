local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeaderboardSystem = require(script.Parent.LeaderboardSystem)

local updateRemote = ReplicatedStorage:WaitForChild("UpdateLeaderboard")

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
	while true do
		updateAllPlayers()
		wait(30)
	end
end)

Players.PlayerAdded:Connect(function(player)
	wait(2)
	updateAllPlayers()
end)
