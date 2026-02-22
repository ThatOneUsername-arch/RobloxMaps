-- Crystal Empire Map Generator
local MapGenerator = {}
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Map Configuration
local MAP_SIZE = 2048
local ZONE_SIZE = 600
local CENTER_SIZE = 400

-- Zone Definitions
local ZONES = {
    Central = {pos = Vector3.new(0, 8, 0), size = Vector3.new(400, 16, 400), material = Enum.Material.Marble},
    North = {pos = Vector3.new(0, 32, 600), size = Vector3.new(600, 64, 400), material = Enum.Material.Snow},
    East = {pos = Vector3.new(600, 16, 0), size = Vector3.new(400, 32, 600), material = Enum.Material.Basalt},
    South = {pos = Vector3.new(0, 4, -600), size = Vector3.new(600, 8, 400), material = Enum.Material.Sand},
    West = {pos = Vector3.new(-600, 12, 0), size = Vector3.new(400, 24, 600), material = Enum.Material.Grass}
}

-- Crystal Spawn Points
local CRYSTAL_SPAWNS = {
    North = {{-200, 40, 700}, {200, 45, 750}, {0, 50, 800}},
    East = {{700, 20, -200}, {750, 25, 200}, {800, 30, 0}},
    South = {{-200, 8, -700}, {200, 6, -750}, {0, 10, -800}},
    West = {{-700, 16, -200}, {-750, 18, 200}, {-800, 20, 0}}
}

function MapGenerator:CreateTerrain()
    local terrain = workspace.Terrain
    terrain:FillRegion(
        Region3.new(Vector3.new(-MAP_SIZE/2, -50, -MAP_SIZE/2), Vector3.new(MAP_SIZE/2, 0, MAP_SIZE/2)),
        4,
        Enum.Material.Water
    )
    
    for zoneName, zoneData in pairs(ZONES) do
        local region = Region3.new(
            zoneData.pos - zoneData.size/2,
            zoneData.pos + zoneData.size/2
        )
        terrain:FillRegion(region, 4, zoneData.material)
    end
end

function MapGenerator:CreateCrystalSpawns()
    local crystalFolder = Instance.new("Folder")
    crystalFolder.Name = "CrystalSpawns"
    crystalFolder.Parent = workspace
    
    for zone, spawns in pairs(CRYSTAL_SPAWNS) do
        for i, pos in ipairs(spawns) do
            local spawn = Instance.new("Part")
            spawn.Name = zone .. "Crystal" .. i
            spawn.Size = Vector3.new(4, 8, 4)
            spawn.Position = Vector3.new(pos[1], pos[2], pos[3])
            spawn.Material = Enum.Material.Neon
            spawn.BrickColor = BrickColor.new("Bright blue")
            spawn.Anchored = true
            spawn.Parent = crystalFolder
        end
    end
end

function MapGenerator:CreateZoneMarkers()
    local markerFolder = Instance.new("Folder")
    markerFolder.Name = "ZoneMarkers"
    markerFolder.Parent = workspace
    
    for zoneName, zoneData in pairs(ZONES) do
        local marker = Instance.new("Part")
        marker.Name = zoneName .. "Marker"
        marker.Size = Vector3.new(20, 1, 20)
        marker.Position = zoneData.pos
        marker.Material = Enum.Material.ForceField
        marker.Transparency = 0.5
        marker.Anchored = true
        marker.Parent = markerFolder
    end
end

function MapGenerator:GenerateMap()
    self:CreateTerrain()
    self:CreateCrystalSpawns()
    self:CreateZoneMarkers()
    print("Crystal Empire map generated successfully!")
end

return MapGenerator