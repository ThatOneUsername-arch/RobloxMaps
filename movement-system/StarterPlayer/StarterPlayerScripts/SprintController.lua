-- SprintController.lua
-- Client-side sprint handling (UI-only, server tracks stamina)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SprintController = {}

local LocalPlayer = Players.LocalPlayer

-- Wait for remotes
local RemotesFolder = ReplicatedStorage:WaitForChild("MovementRemotes",
10)
if not RemotesFolder then
warn("SprintController: MovementRemotes folder not found!")
return
end

local Remotes = {
RequestSprintStart =
RemotesFolder:WaitForChild("RequestSprintStart"),
RequestSprintStop =
RemotesFolder:WaitForChild("RequestSprintStop"),
UpdateStamina = RemotesFolder:WaitForChild("UpdateStamina"),
UpdateMovementState =
RemotesFolder:WaitForChild("UpdateMovementState"),
}

-- Configuration (for UI only)
local CONFIG = {
STAMINA_BAR_WIDTH = 200,
STAMINA_BAR_HEIGHT = 20,
STAMINA_BAR_POSITION = UDim2.new(0.5, -100, 0.9, -30),

STAMINA_COLOR_FULL = Color3.fromRGB(0, 255, 100),
STAMINA_COLOR_MID = Color3.fromRGB(255, 255, 0),
STAMINA_COLOR_LOW = Color3.fromRGB(255, 50, 50),

LOW_STAMINA_THRESHOLD = 0.25,
MID_STAMINA_THRESHOLD = 0.5,

SHOW_STAMINA_BAR = true,
}

-- Local state (UI display only, server is authoritative)
local LocalState = {
stamina = 100,
maxStamina = 100,
isSprinting = false,
wantsToSprint = false, -- Player's input intent
}

-- UI Elements
local StaminaUI = nil

-- Create stamina bar UI
local function CreateStaminaUI()
if not CONFIG.SHOW_STAMINA_BAR then return end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SprintUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "StaminaContainer"
container.Size = UDim2.new(0, CONFIG.STAMINA_BAR_WIDTH, 0,
CONFIG.STAMINA_BAR_HEIGHT)
container.Position = CONFIG.STAMINA_BAR_POSITION
container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = container

local fill = Instance.new("Frame")
fill.Name = "StaminaFill"
fill.Size = UDim2.new(1, -4, 1, -4)
fill.Position = UDim2.new(0, 2, 0, 2)
fill.BackgroundColor3 = CONFIG.STAMINA_COLOR_FULL
fill.BorderSizePixel = 0
fill.Parent = container

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 3)
fillCorner.Parent = fill

local label = Instance.new("TextLabel")
label.Name = "StaminaLabel"
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "STAMINA"
label.TextColor3 = Color3.new(1, 1, 1)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = container

StaminaUI = {
Container = container,
Fill = fill,
Label = label,
}

return StaminaUI
end

-- Update stamina bar visual
local function UpdateStaminaUI()
if not StaminaUI then return end

local percent = LocalState.stamina / LocalState.maxStamina

-- Update fill width
local targetSize = UDim2.new(percent, -4, 1, -4)
local tween = TweenService:Create(StaminaUI.Fill,
TweenInfo.new(0.1), {Size = targetSize})
tween:Play()

-- Update color based on percentage
local targetColor
if percent <= CONFIG.LOW_STAMINA_THRESHOLD then
targetColor = CONFIG.STAMINA_COLOR_LOW
elseif percent <= CONFIG.MID_STAMINA_THRESHOLD then
-- Interpolate between low and mid
local t = (percent - CONFIG.LOW_STAMINA_THRESHOLD) /
(CONFIG.MID_STAMINA_THRESHOLD - CONFIG.LOW_STAMINA_THRESHOLD)
targetColor =
CONFIG.STAMINA_COLOR_LOW:Lerp(CONFIG.STAMINA_COLOR_MID, t)
else
-- Interpolate between mid and full
local t = (percent - CONFIG.MID_STAMINA_THRESHOLD) / (1 -
CONFIG.MID_STAMINA_THRESHOLD)
targetColor =
CONFIG.STAMINA_COLOR_MID:Lerp(CONFIG.STAMINA_COLOR_FULL, t)
end

local colorTween = TweenService:Create(StaminaUI.Fill,
TweenInfo.new(0.2), {BackgroundColor3 = targetColor})
colorTween:Play()

-- Update label
StaminaUI.Label.Text = string.format("STAMINA: %d%%",
math.floor(percent * 100))
end

-- Handle stamina updates from server (authoritative)
local function OnUpdateStamina(stamina: number, maxStamina: number)
if typeof(stamina) ~= "number" or typeof(maxStamina) ~= "number"
then return end

LocalState.stamina = stamina
LocalState.maxStamina = maxStamina

UpdateStaminaUI()
end

-- Handle movement state updates from server
local function OnUpdateMovementState(state)
if typeof(state) ~= "table" then return end

if state.isSprinting ~= nil then
LocalState.isSprinting = state.isSprinting
end

-- NOTE: Server is authoritative - we just update UI here
end

-- Request sprint start (server validates and tracks stamina)
function SprintController.RequestSprintStart()
if LocalState.wantsToSprint then return end

LocalState.wantsToSprint = true
Remotes.RequestSprintStart:FireServer()
end

-- Request sprint stop
function SprintController.RequestSprintStop()
if not LocalState.wantsToSprint then return end

LocalState.wantsToSprint = false
Remotes.RequestSprintStop:FireServer()
end

-- REMOVED: Local stamina tracking
-- Server now handles all stamina calculations

-- REMOVED: Direct WalkSpeed modification
-- Server controls WalkSpeed through MovementServer.lua

-- Getters for other scripts (read-only)
function SprintController.GetStamina(): number
return LocalState.stamina
end

function SprintController.GetMaxStamina(): number
return LocalState.maxStamina
end

function SprintController.GetStaminaPercent(): number
return LocalState.stamina / LocalState.maxStamina
end

function SprintController.IsSprinting(): boolean
return LocalState.isSprinting
end

function SprintController.WantsToSprint(): boolean
return LocalState.wantsToSprint
end

-- Input handling
local function OnInputBegan(input: InputObject, gameProcessed: boolean)
if gameProcessed then return end

if input.KeyCode == Enum.KeyCode.LeftShift then
SprintController.RequestSprintStart()
end
end

local function OnInputEnded(input: InputObject, gameProcessed: boolean)
if input.KeyCode == Enum.KeyCode.LeftShift then
SprintController.RequestSprintStop()
end
end

-- Connect events
Remotes.UpdateStamina.OnClientEvent:Connect(OnUpdateStamina)
Remotes.UpdateMovementState.OnClientEvent:Connect(OnUpdateMovementState)

UserInputService.InputBegan:Connect(OnInputBegan)
UserInputService.InputEnded:Connect(OnInputEnded)

-- Initialize UI
CreateStaminaUI()
UpdateStaminaUI()

print("SprintController: Initialized (UI-only, server-authoritative
stamina)")

return SprintController
