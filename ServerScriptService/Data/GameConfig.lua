local GameConfig = {}

GameConfig.Pickaxes = {
	Starter = {MiningSpeed = 1.0, Damage = 1, Cost = 0},
	Iron = {MiningSpeed = 2.0, Damage = 2, Cost = 100},
	Diamond = {MiningSpeed = 3.0, Damage = 3, Cost = 500},
	Obsidian = {MiningSpeed = 4.0, Damage = 5, Cost = 2000}
}

GameConfig.PowerUps = {
	SpeedBoost = {Duration = 30, Multiplier = 2},
	DoubleDrops = {Duration = 60, Multiplier = 2},
	InstantMine = {Uses = 5},
	Shield = {Duration = 45}
}

GameConfig.Crystals = {
	Starter = {Value = 10, Health = 3, RespawnTime = 60, Color = Color3.fromRGB(150, 150, 150)},
	Iron = {Value = 25, Health = 6, RespawnTime = 60, Color = Color3.fromRGB(200, 200, 200)},
	Gold = {Value = 50, Health = 10, RespawnTime = 60, Color = Color3.fromRGB(255, 215, 0)},
	Diamond = {Value = 100, Health = 15, RespawnTime = 60, Color = Color3.fromRGB(0, 191, 255)},
	Premium = {Value = 200, Health = 20, RespawnTime = 60, Color = Color3.fromRGB(138, 43, 226)}
}

GameConfig.CrystalClusters = {
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

GameConfig.Gates = {
	DeepTunnel = {UnlockCost = 100}
}

GameConfig.Portals = {
	Beginner = {Unlocked = true, Position = Vector3.new(-20, 5, 0), Destination = Vector3.new(100, 20, 0)},
	Intermediate = {Unlocked = false, RequiredCoins = 500, Position = Vector3.new(20, 5, 0), Destination = Vector3.new(200, 20, 0)},
	Advanced = {Unlocked = false, RequiredCoins = 2000, Position = Vector3.new(0, 5, 20), Destination = Vector3.new(300, 20, 0)},
	Expert = {Unlocked = false, RequiredCoins = 5000, Position = Vector3.new(0, 5, -20), Destination = Vector3.new(400, 20, 0)}
}

return GameConfig
