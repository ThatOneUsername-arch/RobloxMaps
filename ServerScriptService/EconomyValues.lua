-- EconomyValues: Single source of truth for all game balance data
-- Other scripts read from ServerStorage.Economy using WaitForChild
-- Change any value here and it propagates everywhere via .Changed events

local ServerStorage = game:GetService("ServerStorage")

local economy = Instance.new("Folder")
economy.Name = "Economy"
economy.Parent = ServerStorage

-- ============================================================
-- PICKAXES
-- ============================================================
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

-- ============================================================
-- CRYSTALS
-- ============================================================
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

-- ============================================================
-- PORTALS
-- ============================================================
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

-- ============================================================
-- GATES
-- ============================================================
local gates = Instance.new("Folder")
gates.Name = "Gates"
gates.Parent = economy

local deepTunnelCost = Instance.new("IntValue")
deepTunnelCost.Name = "DeepTunnelCost"
deepTunnelCost.Value = 100
deepTunnelCost.Parent = gates

-- ============================================================
-- POWER-UPS
-- ============================================================
local powerUps = Instance.new("Folder")
powerUps.Name = "PowerUps"
powerUps.Parent = economy

local function createPowerUp(name, duration, multiplier, uses)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = powerUps

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

-- ============================================================
-- DAILY BONUS
-- ============================================================
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

print("[EconomyValues] All economy values created in ServerStorage.Economy")
