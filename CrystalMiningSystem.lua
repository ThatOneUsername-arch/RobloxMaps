-- Crystal Mining System for Roblox Crystal Empire Game
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CrystalMining = {}

-- Crystal Types and Properties
local CRYSTAL_TYPES = {
    Common = {value = 1, hardness = 1, color = Color3.fromRGB(150, 150, 255)},
    Rare = {value = 5, hardness = 2, color = Color3.fromRGB(255, 100, 255)},
    Epic = {value = 15, hardness = 3, color = Color3.fromRGB(255, 215, 0)},
    Legendary = {value = 50, hardness = 4, color = Color3.fromRGB(255, 0, 0)}
}

-- Tool Properties
local TOOL_STATS = {
    BasicPickaxe = {power = 1, speed = 1},
    IronPickaxe = {power = 2, speed = 1.2},
    DiamondPickaxe = {power = 3, speed = 1.5},
    CrystalPickaxe = {power = 5, speed = 2}
}

-- Create Crystal Node
function CrystalMining.createCrystalNode(position, crystalType)
    local crystal = Instance.new("Part")
    crystal.Name = "CrystalNode"
    crystal.Size = Vector3.new(4, 6, 4)
    crystal.Position = position
    crystal.Anchored = true
    crystal.Material = Enum.Material.Neon
    crystal.Color = CRYSTAL_TYPES[crystalType].color
    crystal.Shape = Enum.PartType.Block
    
    -- Add crystal properties
    local crystalData = Instance.new("StringValue")
    crystalData.Name = "CrystalType"
    crystalData.Value = crystalType
    crystalData.Parent = crystal
    
    local health = Instance.new("IntValue")
    health.Name = "Health"
    health.Value = CRYSTAL_TYPES[crystalType].hardness * 10
    health.Parent = crystal
    
    -- Visual effects
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 2
    pointLight.Color = CRYSTAL_TYPES[crystalType].color
    pointLight.Range = 10
    pointLight.Parent = crystal
    
    crystal.Parent = workspace
    return crystal
end

-- Mining Animation
function CrystalMining.playMiningAnimation(player, tool)
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Simple swing animation using TweenService
    local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
    if rightArm then
        local swingTween = TweenService:Create(
            rightArm,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
            {CFrame = rightArm.CFrame * CFrame.Angles(math.rad(-45), 0, 0)}
        )
        swingTween:Play()
    end
end

-- Mine Crystal Function
function CrystalMining.mineCrystal(player, crystal, tool)
    local crystalType = crystal:FindFirstChild("CrystalType").Value
    local health = crystal:FindFirstChild("Health")
    local toolName = tool.Name
    
    if not TOOL_STATS[toolName] then return false end
    
    local toolPower = TOOL_STATS[toolName].power
    local damage = toolPower
    
    -- Check if tool can mine this crystal
    if toolPower < CRYSTAL_TYPES[crystalType].hardness then
        CrystalMining.showFeedback(player, "Tool too weak!", Color3.fromRGB(255, 0, 0))
        return false
    end
    
    -- Play mining animation
    CrystalMining.playMiningAnimation(player, tool)
    
    -- Damage crystal
    health.Value = health.Value - damage
    
    -- Visual feedback - crystal shake
    local shakeTween = TweenService:Create(
        crystal,
        TweenInfo.new(0.1, Enum.EasingStyle.Bounce),
        {Position = crystal.Position + Vector3.new(math.random(-1,1), 0, math.random(-1,1))}
    )
    shakeTween:Play()
    
    -- Particle effect
    CrystalMining.createMiningParticles(crystal)
    
    if health.Value <= 0 then
        -- Crystal destroyed - give rewards
        CrystalMining.giveReward(player, crystalType)
        crystal:Destroy()
        return true
    end
    
    return false
end

-- Create Mining Particles
function CrystalMining.createMiningParticles(crystal)
    local attachment = Instance.new("Attachment")
    attachment.Parent = crystal
    
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(crystal.Color)
    particles.Lifetime = NumberRange.new(0.5, 1.0)
    particles.Rate = 50
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(5, 10)
    particles.Parent = attachment
    
    -- Auto cleanup
    game:GetService("Debris"):AddItem(attachment, 2)
end

-- Player Feedback System
function CrystalMining.showFeedback(player, message, color)
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    local screenGui = playerGui:FindFirstChild("MiningFeedback") or Instance.new("ScreenGui")
    screenGui.Name = "MiningFeedback"
    screenGui.Parent = playerGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 50)
    textLabel.Position = UDim2.new(0.5, -100, 0.3, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = color
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = screenGui
    
    -- Animate feedback
    local fadeTween = TweenService:Create(
        textLabel,
        TweenInfo.new(2, Enum.EasingStyle.Quad),
        {TextTransparency = 1, Position = UDim2.new(0.5, -100, 0.2, 0)}
    )
    fadeTween:Play()
    
    fadeTween.Completed:Connect(function()
        textLabel:Destroy()
    end)
end

-- Reward System
function CrystalMining.giveReward(player, crystalType)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
        
        local crystals = Instance.new("IntValue")
        crystals.Name = "Crystals"
        crystals.Value = 0
        crystals.Parent = leaderstats
    end
    
    local crystalValue = CRYSTAL_TYPES[crystalType].value
    leaderstats.Crystals.Value = leaderstats.Crystals.Value + crystalValue
    
    CrystalMining.showFeedback(player, "+" .. crystalValue .. " " .. crystalType .. " Crystal!", CRYSTAL_TYPES[crystalType].color)
end

-- Tool Interaction Handler
function CrystalMining.setupToolInteraction(tool)
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    tool.Activated:Connect(function()
        local player = Players:GetPlayerFromCharacter(tool.Parent)
        if not player then return end
        
        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Raycast to find crystal
        local rayOrigin = humanoidRootPart.Position
        local rayDirection = humanoidRootPart.CFrame.LookVector * 10
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
        raycastParams.FilterDescendantsInstances = {workspace}
        
        local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if raycastResult and raycastResult.Instance.Name == "CrystalNode" then
            CrystalMining.mineCrystal(player, raycastResult.Instance, tool)
        end
    end)
end

return CrystalMining