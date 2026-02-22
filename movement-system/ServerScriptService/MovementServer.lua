-- MovementServer.lua
-- Server-authoritative movement logic
-- Place in ServerScriptService

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementServer = {}

-- Configuration
local CONFIG = {
-- Base movement values (server-authoritative)
BASE_WALK_SPEED = 16,
SPRINT_SPEED = 24,
BASE_JUMP_POWER = 50,

-- Stamina system
MAX_STAMINA = 100,
STAMINA_DRAIN_RATE = 15, -- per second while sprinting
STAMINA_REGEN_RATE = 10, -- per second while not sprinting
MIN_STAMINA_TO_SPRINT = 10,

-- Rate limiting
MAX_JUMPS_PER_SECOND = 5,
MAX_SPRINT_REQUESTS_PER_SECOND = 10,

-- Anti-cheat
POSITION_CHECK_INTERVAL = 0.1,
VIOLATION_THRESHOLD = 3,
MAX_SPEED_TOLERANCE = 1.2, -- 20% tolerance for lag
MAX_TELEPORT_DISTANCE = 50,

-- Validation
MAX_INPUT_MAGNITUDE = 1.0,
}

-- Player data storage
local PlayerData = {}

-- Wait for remotes to be created
local RemotesFolder = ReplicatedStorage:WaitForChild("MovementRemotes",
10)
if not RemotesFolder then
warn("MovementServer: MovementRemotes folder not found!")
return
end

local Remotes = {
RequestJump = RemotesFolder:WaitForChild("RequestJump"),
RequestSprintStart =
RemotesFolder:WaitForChild("RequestSprintStart"),
RequestSprintStop =
RemotesFolder:WaitForChild("RequestSprintStop"),
RequestMovementInput =
RemotesFolder:WaitForChild("RequestMovementInput"),
UpdateMovementState =
RemotesFolder:WaitForChild("UpdateMovementState"),
UpdateStamina = RemotesFolder:WaitForChild("UpdateStamina"),
MovementViolation =
RemotesFolder:WaitForChild("MovementViolation"),
}

-- Initialize player data
local function InitializePlayerData(player: Player)
PlayerData[player] = {
-- Movement state
isSprinting = false,
stamina = CONFIG.MAX_STAMINA,
currentWalkSpeed = CONFIG.BASE_WALK_SPEED,
currentJumpPower = CONFIG.BASE_JUMP_POWER,

-- Rate limiting
jumpRequests = {},
sprintRequests = {},

-- Anti-cheat
lastPosition = nil,
lastPositionTime = 0,
violations = 0,

-- Input validation
lastInputTime = 0,
lastInput = Vector3.zero,
}
end

-- Clean up player data
local function CleanupPlayerData(player: Player)
PlayerData[player] = nil
end

-- Rate limiter helper
local function CheckRateLimit(requests: {number}, maxPerSecond: number):
boolean
local currentTime = tick()

-- Remove old requests (older than 1 second)
local validRequests = {}
for _, requestTime in ipairs(requests) do
if currentTime - requestTime < 1 then
table.insert(validRequests, requestTime)
end
end

-- Check if under limit
if #validRequests >= maxPerSecond then
return false
end

-- Add current request
table.insert(validRequests, currentTime)

-- Update the requests table
for i = 1, #requests do
requests[i] = nil
end
for i, v in ipairs(validRequests) do
requests[i] = v
end

return true
end

-- Input validation
local function ValidateInput(input: any): (boolean, Vector3?)
-- Check type
if typeof(input) ~= "Vector3" then
return false, nil
end

-- Check for NaN or infinity
if input.X ~= input.X or input.Y ~= input.Y or input.Z ~= input.Z
then
return false, nil
end

if math.abs(input.X) == math.huge or math.abs(input.Y) ==
math.huge or math.abs(input.Z) == math.huge then
return false, nil
end

