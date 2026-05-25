local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiningHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = StarterGui

local coinFrame = Instance.new("Frame")
coinFrame.Name = "CoinFrame"
coinFrame.Size = UDim2.new(0, 200, 0, 60)
coinFrame.Position = UDim2.new(0, 10, 0, 10)
coinFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coinFrame.BorderSizePixel = 2
coinFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
coinFrame.Parent = screenGui

local coinIcon = Instance.new("TextLabel")
coinIcon.Size = UDim2.new(0, 40, 0, 40)
coinIcon.Position = UDim2.new(0, 10, 0.5, -20)
coinIcon.BackgroundTransparency = 1
coinIcon.Text = "💰"
coinIcon.TextSize = 30
coinIcon.Parent = coinFrame

local coinLabel = Instance.new("TextLabel")
coinLabel.Name = "CoinLabel"
coinLabel.Size = UDim2.new(1, -60, 1, 0)
coinLabel.Position = UDim2.new(0, 60, 0, 0)
coinLabel.BackgroundTransparency = 1
coinLabel.Text = "0"
coinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coinLabel.TextSize = 24
coinLabel.Font = Enum.Font.GothamBold
coinLabel.TextXAlignment = Enum.TextXAlignment.Left
coinLabel.Parent = coinFrame

local powerUpFrame = Instance.new("Frame")
powerUpFrame.Name = "PowerUpFrame"
powerUpFrame.Size = UDim2.new(0, 200, 0, 60)
powerUpFrame.Position = UDim2.new(0, 10, 0, 80)
powerUpFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
powerUpFrame.BorderSizePixel = 2
powerUpFrame.BorderColor3 = Color3.fromRGB(138, 43, 226)
powerUpFrame.Parent = screenGui

local powerUpLabel = Instance.new("TextLabel")
powerUpLabel.Name = "PowerUpLabel"
powerUpLabel.Size = UDim2.new(1, -20, 1, 0)
powerUpLabel.Position = UDim2.new(0, 10, 0, 0)
powerUpLabel.BackgroundTransparency = 1
powerUpLabel.Text = "Power-up: None"
powerUpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
powerUpLabel.TextSize = 18
powerUpLabel.Font = Enum.Font.Gotham
powerUpLabel.TextXAlignment = Enum.TextXAlignment.Left
powerUpLabel.Parent = powerUpFrame

local function updateHUD(player)
	local gui = player.PlayerGui:FindFirstChild("MiningHUD")
	if not gui then return end

	local label = gui.CoinFrame:FindFirstChild("CoinLabel")
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if label and coins then
		label.Text = tostring(coins.Value)
	end

	local puLabel = gui.PowerUpFrame:FindFirstChild("PowerUpLabel")
	local powerUp = player:FindFirstChild("PowerUp")
	if puLabel and powerUp then
		puLabel.Text = "Power-up: " .. powerUp.Value
	end
end

Players.PlayerAdded:Connect(function(player)
	local coinsConnection
	local powerUpConnection

	local function connectListeners()
		if coinsConnection then
			coinsConnection:Disconnect()
			coinsConnection = nil
		end
		if powerUpConnection then
			powerUpConnection:Disconnect()
			powerUpConnection = nil
		end

		local leaderstats = player:WaitForChild("leaderstats", 10)
		local coins = leaderstats and leaderstats:FindFirstChild("Coins")
		if coins then
			coinsConnection = coins.Changed:Connect(function()
				updateHUD(player)
			end)
		end

		local powerUp = player:WaitForChild("PowerUp", 10)
		if powerUp then
			powerUpConnection = powerUp.Changed:Connect(function()
				updateHUD(player)
			end)
		end

		updateHUD(player)
	end

	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		connectListeners()
	end)

	if player.Character then
		task.wait(0.5)
		connectListeners()
	end
end)
