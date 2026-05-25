local Config = require(script.Parent.Data.GameConfig)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundSystem = require(ReplicatedStorage.SoundSystem)

local shopRemote = Instance.new("RemoteEvent")
shopRemote.Name = "ShopPurchase"
shopRemote.Parent = ReplicatedStorage

local feedbackRemote = Instance.new("RemoteEvent")
feedbackRemote.Name = "ShopFeedback"
feedbackRemote.Parent = ReplicatedStorage

local function createPickaxeTool(name, data)
	local tool = Instance.new("Tool")
	tool.Name = name .. "Pickaxe"
	tool.RequiresHandle = true
	tool.ToolTip = name .. " Pickaxe - Damage: " .. data.Damage

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 3.5)
	handle.Color = data.Color
	handle.Material = data.Material
	handle.Parent = tool

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://92656610"
	mesh.Scale = Vector3.new(0.85, 0.85, 0.85)
	mesh.Parent = handle

	local weld = Instance.new("Vector3Value")
	weld.Name = "GripPos"
	weld.Value = Vector3.new(0, 0, -1.5)

	tool.GripPos = Vector3.new(0, 0, -1.5)
	tool.GripForward = Vector3.new(0, 0, -1)
	tool.GripUp = Vector3.new(0, 1, 0)

	if data.Material == Enum.Material.Glass then
		local pointLight = Instance.new("PointLight")
		pointLight.Color = data.Color
		pointLight.Brightness = 0.5
		pointLight.Range = 6
		pointLight.Parent = handle
	end

	if name == "Obsidian" then
		local particle = Instance.new("ParticleEmitter")
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Color = ColorSequence.new(Color3.fromRGB(128, 0, 255))
		particle.Rate = 8
		particle.Lifetime = NumberRange.new(0.5, 1)
		particle.Speed = NumberRange.new(1, 2)
		particle.Size = NumberSequence.new(0.1, 0)
		particle.Parent = handle
	end

	return tool
end

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
	SoundSystem.PlaySound("Purchase")
	feedbackRemote:FireClient(player, "Purchased " .. itemName .. " Pickaxe!")
end)

return {
	CreatePickaxeTool = createPickaxeTool
}
