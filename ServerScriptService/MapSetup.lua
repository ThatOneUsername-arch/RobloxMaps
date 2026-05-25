-- MapSetup: Creates the game world, portals, and crystal spawns
-- Reads crystal/portal config from ServerStorage.Economy (created by EconomyValues)

local ServerStorage = game:GetService("ServerStorage")

local economy = ServerStorage:WaitForChild("Economy")
local crystalsFolder = economy:WaitForChild("Crystals")
local portalsFolder = economy:WaitForChild("Portals")

-- Crystal cluster positions (layout data, not economy data)
local CRYSTAL_CLUSTERS = {
	StarterArea = {
		{Type = "Starter", Position = Vector3.new(110, 15, 5)},
		{Type = "Starter", Position = Vector3.new(112, 15, 5)},
		{Type = "Starter", Position = Vector3.new(111, 15, 7)},
		{Type = "Iron", Position = Vector3.new(115, 15, 10)},
		{Type = "Iron", Position = Vector3.new(117, 15, 10)},
		{Type = "Iron", Position = Vector3.new(116, 15, 12)}
	},
	DeepTunnel = {
		{Type = "Gold", Position = Vector3.new(130, 10, 5)},
		{Type = "Gold", Position = Vector3.new(132, 10, 5)},
		{Type = "Gold", Position = Vector3.new(131, 10, 7)},
		{Type = "Diamond", Position = Vector3.new(135, 10, 10)},
		{Type = "Diamond", Position = Vector3.new(137, 10, 10)},
		{Type = "Diamond", Position = Vector3.new(136, 10, 12)},
		{Type = "Premium", Position = Vector3.new(140, 10, 15)},
		{Type = "Premium", Position = Vector3.new(142, 10, 15)},
		{Type = "Premium", Position = Vector3.new(141, 10, 17)}
	}
}

-- Portal positions (layout, not economy)
local PORTAL_LAYOUT = {
	Beginner = {Position = Vector3.new(-20, 12, 0), Destination = Vector3.new(100, 20, 0), Unlocked = true},
	Intermediate = {Position = Vector3.new(20, 12, 0), Unlocked = false},
	Advanced = {Position = Vector3.new(0, 12, 20), Unlocked = false},
	Expert = {Position = Vector3.new(0, 12, -20), Unlocked = false}
}

-- ============================================================
-- BUILD THE MAP
-- ============================================================

local centralIsland = Instance.new("Folder")
centralIsland.Name = "CentralIsland"
centralIsland.Parent = workspace

local ground = Instance.new("Part")
ground.Name = "CentralGround"
ground.Size = Vector3.new(80, 4, 80)
ground.Position = Vector3.new(0, 3, 0)
ground.Anchored = true
ground.Material = Enum.Material.Marble
ground.Color = Color3.fromRGB(220, 220, 230)
ground.Parent = centralIsland

local spawnPad = Instance.new("Part")
spawnPad.Name = "SpawnPad"
spawnPad.Size = Vector3.new(10, 0.5, 10)
spawnPad.Position = Vector3.new(0, 5.25, 0)
spawnPad.Anchored = true
spawnPad.Material = Enum.Material.Neon
spawnPad.Color = Color3.fromRGB(0, 255, 128)
spawnPad.Parent = centralIsland

-- Starting Island
local startingIsland = Instance.new("Folder")
startingIsland.Name = "StartingIsland"
startingIsland.Parent = workspace

local starterGround = Instance.new("Part")
starterGround.Name = "StarterGround"
starterGround.Size = Vector3.new(60, 4, 60)
starterGround.Position = Vector3.new(100, 15, 0)
starterGround.Anchored = true
starterGround.Material = Enum.Material.Grass
starterGround.Color = Color3.fromRGB(80, 160, 60)
starterGround.Parent = startingIsland

-- Deep Tunnel
local deepTunnel = Instance.new("Folder")
deepTunnel.Name = "DeepTunnel"
deepTunnel.Parent = workspace

local tunnelGround = Instance.new("Part")
tunnelGround.Name = "TunnelGround"
tunnelGround.Size = Vector3.new(60, 4, 60)
tunnelGround.Position = Vector3.new(130, 5, 0)
tunnelGround.Anchored = true
tunnelGround.Material = Enum.Material.Slate
tunnelGround.Color = Color3.fromRGB(60, 60, 70)
tunnelGround.Parent = deepTunnel

