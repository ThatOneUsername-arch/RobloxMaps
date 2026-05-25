-- DailyBonusGUI: Daily bonus claim button (top-right, row 1)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local bonusGui = Instance.new("ScreenGui")
bonusGui.Name = "DailyBonusGUI"
bonusGui.ResetOnSpawn = false
bonusGui.Parent = StarterGui

local bonusButton = Instance.new("TextButton")
bonusButton.Name = "DailyBonusButton"
bonusButton.Size = UDim2.new(0, 120, 0, 40)
bonusButton.Position = UDim2.new(1, -130, 0, 10)
bonusButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
bonusButton.Text = "DAILY BONUS"
bonusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bonusButton.TextSize = 14
bonusButton.Font = Enum.Font.GothamBold
bonusButton.Parent = bonusGui

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(0, 250, 0, 40)
feedbackLabel.Position = UDim2.new(1, -380, 0, 10)
feedbackLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
feedbackLabel.BackgroundTransparency = 0.3
feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
feedbackLabel.TextSize = 16
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.Text = ""
feedbackLabel.Visible = false
feedbackLabel.Parent = bonusGui

bonusButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return end
	local bonusRemote = remotes:FindFirstChild("ClaimDailyBonus")
	if not bonusRemote then return end

	local success, message = bonusRemote:InvokeServer()
	feedbackLabel.Text = message or ""
	feedbackLabel.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
	feedbackLabel.Visible = true
	task.delay(3, function()
		feedbackLabel.Visible = false
	end)
end)
