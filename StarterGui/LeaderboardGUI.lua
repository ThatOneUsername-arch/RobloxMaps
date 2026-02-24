local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local leaderboardGui = Instance.new("ScreenGui")
leaderboardGui.Name = "LeaderboardGUI"
leaderboardGui.ResetOnSpawn = false
leaderboardGui.Parent = StarterGui

local frame = Instance.new("Frame")
frame.Name = "LeaderboardFrame"
frame.Size = UDim2.new(0, 250, 0, 400)
frame.Position = UDim2.new(1, -260, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
frame.Parent = leaderboardGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "🏆 TOP MINERS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -50)
scrollFrame.Position = UDim2.new(0, 5, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollFrame

local updateRemote = Instance.new("RemoteEvent")
updateRemote.Name = "UpdateLeaderboard"
updateRemote.Parent = ReplicatedStorage

updateRemote.OnClientEvent:Connect(function(topPlayers)
	for _, child in ipairs(scrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	for rank, playerData in ipairs(topPlayers) do
		local entryFrame = Instance.new("Frame")
		entryFrame.Size = UDim2.new(1, -10, 0, 35)
		entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		entryFrame.Parent = scrollFrame
		
		local rankLabel = Instance.new("TextLabel")
		rankLabel.Size = UDim2.new(0, 30, 1, 0)
		rankLabel.BackgroundTransparency = 1
		rankLabel.Text = "#" .. rank
		rankLabel.TextColor3 = rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
		rankLabel.TextSize = 16
		rankLabel.Font = Enum.Font.GothamBold
		rankLabel.Parent = entryFrame
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, -35, 1, 0)
		nameLabel.Position = UDim2.new(0, 35, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = playerData.Name or "Player"
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 14
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = entryFrame
		
		local coinsLabel = Instance.new("TextLabel")
		coinsLabel.Size = UDim2.new(0.5, -5, 1, 0)
		coinsLabel.Position = UDim2.new(0.5, 0, 0, 0)
		coinsLabel.BackgroundTransparency = 1
		coinsLabel.Text = "💰 " .. playerData.Coins
		coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		coinsLabel.TextSize = 14
		coinsLabel.Font = Enum.Font.GothamBold
		coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
		coinsLabel.Parent = entryFrame
	end
	
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #topPlayers * 40)
end)
