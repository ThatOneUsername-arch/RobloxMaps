-- LeaderboardGUI: Top miners display (bottom-right, out of the way)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local leaderboardGui = Instance.new("ScreenGui")
leaderboardGui.Name = "LeaderboardGUI"
leaderboardGui.ResetOnSpawn = false
leaderboardGui.Parent = StarterGui

local frame = Instance.new("Frame")
frame.Name = "LeaderboardFrame"
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(1, -230, 1, -310)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 215, 0)
frame.Parent = leaderboardGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "TOP MINERS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -45)
scrollFrame.Position = UDim2.new(0, 5, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scrollFrame

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
	if not remotes then return end
	local updateRemote = remotes:WaitForChild("UpdateLeaderboard", 10)
	if not updateRemote then return end

	updateRemote.OnClientEvent:Connect(function(topPlayers)
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		for rank, playerData in ipairs(topPlayers) do
			local entryFrame = Instance.new("Frame")
			entryFrame.Size = UDim2.new(1, -5, 0, 30)
			entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			entryFrame.Parent = scrollFrame

			local rankLabel = Instance.new("TextLabel")
			rankLabel.Size = UDim2.new(0, 25, 1, 0)
			rankLabel.BackgroundTransparency = 1
			rankLabel.Text = "#" .. rank
			rankLabel.TextColor3 = rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
			rankLabel.TextSize = 14
			rankLabel.Font = Enum.Font.GothamBold
			rankLabel.Parent = entryFrame

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.5, -25, 1, 0)
			nameLabel.Position = UDim2.new(0, 28, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = playerData.Name or "Player"
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.TextSize = 12
			nameLabel.Font = Enum.Font.Gotham
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = entryFrame

			local coinsLabel = Instance.new("TextLabel")
			coinsLabel.Size = UDim2.new(0.4, 0, 1, 0)
			coinsLabel.Position = UDim2.new(0.6, 0, 0, 0)
			coinsLabel.BackgroundTransparency = 1
			coinsLabel.Text = tostring(playerData.Coins)
			coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
			coinsLabel.TextSize = 12
			coinsLabel.Font = Enum.Font.GothamBold
			coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
			coinsLabel.Parent = entryFrame
		end

		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #topPlayers * 34)
	end)
end)
