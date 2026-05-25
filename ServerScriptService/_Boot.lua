-- _Boot: Single entry point that creates Economy, Remotes, and Map in order
-- All other scripts wait for ServerStorage.GameReady before running

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================================
-- STEP 1: ECONOMY VALUES
-- ============================================================

local economy = Instance.new("Folder")
economy.Name = "Economy"
economy.Parent = ServerStorage

-- Pickaxes
local pickaxes = Instance.new("Folder")
pickaxes.Name = "Pickaxes"
pickaxes.Parent = economy

local function createPickaxe(name, damage, cost, speed, colorR, colorG, colorB, material)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = pickaxes

	local d = Instance.new("IntValue")
	d.Name = "Damage"
	d.Value = damage
	d.Parent = folder

	local c = Instance.new("IntValue")
	c.Name = "Cost"
	c.Value = cost
	c.Parent = folder

	local s = Instance.new("NumberValue")
	s.Name = "MiningSpeed"
	s.Value = speed
	s.Parent = folder

	local col = Instance.new("Color3Value")
	col.Name = "Color"
	col.Value = Color3.fromRGB(colorR, colorG, colorB)
	col.Parent = folder

	local mat = Instance.new("StringValue")
	mat.Name = "Material"
	mat.Value = material
	mat.Parent = folder
end

createPickaxe("Starter", 1, 0, 1.0, 139, 90, 43, "Wood")
createPickaxe("Iron", 2, 100, 2.0, 180, 180, 190, "Metal")
createPickaxe("Diamond", 3, 500, 3.0, 0, 191, 255, "Glass")
createPickaxe("Obsidian", 5, 2000, 4.0, 30, 0, 50, "Basalt")

-- Crystals
local crystals = Instance.new("Folder")
crystals.Name = "Crystals"
crystals.Parent = economy

local function createCrystal(name, value, health, respawnTime, colorR, colorG, colorB)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = crystals

	local v = Instance.new("IntValue")
	v.Name = "Value"
	v.Value = value
	v.Parent = folder

	local h = Instance.new("IntValue")
	h.Name = "Health"
	h.Value = health
	h.Parent = folder

	local r = Instance.new("IntValue")
	r.Name = "RespawnTime"
	r.Value = respawnTime
	r.Parent = folder

	local col = Instance.new("Color3Value")
	col.Name = "Color"
	col.Value = Color3.fromRGB(colorR, colorG, colorB)
	col.Parent = folder
end

createCrystal("Starter", 10, 3, 10, 150, 150, 150)
createCrystal("Iron", 25, 6, 15, 200, 200, 200)
createCrystal("Gold", 50, 10, 25, 255, 215, 0)
createCrystal("Diamond", 100, 15, 40, 0, 191, 255)
createCrystal("Premium", 200, 20, 60, 138, 43, 226)

-- Portals
local portals = Instance.new("Folder")
portals.Name = "Portals"
portals.Parent = economy

local function createPortal(name, requiredCoins, destX, destY, destZ)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = portals

	local req = Instance.new("IntValue")
	req.Name = "RequiredCoins"
	req.Value = requiredCoins
	req.Parent = folder

	local dest = Instance.new("Vector3Value")
	dest.Name = "Destination"
	dest.Value = Vector3.new(destX, destY, destZ)
	dest.Parent = folder
end

createPortal("Intermediate", 500, 200, 20, 0)
createPortal("Advanced", 2000, 300, 20, 0)
createPortal("Expert", 5000, 400, 20, 0)

-- Gates
local gatesFolder = Instance.new("Folder")
gatesFolder.Name = "Gates"
gatesFolder.Parent = economy

local deepTunnelCost = Instance.new("IntValue")
deepTunnelCost.Name = "DeepTunnelCost"
deepTunnelCost.Value = 100
deepTunnelCost.Parent = gatesFolder

-- Power-ups
local powerUpsFolder = Instance.new("Folder")
powerUpsFolder.Name = "PowerUps"
powerUpsFolder.Parent = economy

local function createPowerUp(name, duration, multiplier, uses)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = powerUpsFolder

	if duration then
		local d = Instance.new("IntValue")
		d.Name = "Duration"
		d.Value = duration
		d.Parent = folder
	end
	if multiplier then
		local m = Instance.new("NumberValue")
		m.Name = "Multiplier"
		m.Value = multiplier
		m.Parent = folder
	end
	if uses then
		local u = Instance.new("IntValue")
		u.Name = "Uses"
		u.Value = uses
		u.Parent = folder
	end
