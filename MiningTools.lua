-- Mining Tools Setup Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MiningTools = {}

-- Tool Creation Function
function MiningTools.createPickaxe(toolName, toolStats)
    local tool = Instance.new("Tool")
    tool.Name = toolName
    tool.RequiresHandle = true
    
    -- Create handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.2, 4, 0.2)
    handle.Material = Enum.Material.Wood
    handle.Color = Color3.fromRGB(139, 69, 19)
    handle.Parent = tool
    
    -- Create pickaxe head
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1, 0.5, 0.2)
    head.Material = Enum.Material.Metal
    head.Color = Color3.fromRGB(100, 100, 100)
    head.Parent = tool
    
    -- Weld head to handle
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = head
    weld.Parent = handle
    
    -- Position head at top of handle
    head.CFrame = handle.CFrame * CFrame.new(0, 2, 0)
    
    -- Add tool stats
    local powerValue = Instance.new("IntValue")
    powerValue.Name = "Power"
    powerValue.Value = toolStats.power
    powerValue.Parent = tool
    
    local speedValue = Instance.new("NumberValue")
    speedValue.Name = "Speed"
    speedValue.Value = toolStats.speed
    speedValue.Parent = tool
    
    return tool
end

-- Initialize all tools
function MiningTools.initializeTools()
    local toolsFolder = Instance.new("Folder")
    toolsFolder.Name = "MiningTools"
    toolsFolder.Parent = ReplicatedStorage
    
    -- Create all pickaxe types
    local basicPickaxe = MiningTools.createPickaxe("BasicPickaxe", {power = 1, speed = 1})
    basicPickaxe.Parent = toolsFolder
    
    local ironPickaxe = MiningTools.createPickaxe("IronPickaxe", {power = 2, speed = 1.2})
    ironPickaxe.Head.Color = Color3.fromRGB(169, 169, 169)
    ironPickaxe.Parent = toolsFolder
    
    local diamondPickaxe = MiningTools.createPickaxe("DiamondPickaxe", {power = 3, speed = 1.5})
    diamondPickaxe.Head.Color = Color3.fromRGB(185, 242, 255)
    diamondPickaxe.Head.Material = Enum.Material.Diamond
    diamondPickaxe.Parent = toolsFolder
    
    local crystalPickaxe = MiningTools.createPickaxe("CrystalPickaxe", {power = 5, speed = 2})
    crystalPickaxe.Head.Color = Color3.fromRGB(255, 0, 255)
    crystalPickaxe.Head.Material = Enum.Material.Neon
    crystalPickaxe.Parent = toolsFolder
end

-- Give starter tool to player
function MiningTools.giveStarterTool(player)
    local toolsFolder = ReplicatedStorage:FindFirstChild("MiningTools")
    if not toolsFolder then return end
    
    local basicPickaxe = toolsFolder:FindFirstChild("BasicPickaxe")
    if basicPickaxe then
        local toolCopy = basicPickaxe:Clone()
        toolCopy.Parent = player.Backpack
    end
end

return MiningTools