-- SpawnSystem: Player join, leaderstats, starter pickaxe
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

ServerStorage:WaitForChild("GameReady")

local economy = ServerStorage:WaitForChild("Economy")
local pickaxesFolder = economy:WaitForChild("Pickaxes")

local SPAWN_POSITION = Vector3.new(0, 10, 0)
local POWER_UPS = {"SpeedBoost", "DoubleDrops", "InstantMine", "Shield"}

local function createStarterPickaxe()
	local starterFolder = pickaxesFolder:WaitForChild("Starter")
	local color = starterFolder.Color.Value
	local material = starterFolder.Material.Value
	local damage = starterFolder.Damage.Value

	local tool = Instance.new("Tool")
	tool.Name = "StarterPickaxe"
	tool.RequiresHandle = true
	tool.ToolTip = "Starter Pickaxe - Damage: " .. damage

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 3.5)
	handle.Color = color
	handle.Material = Enum.Material[material] or Enum.Material.Wood
	handle.Parent = tool

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://92656610"
	mesh.Scale = Vector3.new(0.85, 0.85, 0.85)
	mesh.Parent = handle

	tool.GripPos = Vector3.new(0, 0, -1.5)
	tool.GripForward = Vector3.new(0, 0, -1)
	tool.GripUp = Vector3.new(0, 1, 0)

	return tool
end

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local powerUp = Instance.new("StringValue")
	powerUp.Name = "PowerUp"
	powerUp.Value = POWER_UPS[math.random(1, #POWER_UPS)]
	powerUp.Parent = player

	player.CharacterAdded:Connect(function(character)
		local hrp = character:WaitForChild("HumanoidRootPart")
		hrp.CFrame = CFrame.new(SPAWN_POSITION)

		local hasPickaxe = false
		for _, item in ipairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") and item.Name:find("Pickaxe") then
				hasPickaxe = true
				break
			end
		end

		if not hasPickaxe then
			local pickaxe = createStarterPickaxe()
			pickaxe.Parent = player.Backpack
		end
	end)
end)
