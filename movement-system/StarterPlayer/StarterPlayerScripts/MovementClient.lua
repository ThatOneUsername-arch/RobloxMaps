-- MovementClient.lua
-- Client-side movement handling (request-based, no direct control)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MovementClient = {}

local LocalPlayer = Players.LocalPlayer

-- Wait for remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("MovementRemotes",
10)
if not RemotesFolder then
warn("MovementClient: MovementRemotes folder not found!")
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

-- Local state (for UI display only, not authoritative)
local LocalState = {
walkSpeed = 16,
jumpPower = 50,
isSprinting = false,
stamina = 100,
maxStamina = 100,
}

-- Input state
local InputState = {
moveDirection = Vector3.zero,
wantsToSprint = false,
lastMoveInputTime = 0,
}

-- Configuration
local CONFIG = {
MOVE_INPUT_SEND_INTERVAL = 0.1, -- How often to send movement
input to server
}

-- Handle movement state updates from server
local function OnUpdateMovementState(state)
if typeof(state) ~= "table" then return end

if state.walkSpeed then
LocalState.walkSpeed = state.walkSpeed
end
if state.jumpPower then
LocalState.jumpPower = state.jumpPower
end
if state.isSprinting ~= nil then
LocalState.isSprinting = state.isSprinting
end

-- NOTE: We do NOT set humanoid values here - server handles that
-- This is purely for local UI/feedback purposes
end

-- Handle stamina updates from server
local function OnUpdateStamina(stamina: number, maxStamina: number)
if typeof(stamina) ~= "number" or typeof(maxStamina) ~= "number"
then return end

LocalState.stamina = stamina
LocalState.maxStamina = maxStamina

-- Update any UI here (stamina bar, etc.)
-- Example: StaminaUI:Update(stamina, maxStamina)
end

-- Handle movement violations from server
local function OnMovementViolation(message: string)
warn("MovementClient: Server violation -", message)
-- Could show UI warning to player
end

-- Get current movement input direction
local function GetMoveDirection(): Vector3
local character = LocalPlayer.Character
if not character then return Vector3.zero end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return Vector3.zero end

return humanoid.MoveDirection
end

-- Request jump from server (no local ApplyImpulse)
function MovementClient.RequestJump()
Remotes.RequestJump:FireServer()
end

-- Request sprint start from server
function MovementClient.RequestSprintStart()
if not InputState.wantsToSprint then
InputState.wantsToSprint = true
Remotes.RequestSprintStart:FireServer()
end
end

-- Request sprint stop from server
function MovementClient.RequestSprintStop()
if InputState.wantsToSprint then
InputState.wantsToSprint = false
Remotes.RequestSprintStop:FireServer()
end
end

-- Send movement input to server for validation
local function SendMovementInput()
local currentTime = tick()
if currentTime - InputState.lastMoveInputTime <
CONFIG.MOVE_INPUT_SEND_INTERVAL then
return
end

local moveDirection = GetMoveDirection()
if moveDirection ~= InputState.moveDirection then
InputState.moveDirection = moveDirection
InputState.lastMoveInputTime = currentTime
Remotes.RequestMovementInput:FireServer(moveDirection)
end
end

-- Input handling
local function OnInputBegan(input: InputObject, gameProcessed: boolean)
if gameProcessed then return end

-- Jump request (Space key)
if input.KeyCode == Enum.KeyCode.Space then
MovementClient.RequestJump()
end

-- Sprint request (Left Shift)
if input.KeyCode == Enum.KeyCode.LeftShift then
MovementClient.RequestSprintStart()
end
end

local function OnInputEnded(input: InputObject, gameProcessed: boolean)
-- Sprint stop (Left Shift released)
if input.KeyCode == Enum.KeyCode.LeftShift then
MovementClient.RequestSprintStop()
end
end

-- Getters for UI/other scripts (read-only local state)
function MovementClient.GetStamina(): (number, number)
return LocalState.stamina, LocalState.maxStamina
end

function MovementClient.GetStaminaPercent(): number
return LocalState.stamina / LocalState.maxStamina
end

function MovementClient.IsSprinting(): boolean
return LocalState.isSprinting
end

function MovementClient.GetWalkSpeed(): number
return LocalState.walkSpeed
end

-- Connect events
Remotes.UpdateMovementState.OnClientEvent:Connect(OnUpdateMovementState)
Remotes.UpdateStamina.OnClientEvent:Connect(OnUpdateStamina)
Remotes.MovementViolation.OnClientEvent:Connect(OnMovementViolation)

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputEnded:Connect(OnInputEnded)

-- Update loop for sending movement input
RunService.Heartbeat:Connect(function()
SendMovementInput()
end)

print("MovementClient: Initialized (request-based, server-authoritative)")

return MovementClient
