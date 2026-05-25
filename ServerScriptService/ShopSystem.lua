-- ShopSystem: Handles pickaxe purchases
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

ServerStorage:WaitForChild("GameReady")

local economy = ServerStorage.Economy
local pickaxesFolder = economy.Pickaxes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local shopRemote = remotes:WaitForChild("ShopPurchase")
local feedbackRemote = remotes:WaitForChild("ShopFeedback")

local function createPickaxeTool(name, data)
	local tool = Instance.new("Tool")
	tool.Name = name .. "Pickaxe"
	tool.RequiresHandle = true
	tool.ToolTip = name .. " Pickaxe - Damage: " .. data.Damage

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 3.5)
	handle.Color = data.Color
	handle.Material = Enum.Material[data.Material] or Enum.Material.Metal
	handle.Parent = tool

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://92656610"
	mesh.Scale = Vector3.new(0.85, 0.85, 0.85)
	mesh.Parent = handle

	tool.GripPos = Vector3.new(0, 0, -1.5)
	tool.GripForward = Vector3.new(0, 0, -1)
	tool.GripUp = Vector3.new(0, 1, 0)

	if data.Material == "Glass" then
		local pointLight = Instance.new("PointLight")
		pointLight.Color = data.Color
		pointLight.Brightness = 0.5
		pointLight.Range = 6
		pointLight.Parent = handle
	end

	return tool
end

local function getPickaxeData(name)
	local folder = pickaxesFolder:FindFirstChild(name)
	if not folder then return nil end
	return {
		Damage = folder.Damage.Value,
		Cost = folder.Cost.Value,
		Color = folder.Color.Value,
		Material = folder.Material.Value
	}
end

shopRemote.OnServerEvent:Connect(function(player, itemType, itemName)
	if itemType ~= "Pickaxe" then return end

	local pickaxeData = getPickaxeData(itemName)
	if not pickaxeData then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then return end

	if coins.Value < pickaxeData.Cost then
		feedbackRemote:FireClient(player, "Not enough coins! Need " .. pickaxeData.Cost)
		return
	end

	coins.Value = coins.Value - pickaxeData.Cost

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

	local tool = createPickaxeTool(itemName, pickaxeData)
	tool.Parent = player.Backpack
	feedbackRemote:FireClient(player, "Purchased " .. itemName .. " Pickaxe!")
end)
