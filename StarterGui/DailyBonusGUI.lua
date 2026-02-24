local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local bonusRemote = ReplicatedStorage:WaitForChild("ClaimDailyBonus")

local bonusButton = Instance.new("TextButton")
bonusButton.Name = "DailyBonusButton"
bonusButton.Size = UDim2.new(0, 150, 0, 50)
bonusButton.Position = UDim2.new(1, -160, 0, 10)
bonusButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
bonusButton.Text = "🎁 DAILY BONUS"
bonusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bonusButton.TextSize = 16
bonusButton.Font = Enum.Font.GothamBold

local bonusGui = Instance.new("ScreenGui")
bonusGui.Name = "DailyBonusGUI"
bonusGui.ResetOnSpawn = false
bonusGui.Parent = StarterGui

bonusButton.Parent = bonusGui

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(0, 300, 0, 50)
feedbackLabel.Position = UDim2.new(0.5, -150, 0, 70)
feedbackLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
feedbackLabel.BackgroundTransparency = 0.3
feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
feedbackLabel.TextSize = 18
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.Visible = false
feedbackLabel.Parent = bonusGui

bonusButton.MouseButton1Click:Connect(function()
	local success, message = bonusRemote:InvokeServer()
	feedbackLabel.Text = message
	feedbackLabel.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
	feedbackLabel.Visible = true
	task.delay(3, function()
		feedbackLabel.Visible = false
	end)
end)
