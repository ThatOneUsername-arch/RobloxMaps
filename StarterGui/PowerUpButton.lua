local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local powerUpRemote = Instance.new("RemoteEvent")
powerUpRemote.Name = "ActivatePowerUp"
powerUpRemote.Parent = ReplicatedStorage

local activateButton = Instance.new("TextButton")
activateButton.Name = "ActivatePowerUpButton"
activateButton.Size = UDim2.new(0, 150, 0, 50)
activateButton.Position = UDim2.new(0, 10, 0, 150)
activateButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
activateButton.Text = "⚡ USE POWER-UP"
activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
activateButton.TextSize = 16
activateButton.Font = Enum.Font.GothamBold

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PowerUpGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = StarterGui

activateButton.Parent = screenGui

activateButton.MouseButton1Click:Connect(function()
	powerUpRemote:FireServer()
end)
