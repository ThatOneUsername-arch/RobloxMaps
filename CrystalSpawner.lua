-- Crystal Spawning System
local CrystalSpawner = {}
local RunService = game:GetService("RunService")

local CRYSTAL_TYPES = {
    Common = {color = "Bright green", value = 15, rarity = 0.6},
    Rare = {color = "Bright blue", value = 75, rarity = 0.3},
    Epic = {color = "Bright violet", value = 225, rarity = 0.08},
    Legendary = {color = "Bright yellow", value = 750, rarity = 0.02}
}

local ZONE_TIMERS = {
    North = 120,  -- 2 minutes
    East = 90,    -- 1.5 minutes
    South = 180,  -- 3 minutes
    West = 150    -- 2.5 minutes
}

function CrystalSpawner:GetRandomCrystalType()
    local rand = math.random()
    local cumulative = 0
    
    for crystalType, data in pairs(CRYSTAL_TYPES) do
        cumulative = cumulative + data.rarity
        if rand <= cumulative then
            return crystalType, data
        end
    end
    return "Common", CRYSTAL_TYPES.Common
end

function CrystalSpawner:SpawnCrystal(position, zone)
    local crystalType, data = self:GetRandomCrystalType()
    
    local crystal = Instance.new("Part")
    crystal.Name = crystalType .. "Crystal"
    crystal.Size = Vector3.new(3, 6, 3)
    crystal.Position = position
    crystal.Material = Enum.Material.Neon
    crystal.BrickColor = BrickColor.new(data.color)
    crystal.Shape = Enum.PartType.Ball
    crystal.Anchored = true
    
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 10
    clickDetector.Parent = crystal
    
    clickDetector.MouseClick:Connect(function(player)
        self:CollectCrystal(player, crystal, data.value)
    end)
    
    crystal.Parent = workspace.Crystals or workspace
    
    -- Auto-despawn after 5 minutes
    game:GetService("Debris"):AddItem(crystal, 300)
end

function CrystalSpawner:CollectCrystal(player, crystal, value)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local crystals = leaderstats:FindFirstChild("Crystals")
        if crystals then
            crystals.Value = crystals.Value + value
        end
    end
    crystal:Destroy()
end

function CrystalSpawner:StartSpawning()
    local crystalFolder = Instance.new("Folder")
    crystalFolder.Name = "Crystals"
    crystalFolder.Parent = workspace
    
    for zone, timer in pairs(ZONE_TIMERS) do
        spawn(function()
            while true do
                wait(timer)
                local spawns = workspace.CrystalSpawns:GetChildren()
                local zoneSpawns = {}
                
                for _, spawn in ipairs(spawns) do
                    if string.find(spawn.Name, zone) then
                        table.insert(zoneSpawns, spawn)
                    end
                end
                
                if #zoneSpawns > 0 then
                    local randomSpawn = zoneSpawns[math.random(#zoneSpawns)]
                    self:SpawnCrystal(randomSpawn.Position + Vector3.new(0, 10, 0), zone)
                end
            end
        end)
    end
end

return CrystalSpawner