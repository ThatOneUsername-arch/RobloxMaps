-- Zone Control System
local ZoneControl = {}
local Players = game:GetService("Players")

local ZONES = {
    North = {owner = nil, contested = false, points = 0},
    East = {owner = nil, contested = false, points = 0},
    South = {owner = nil, contested = false, points = 0},
    West = {owner = nil, contested = false, points = 0}
}

local CAPTURE_POINTS = 100
local CAPTURE_RATE = 1 -- points per second

function ZoneControl:GetPlayersInZone(zoneName)
    local playersInZone = {}
    local zoneMarker = workspace.ZoneMarkers:FindFirstChild(zoneName .. "Marker")
    
    if not zoneMarker then return playersInZone end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - zoneMarker.Position).Magnitude
            if distance <= 300 then -- Zone radius
                table.insert(playersInZone, player)
            end
        end
    end
    
    return playersInZone
end

function ZoneControl:UpdateZoneControl(zoneName)
    local playersInZone = self:GetPlayersInZone(zoneName)
    local zone = ZONES[zoneName]
    
    if #playersInZone == 0 then
        zone.contested = false
        return
    end
    
    -- Determine controlling team
    local teamCounts = {}
    for _, player in ipairs(playersInZone) do
        local team = player.Team and player.Team.Name or "Neutral"
        teamCounts[team] = (teamCounts[team] or 0) + 1
    end
    
    local dominantTeam = nil
    local maxCount = 0
    local totalPlayers = 0
    
    for team, count in pairs(teamCounts) do
        totalPlayers = totalPlayers + count
        if count > maxCount then
            maxCount = count
            dominantTeam = team
        end
    end
    
    -- Check if contested
    local contestedCount = 0
    for team, count in pairs(teamCounts) do
        if count > 0 then contestedCount = contestedCount + 1 end
    end
    
    zone.contested = contestedCount > 1
    
    if not zone.contested and dominantTeam then
        if zone.owner == dominantTeam then
            -- Maintain control
            zone.points = math.min(CAPTURE_POINTS, zone.points + CAPTURE_RATE)
        else
            -- Capturing
            zone.points = zone.points - CAPTURE_RATE
            if zone.points <= 0 then
                zone.owner = dominantTeam
                zone.points = CAPTURE_RATE
                self:OnZoneCaptured(zoneName, dominantTeam)
            end
        end
    end
end

function ZoneControl:OnZoneCaptured(zoneName, team)
    print(team .. " has captured " .. zoneName .. "!")
    
    -- Bonus effects for controlling team
    local zoneMarker = workspace.ZoneMarkers:FindFirstChild(zoneName .. "Marker")
    if zoneMarker then
        zoneMarker.BrickColor = BrickColor.new("Bright red") -- Team color
    end
end

function ZoneControl:StartZoneControl()
    spawn(function()
        while true do
            for zoneName, _ in pairs(ZONES) do
                self:UpdateZoneControl(zoneName)
            end
            wait(1)
        end
    end)
end

function ZoneControl:GetZoneStatus()
    return ZONES
end

return ZoneControl