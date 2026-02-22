-- Crystal Empire Main Game Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local MapGenerator = require(script.MapGenerator)
local CrystalSpawner = require(script.CrystalSpawner)
local ZoneControl = require(script.ZoneControl)

-- Game Configuration
local STARTING_CRYSTALS = 100

-- Initialize player data
local function setupPlayer(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    local crystals = Instance.new("IntValue")
    crystals.Name = "Crystals"
    crystals.Value = STARTING_CRYSTALS
    crystals.Parent = leaderstats
    
    local zonesControlled = Instance.new("IntValue")
    zonesControlled.Name = "Zones"
    zonesControlled.Value = 0
    zonesControlled.Parent = leaderstats
end

-- Player spawn handling
local function onPlayerSpawn(player)
    player.CharacterAdded:Connect(function(character)
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        -- Spawn at Central Citadel
        humanoidRootPart.CFrame = CFrame.new(0, 20, 0)
    end)
end

-- Initialize game systems
local function initializeGame()
    print("Initializing Crystal Empire...")
    
    -- Generate map
    MapGenerator:GenerateMap()
    
    -- Start crystal spawning
    CrystalSpawner:StartSpawning()
    
    -- Start zone control system
    ZoneControl:StartZoneControl()
    
    print("Crystal Empire initialized successfully!")
end

-- Player connection events
Players.PlayerAdded:Connect(function(player)
    setupPlayer(player)
    onPlayerSpawn(player)
end)

-- Initialize game on server start
initializeGame()