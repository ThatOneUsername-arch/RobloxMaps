local Config = require(script.Parent.Data.GameConfig)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundSystem = require(ReplicatedStorage.SoundSystem)

local shopRemote = Instance.new("RemoteEvent")
shopRemote.Name = "ShopPurchase"
shopRemote.Parent = ReplicatedStorage

local feedbackRemote = Instance.new("RemoteEvent")
feedbackRemote.Name = "ShopFeedback"
feedbackRemote.Parent = ReplicatedStorage

shopRemote.OnServerEvent:Connect(function(player, itemType, itemName)
	if itemType ~= "Pickaxe" then return end
	
	local pickaxeData = Config.Pickaxes[itemName]
	if not pickaxeData then return end
	
	local coins = player.leaderstats and player.leaderstats:FindFirstChild("Coins")
	if not coins then return end
	
	if coins.Value < pickaxeData.Cost then
		feedbackRemote:FireClient(player, "Not enough coins! Need " .. pickaxeData.Cost)
		return
	end
	
	coins.Value -= pickaxeData.Cost
	
	local tool = Instance.new("Tool")
	tool.Name = itemName .. "Pickaxe"
	tool.RequiresHandle = true
	
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.5, 3, 0.5)
	handle.Parent = tool
	
	for _, existingTool in ipairs(player.Backpack:GetChildren()) do
		if existingTool:IsA("Tool") and existingTool.Name:find("Pickaxe") then
			existingTool:Destroy()
		end
	end
	
	if player.Character then
		local equippedTool = player.Character:FindFirstChildOfClass("Tool")
		if equippedTool and equippedTool.Name:find("Pickaxe") then
			equippedTool:Destroy()
		end
	end
	
	tool.Parent = player.Backpack
	SoundSystem.PlaySound("Purchase")
	feedbackRemote:FireClient(player, "Purchased " .. itemName .. " Pickaxe!")
end)