-- Normalize if magnitude exceeds max
local magnitude = input.Magnitude
if magnitude > CONFIG.MAX_INPUT_MAGNITUDE then
input = input.Unit * CONFIG.MAX_INPUT_MAGNITUDE
end

return true, input
end

-- Apply movement values to character (server-authoritative)
local function ApplyMovementValues(player: Player)
local data = PlayerData[player]
if not data then return end

local character = player.Character
if not character then return end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end

-- Set values directly on server
humanoid.WalkSpeed = data.currentWalkSpeed
humanoid.JumpPower = data.currentJumpPower

-- Notify client of state change
Remotes.UpdateMovementState:FireClient(player, {
walkSpeed = data.currentWalkSpeed,
jumpPower = data.currentJumpPower,
isSprinting = data.isSprinting,
})
end

-- Handle jump request
local function OnRequestJump(player: Player)
local data = PlayerData[player]
if not data then return end

-- Rate limit check
if not CheckRateLimit(data.jumpRequests,
CONFIG.MAX_JUMPS_PER_SECOND) then
warn("MovementServer: Jump rate limit exceeded for",
player.Name)
return
end

local character = player.Character
if not character then return end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end

-- Server performs the jump
if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and
humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
end

-- Handle sprint start request
local function OnRequestSprintStart(player: Player)
local data = PlayerData[player]
if not data then return end

-- Rate limit check
if not CheckRateLimit(data.sprintRequests,
CONFIG.MAX_SPRINT_REQUESTS_PER_SECOND) then
warn("MovementServer: Sprint rate limit exceeded for",
player.Name)
return
end

-- Check stamina
if data.stamina < CONFIG.MIN_STAMINA_TO_SPRINT then
return
end

-- Start sprinting
data.isSprinting = true
data.currentWalkSpeed = CONFIG.SPRINT_SPEED
ApplyMovementValues(player)
end

-- Handle sprint stop request
local function OnRequestSprintStop(player: Player)
local data = PlayerData[player]
if not data then return end

-- Rate limit check
if not CheckRateLimit(data.sprintRequests,
CONFIG.MAX_SPRINT_REQUESTS_PER_SECOND) then
return
end

-- Stop sprinting
data.isSprinting = false
data.currentWalkSpeed = CONFIG.BASE_WALK_SPEED
ApplyMovementValues(player)
end

-- Handle movement input (for validation purposes)
local function OnRequestMovementInput(player: Player, input: any)
local data = PlayerData[player]
if not data then return end

