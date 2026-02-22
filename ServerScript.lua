-- Main Server Script - Initialize Mining System
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Require modules
local CrystalMining = require(script.CrystalMiningSystem)
local MiningTools = require(script.MiningTools)
local CrystalSpawner = require(script.CrystalSpawner)

-- Initialize systems
print("Initializing Crystal Empire Mining System...")

-- Setup tools
MiningTools.initializeTools()
print("Mining tools created")

-- Initialize crystal spawning
CrystalSpawner.initialize()
print("Crystal spawning system initialized")

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    -- Give starter tool
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Wait for character to fully load
        MiningTools.giveStarterTool(player)
    end)
    
    -- Setup tool interactions when player gets tools
    player.Backpack.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") and tool.Name:find("Pickaxe") then
            CrystalMining.setupToolInteraction(tool)
        end
    end)
end)

print("Crystal Empire Mining System fully initialized!")