local tunnelCeiling = Instance.new("Part")
tunnelCeiling.Name = "TunnelCeiling"
tunnelCeiling.Size = Vector3.new(60, 2, 60)
tunnelCeiling.Position = Vector3.new(130, 25, 0)
tunnelCeiling.Anchored = true
tunnelCeiling.Material = Enum.Material.Slate
tunnelCeiling.Color = Color3.fromRGB(40, 40, 50)
tunnelCeiling.Transparency = 0.3
tunnelCeiling.Parent = deepTunnel

-- Intermediate zone
local intermediateZone = Instance.new("Part")
intermediateZone.Name = "IntermediateZone"
intermediateZone.Size = Vector3.new(60, 4, 60)
intermediateZone.Position = Vector3.new(200, 15, 0)
intermediateZone.Anchored = true
intermediateZone.Material = Enum.Material.Sand
intermediateZone.Color = Color3.fromRGB(194, 178, 128)
intermediateZone.Parent = workspace

-- Advanced zone
local advancedZone = Instance.new("Part")
advancedZone.Name = "AdvancedZone"
advancedZone.Size = Vector3.new(60, 4, 60)
advancedZone.Position = Vector3.new(300, 15, 0)
advancedZone.Anchored = true
advancedZone.Material = Enum.Material.Basalt
advancedZone.Color = Color3.fromRGB(80, 60, 80)
advancedZone.Parent = workspace

-- Expert zone
local expertZone = Instance.new("Part")
expertZone.Name = "ExpertZone"
expertZone.Size = Vector3.new(60, 4, 60)
expertZone.Position = Vector3.new(400, 15, 0)
expertZone.Anchored = true
expertZone.Material = Enum.Material.CrackedLava
expertZone.Color = Color3.fromRGB(50, 0, 80)
expertZone.Parent = workspace

-- ============================================================
-- CREATE PORTALS
-- ============================================================

for name, layout in pairs(PORTAL_LAYOUT) do
	local portal = Instance.new("Part")
	portal.Name = name .. "Portal"
	portal.Size = Vector3.new(6, 10, 1)
	portal.Position = layout.Position
	portal.Anchored = true
	portal.CanCollide = false
	portal.Material = Enum.Material.Neon
	portal.Transparency = 0.3
	portal.Parent = centralIsland

	if layout.Unlocked then
		portal.Color = Color3.fromRGB(0, 255, 100)
		local click = Instance.new("ClickDetector")
		click.MaxActivationDistance = 12
		click.Parent = portal

		click.MouseClick:Connect(function(player)
			local char = player.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				char.HumanoidRootPart.CFrame = CFrame.new(layout.Destination + Vector3.new(0, 5, 0))
			end
		end)
	else
		portal.Color = Color3.fromRGB(255, 50, 50)
	end

	-- Billboard label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 6, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = portal

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.5
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.Parent = billboard

	if layout.Unlocked then
		label.Text = name .. " Portal"
	else
		local portalConfig = portalsFolder:FindFirstChild(name)
		local req = portalConfig and portalConfig:FindFirstChild("RequiredCoins")
		label.Text = name .. " (" .. (req and req.Value or "?") .. " coins)"
	end
end

-- ============================================================
-- CREATE CRYSTALS
-- ============================================================

for areaName, clusters in pairs(CRYSTAL_CLUSTERS) do
	local parentFolder = areaName == "StarterArea" and workspace:FindFirstChild("StartingIsland") or workspace:FindFirstChild("DeepTunnel")
	if not parentFolder then parentFolder = workspace end

	for _, crystalData in ipairs(clusters) do
		local configFolder = crystalsFolder:FindFirstChild(crystalData.Type)
		local color = configFolder and configFolder:FindFirstChild("Color") and configFolder.Color.Value or Color3.fromRGB(255, 255, 255)
		local health = configFolder and configFolder:FindFirstChild("Health") and configFolder.Health.Value or 3

		local crystal = Instance.new("Part")
		crystal.Name = crystalData.Type .. "Crystal"
		crystal.Size = Vector3.new(3, 3, 3)
		crystal.Position = crystalData.Position
		crystal.Anchored = true
		crystal.Material = Enum.Material.Neon
		crystal.Color = color
		crystal.Parent = parentFolder

		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 10
		clickDetector.Parent = crystal

		local healthValue = Instance.new("IntValue")
		healthValue.Name = "Health"
		healthValue.Value = health
		healthValue.Parent = crystal

		local typeValue = Instance.new("StringValue")
		typeValue.Name = "CrystalType"
		typeValue.Value = crystalData.Type
		typeValue.Parent = crystal
	end
end

print("[MapSetup] Map complete: CentralIsland, StartingIsland, DeepTunnel, portals, crystals")