-- Validate input
local isValid, validatedInput = ValidateInput(input)
if not isValid then
data.violations = data.violations + 1
warn("MovementServer: Invalid input from", player.Name, "-
Violations:", data.violations)

if data.violations >= CONFIG.VIOLATION_THRESHOLD then
Remotes.MovementViolation:FireClient(player,
"Invalid movement input detected")
-- Could add kick logic here
end
return
end

data.lastInput = validatedInput
data.lastInputTime = tick()
end

-- Position validation (anti-cheat)
local function ValidatePlayerPosition(player: Player)
local data = PlayerData[player]
if not data then return end

local character = player.Character
if not character then return end

local rootPart = character:FindFirstChild("HumanoidRootPart")
if not rootPart then return end

local currentPosition = rootPart.Position
local currentTime = tick()

if data.lastPosition then
local deltaTime = currentTime - data.lastPositionTime
local distance = (currentPosition -
data.lastPosition).Magnitude

-- Calculate max allowed distance
local maxSpeed = data.currentWalkSpeed *
CONFIG.MAX_SPEED_TOLERANCE
local maxDistance = maxSpeed * deltaTime + 5 -- 5 stud
buffer for physics

-- Check for teleportation
if distance > CONFIG.MAX_TELEPORT_DISTANCE then
data.violations = data.violations + 1
warn("MovementServer: Possible teleport detected
for", player.Name,
"Distance:", distance, "Violations:",
data.violations)

if data.violations >= CONFIG.VIOLATION_THRESHOLD
then
-- Teleport back to last valid position
rootPart.CFrame =
CFrame.new(data.lastPosition)
Remotes.MovementViolation:FireClient(playe
r, "Position violation detected")
end
-- Check for speed hacking
elseif distance > maxDistance and deltaTime > 0.05 then
data.violations = data.violations + 1
warn("MovementServer: Speed violation for",
player.Name,
"Speed:", distance/deltaTime, "Max:",
maxSpeed, "Violations:", data.violations)

if data.violations >= CONFIG.VIOLATION_THRESHOLD
then
rootPart.CFrame =
CFrame.new(data.lastPosition)
Remotes.MovementViolation:FireClient(playe
r, "Speed violation detected")
end
else
-- Valid movement, decay violations
data.violations = math.max(0, data.violations -
0.1)
end
end

data.lastPosition = currentPosition
data.lastPositionTime = currentTime
end

-- Update stamina and sprint state
local function UpdateStamina(player: Player, deltaTime: number)
local data = PlayerData[player]
if not data then return end

local previousStamina = data.stamina

if data.isSprinting then
-- Drain stamina
data.stamina = math.max(0, data.stamina -
CONFIG.STAMINA_DRAIN_RATE * deltaTime)

-- Stop sprinting if out of stamina
if data.stamina <= 0 then
data.isSprinting = false
data.currentWalkSpeed = CONFIG.BASE_WALK_SPEED
ApplyMovementValues(player)
end
else
-- Regenerate stamina
data.stamina = math.min(CONFIG.MAX_STAMINA, data.stamina +
CONFIG.STAMINA_REGEN_RATE * deltaTime)
end

-- Only send update if stamina changed significantly
if math.abs(data.stamina - previousStamina) > 0.5 then
Remotes.UpdateStamina:FireClient(player, data.stamina,
CONFIG.MAX_STAMINA)
end
end

-- Main update loop
local lastUpdateTime = tick()
local positionCheckAccumulator = 0

RunService.Heartbeat:Connect(function()
local currentTime = tick()
local deltaTime = currentTime - lastUpdateTime
lastUpdateTime = currentTime

positionCheckAccumulator = positionCheckAccumulator + deltaTime
local shouldCheckPosition = positionCheckAccumulator >=
CONFIG.POSITION_CHECK_INTERVAL

if shouldCheckPosition then
positionCheckAccumulator = 0
end

for player, data in pairs(PlayerData) do
-- Update stamina
UpdateStamina(player, deltaTime)

-- Position validation at reduced interval
if shouldCheckPosition then
ValidatePlayerPosition(player)
end
end
end)

-- Player connections
Players.PlayerAdded:Connect(function(player: Player)
InitializePlayerData(player)

player.CharacterAdded:Connect(function(character)
-- Reset position tracking on respawn
local data = PlayerData[player]
if data then
data.lastPosition = nil
data.lastPositionTime = 0
data.violations = 0
data.isSprinting = false
data.currentWalkSpeed = CONFIG.BASE_WALK_SPEED
data.stamina = CONFIG.MAX_STAMINA
end

-- Wait for humanoid and apply initial values
local humanoid = character:WaitForChild("Humanoid")
task.wait(0.1)
ApplyMovementValues(player)
end)
end)

Players.PlayerRemoving:Connect(CleanupPlayerData)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
InitializePlayerData(player)
end

-- Connect remote events
Remotes.RequestJump.OnServerEvent:Connect(OnRequestJump)
Remotes.RequestSprintStart.OnServerEvent:Connect(OnRequestSprintStart)
Remotes.RequestSprintStop.OnServerEvent:Connect(OnRequestSprintStop)
Remotes.RequestMovementInput.OnServerEvent:Connect(OnRequestMovementInput)

print("MovementServer: Initialized with server-authoritative
architecture")

return MovementServer
