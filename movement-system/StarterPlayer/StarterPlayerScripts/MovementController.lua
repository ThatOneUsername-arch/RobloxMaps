-- MovementController.lua
-- Main client-side movement coordinator (no direct control)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MovementController = {}

local LocalPlayer = Players.LocalPlayer

-- Wait for remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("MovementRemotes",
10)
if not RemotesFolder then
warn("MovementController: MovementRemotes folder not found!")
return
end

local Remotes = {
RequestMovementInput =
RemotesFolder:WaitForChild("RequestMovementInput"),
UpdateMovementState =
RemotesFolder:WaitForChild("UpdateMovementState"),
MovementViolation =
RemotesFolder:WaitForChild("MovementViolation"),
}

-- Configuration
local CONFIG = {
-- Input smoothing (visual only)
INPUT_SMOOTHING = 0.1,

-- Camera settings
CAMERA_SHAKE_ON_SPRINT = true,
CAMERA_SHAKE_INTENSITY = 0.1,

-- Input reporting interval
INPUT_REPORT_INTERVAL = 0.1,
}

-- Local state (display/feedback only, not authoritative)
local LocalState = {
walkSpeed = 16,
jumpPower = 50,
isSprinting = false,
moveDirection = Vector3.zero,
lastReportTime = 0,
}

-- REMOVED: Direct WalkSpeed/JumpPower setters
-- Server now controls these values directly on the Humanoid

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

-- NOTE: We do NOT modify humanoid values here
-- Server has already set them - this is just for local state
tracking
end

-- Handle movement violations
local function OnMovementViolation(message: string)
if typeof(message) ~= "string" then return end

warn("MovementController: Violation -", message)

-- Could display UI notification to player
-- Could trigger visual correction effect
end

-- Report movement input to server for validation
local function ReportMovementInput()
local currentTime = tick()
if currentTime - LocalState.lastReportTime <
CONFIG.INPUT_REPORT_INTERVAL then
return
end

local character = LocalPlayer.Character
if not character then return end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end

local moveDirection = humanoid.MoveDirection

-- Only report if changed
if moveDirection ~= LocalState.moveDirection then
LocalState.moveDirection = moveDirection
LocalState.lastReportTime = currentTime

-- Send to server for validation
Remotes.RequestMovementInput:FireServer(moveDirection)
end
end

-- Visual effects based on movement state (no physics changes)
local function UpdateVisualEffects(deltaTime: number)
if not CONFIG.CAMERA_SHAKE_ON_SPRINT then return end
if not LocalState.isSprinting then return end

local character = LocalPlayer.Character
if not character then return end

local humanoid = character:FindFirstChildOfClass("Humanoid")
if not humanoid then return end

-- Only shake camera if actually moving while sprinting
if humanoid.MoveDirection.Magnitude > 0.1 then
local camera = workspace.CurrentCamera
if camera then
local shake = Vector3.new(
(math.random() - 0.5) *
CONFIG.CAMERA_SHAKE_INTENSITY,
(math.random() - 0.5) *
CONFIG.CAMERA_SHAKE_INTENSITY * 0.5,
0
) * deltaTime * 60

-- Apply subtle camera shake (visual feedback
only)
camera.CFrame = camera.CFrame * CFrame.new(shake)
end
end
end

-- Getters for other scripts (read-only)
function MovementController.GetWalkSpeed(): number
return LocalState.walkSpeed
end

function MovementController.GetJumpPower(): number
return LocalState.jumpPower
end

function MovementController.IsSprinting(): boolean
return LocalState.isSprinting
end

function MovementController.GetMoveDirection(): Vector3
return LocalState.moveDirection
end

-- REMOVED: SetWalkSpeed function
-- REMOVED: SetJumpPower function
-- REMOVED: Direct humanoid modification
-- Server is now authoritative for all movement values

-- Connect events
Remotes.UpdateMovementState.OnClientEvent:Connect(OnUpdateMovementState)
Remotes.MovementViolation.OnClientEvent:Connect(OnMovementViolation)

-- Update loop
RunService.RenderStepped:Connect(function(deltaTime)
ReportMovementInput()
UpdateVisualEffects(deltaTime)
end)

-- Character added handling
LocalPlayer.CharacterAdded:Connect(function(character)
-- Reset local state on respawn
LocalState.moveDirection = Vector3.zero
LocalState.lastReportTime = 0

-- Wait for initial state from server
local humanoid = character:WaitForChild("Humanoid")

-- NOTE: We don't set any values here
-- Server will send UpdateMovementState with correct values
end)

print("MovementController: Initialized (no direct control,
server-authoritative)")

return MovementController
