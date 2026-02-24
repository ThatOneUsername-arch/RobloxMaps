local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local shopGui = Instance.new("ScreenGui")
shopGui.Name = "ShopGUI"
shopGui.ResetOnSpawn = false
shopGui.Parent = StarterGui

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "FeedbackLabel"
feedbackLabel.Size = UDim2.new(0, 300, 0, 50)
feedbackLabel.Position = UDim2.new(0.5, -150, 0, 220)
feedbackLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
feedbackLabel.BackgroundTransparency = 0.3
feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
feedbackLabel.TextSize = 18
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.Visible = false
feedbackLabel.Parent = shopGui

local feedbackRemote = ReplicatedStorage:WaitForChild("ShopFeedback")
feedbackRemote.OnClientEvent:Connect(function(message)
	feedbackLabel.Text = message
	feedbackLabel.Visible = true
	task.delay(3, function()
		feedbackLabel.Visible = false
	end)
end)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "ShopFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
mainFrame.Visible = false
mainFrame.Parent = shopGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "⛏️ PICKAXE SHOP"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -45, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = scrollFrame

local pickaxes = {
	{Name = "Starter", Cost = 0, Damage = 1, Speed = 1.0},
	{Name = "Iron", Cost = 100, Damage = 2, Speed = 2.0},
	{Name = "Diamond", Cost = 500, Damage = 3, Speed = 3.0},
	{Name = "Obsidian", Cost = 2000, Damage = 5, Speed = 4.0}
}

for _, pickaxe in ipairs(pickaxes) do
	local itemFrame = Instance.new("Frame")
	itemFrame.Size = UDim2.new(1, -10, 0, 80)
	itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	itemFrame.Parent = scrollFrame
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = pickaxe.Name .. " Pickaxe"
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = itemFrame
	
	local statsLabel = Instance.new("TextLabel")
	statsLabel.Size = UDim2.new(0.6, 0, 0, 20)
	statsLabel.Position = UDim2.new(0, 10, 0, 35)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "Damage: " .. pickaxe.Damage .. " | Speed: " .. pickaxe.Speed .. "x"
	statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statsLabel.TextSize = 14
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.Parent = itemFrame
	
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0, 100, 0, 60)
	buyButton.Position = UDim2.new(1, -110, 0.5, -30)
	buyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	buyButton.Text = pickaxe.Cost == 0 and "FREE" or "💰 " .. pickaxe.Cost
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextSize = 16
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = itemFrame
	
	buyButton.MouseButton1Click:Connect(function()
		local shopRemote = ReplicatedStorage:WaitForChild("ShopPurchase")
		shopRemote:FireServer("Pickaxe", pickaxe.Name)
	end)
end

scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #pickaxes * 90)

local openButton = Instance.new("TextButton")
openButton.Name = "OpenShopButton"
openButton.Size = UDim2.new(0, 120, 0, 50)
openButton.Position = UDim2.new(1, -130, 0, 150)
openButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
openButton.Text = "🛒 SHOP"
openButton.TextColor3 = Color3.fromRGB(0, 0, 0)
openButton.TextSize = 20
openButton.Font = Enum.Font.GothamBold
openButton.Parent = shopGui

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)
