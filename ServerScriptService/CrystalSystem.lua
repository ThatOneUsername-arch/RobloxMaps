local Config = require(script.Parent.Data.GameConfig)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local crystalStates = {}

local function createCrystal(crystalData, area)
	local crystalConfig = Config.Crystals[crystalData.Type]
	
	local crystal = Instance.new("Part")
	crystal.Name = crystalData.Type .. "Crystal"
	crystal.Size = Vector3.new(3, 3, 3)
	crystal.Position = crystalData.Position
	crystal.Anchored = true
	crystal.BrickColor = BrickColor.new(crystalConfig.Color)
	crystal.Material = Enum.Material.Neon
	crystal.Parent = workspace:FindFirstChild(area) or workspace
	
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = crystal
	
	local healthValue = Instance.new("IntValue")
	healthValue.Name = "Health"
	healthValue.Value = crystalConfig.Health
	healthValue.Parent = crystal
	
	local typeValue = Instance.new("StringValue")
	typeValue.Name = "CrystalType"
	typeValue.Value = crystalData.Type
	typeValue.Parent = crystal
	
	crystalStates[crystal] = {
		MaxHealth = crystalConfig.Health,
		OriginalSize = crystal.Size,
		RespawnTime = crystalConfig.RespawnTime,
		Position = crystalData.Position,
		Type = crystalData.Type,
		Area = area
	}
	
	return crystal
end

local function respawnCrystal(crystalData, area)
	wait(crystalData.RespawnTime)
	createCrystal({Type = crystalData.Type, Position = crystalData.Position}, area)
end

local function spawnClusters()
	for areaName, clusters in pairs(Config.CrystalClusters) do
		local areaFolder = areaName == "StarterArea" and "StartingIsland" or "DeepTunnel"
		for _, crystalData in ipairs(clusters) do
			createCrystal(crystalData, areaFolder)
		end
	end
end

spawnClusters()

return {
	GetCrystalState = function(crystal)
		return crystalStates[crystal]
	end,
	RespawnCrystal = respawnCrystal
}