end

createPowerUp("SpeedBoost", 30, 2, nil)
createPowerUp("DoubleDrops", 60, 2, nil)
createPowerUp("InstantMine", nil, nil, 5)
createPowerUp("Shield", 45, nil, nil)

-- Daily Bonus
local daily = Instance.new("Folder")
daily.Name = "DailyBonus"
daily.Parent = economy

local bonusAmount = Instance.new("IntValue")
bonusAmount.Name = "Amount"
bonusAmount.Value = 100
bonusAmount.Parent = daily

local cooldownHours = Instance.new("IntValue")
cooldownHours.Name = "CooldownHours"
cooldownHours.Value = 24
cooldownHours.Parent = daily

-- ============================================================
-- STEP 2: CREATE ALL REMOTES (single source, no duplication)
-- ============================================================

local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local shopPurchase = Instance.new("RemoteEvent")
shopPurchase.Name = "ShopPurchase"
shopPurchase.Parent = remotes

local shopFeedback = Instance.new("RemoteEvent")
shopFeedback.Name = "ShopFeedback"
shopFeedback.Parent = remotes

local activatePowerUp = Instance.new("RemoteEvent")
activatePowerUp.Name = "ActivatePowerUp"
activatePowerUp.Parent = remotes

local updateLeaderboard = Instance.new("RemoteEvent")
updateLeaderboard.Name = "UpdateLeaderboard"
updateLeaderboard.Parent = remotes

local claimDailyBonus = Instance.new("RemoteFunction")
claimDailyBonus.Name = "ClaimDailyBonus"
claimDailyBonus.Parent = remotes

-- ============================================================
-- STEP 3: BUILD THE MAP
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

local intermediateZone = Instance.new("Part")
intermediateZone.Name = "IntermediateZone"
intermediateZone.Size = Vector3.new(60, 4, 60)
intermediateZone.Position = Vector3.new(200, 15, 0)
intermediateZone.Anchored = true
intermediateZone.Material = Enum.Material.Sand
intermediateZone.Color = Color3.fromRGB(194, 178, 128)
intermediateZone.Parent = workspace

local advancedZone = Instance.new("Part")
advancedZone.Name = "AdvancedZone"
advancedZone.Size = Vector3.new(60, 4, 60)
advancedZone.Position = Vector3.new(300, 15, 0)
advancedZone.Anchored = true
advancedZone.Material = Enum.Material.Basalt
advancedZone.Color = Color3.fromRGB(80, 60, 80)
advancedZone.Parent = workspace

local expertZone = Instance.new("Part")
expertZone.Name = "ExpertZone"
expertZone.Size = Vector3.new(60, 4, 60)
expertZone.Position = Vector3.new(400, 15, 0)
expertZone.Anchored = true
expertZone.Material = Enum.Material.CrackedLava
expertZone.Color = Color3.fromRGB(50, 0, 80)
expertZone.Parent = workspace

-- Portals
local PORTAL_LAYOUT = {
	Beginner = {Position = Vector3.new(-20, 12, 0), Destination = Vector3.new(100, 20, 0), Unlocked = true},
	Intermediate = {Position = Vector3.new(20, 12, 0), Unlocked = false},
	Advanced = {Position = Vector3.new(0, 12, 20), Unlocked = false},
	Expert = {Position = Vector3.new(0, 12, -20), Unlocked = false}
}

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
		local portalConfig = portals:FindFirstChild(name)
		local req = portalConfig and portalConfig:FindFirstChild("RequiredCoins")
		label.Text = name .. " (" .. (req and req.Value or "?") .. " coins)"
	end
end

-- Crystals
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

for areaName, clusters in pairs(CRYSTAL_CLUSTERS) do
	local parentFolder = areaName == "StarterArea" and startingIsland or deepTunnel

	for _, crystalData in ipairs(clusters) do
		local configFolder = crystals:FindFirstChild(crystalData.Type)
		local color = configFolder and configFolder.Color.Value or Color3.fromRGB(255, 255, 255)
		local health = configFolder and configFolder.Health.Value or 3

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

-- ============================================================
-- STEP 4: SIGNAL READY
-- ============================================================

local ready = Instance.new("BoolValue")
ready.Name = "GameReady"
ready.Value = true
ready.Parent = ServerStorage

print("[_Boot] Game initialized: Economy, Remotes, Map, Crystals all ready")
