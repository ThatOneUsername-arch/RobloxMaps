-- JumpController.lua
-- Client-side jump handling (request-only, no ApplyImpulse)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local JumpController = {}

local LocalPlayer = Players.LocalPlayer

-- Wait for remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("MovementRemotes",
10)
if not RemotesFolder then
warn("JumpController: MovementRemotes folder not found!")
return
end

local RequestJump = RemotesFolder:WaitForChild("RequestJump")

-- Configuration
local CONFIG = {
-- Visual feedback only (not affecting physics)
JUMP_ANIMATION_ID = nil, -- Set animation ID if you have custom
jump animation
ENABLE_JUMP_PARTICLES = true,
}

-- Local state for UI/feedback (not authoritative)
local LocalState = {
lastJumpRequestTime = 0,
canRequestJump = true,
}

-- Request jump from server
-- NOTE: Server handles all physics - we only send request
function JumpController.RequestJump()
local character = LocalPlayer.Character
if not character then return end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end

-- Basic client-side check (server will validate too)
local state = humanoid:GetState()
if state == Enum.HumanoidStateType.Jumping or state ==
Enum.HumanoidStateType.Freefall then
return -- Already in air
end

-- Send request to server (server performs actual jump)
RequestJump:FireServer()

-- Local feedback only (particles, sounds, etc.)
JumpController.PlayJumpFeedback()
end

-- Visual/audio feedback (no physics changes)
function JumpController.PlayJumpFeedback()
local character = LocalPlayer.Character
if not character then return end

local rootPart = character:FindFirstChild("HumanoidRootPart")
if not rootPart then return end

-- Play jump sound (if exists)
local jumpSound = rootPart:FindFirstChild("JumpSound")
if jumpSound and jumpSound:IsA("Sound") then
jumpSound:Play()
end

-- Create jump particles (optional visual feedback)
if CONFIG.ENABLE_JUMP_PARTICLES then
-- Simple dust effect at feet
local attachment = Instance.new("Attachment")
attachment.Position = Vector3.new(0, -3, 0)
attachment.Parent = rootPart

local particles = Instance.new("ParticleEmitter")
particles.Lifetime = NumberRange.new(0.3, 0.5)
particles.Rate = 0
particles.Speed = NumberRange.new(5, 10)
particles.SpreadAngle = Vector2.new(45, 45)
particles.Color = ColorSequence.new(Color3.fromRGB(200,
200, 200))
particles.Size = NumberSequence.new(0.5, 0)
particles.Transparency = NumberSequence.new(0.5, 1)
particles.Parent = attachment

-- Emit burst and clean up
particles:Emit(5)
task.delay(1, function()
attachment:Destroy()
end)
end
end

-- REMOVED: ApplyImpulse function
-- Server now handles all jump physics through Humanoid state changes

-- REMOVED: Direct jump power modification
-- Server controls JumpPower through MovementServer.lua

-- Input handling
local function OnInputBegan(input: InputObject, gameProcessed: boolean)
if gameProcessed then return end

if input.KeyCode == Enum.KeyCode.Space then
JumpController.RequestJump()
end
end

-- Mobile jump button support
local function OnJumpRequest()
JumpController.RequestJump()
end

-- Connect events
UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.JumpRequest:Connect(OnJumpRequest)

print("JumpController: Initialized (request-only, no client physics)")

return JumpController
