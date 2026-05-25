-- PowerUpButton: Activate power-up button (top-right, row 2)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PowerUpGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = StarterGui

local activateButton = Instance.new("TextButton")
activateButton.Name = "ActivatePowerUpButton"
activateButton.Size = UDim2.new(0, 120, 0, 40)
activateButton.Position = UDim2.new(1, -130, 0, 60)
activateButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
activateButton.Text = "USE POWER-UP"
activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
activateButton.TextSize = 13
activateButton.Font = Enum.Font.GothamBold
activateButton.Parent = screenGui

activateButton.MouseButton1Click:Connect(function()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then return end
	local remote = remotes:FindFirstChild("ActivatePowerUp")
	if remote then
		remote:FireServer()
	end
end)
