-- MovementRemotes.lua
-- Centralized RemoteEvent definitions for movement system
-- Place in ReplicatedStorage

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MovementRemotes = {}

-- Create folder for organization
local RemotesFolder = Instance.new("Folder")
RemotesFolder.Name = "MovementRemotes"
RemotesFolder.Parent = ReplicatedStorage

-- RemoteEvents for client -> server requests
local RequestJump = Instance.new("RemoteEvent")
RequestJump.Name = "RequestJump"
RequestJump.Parent = RemotesFolder

local RequestSprintStart = Instance.new("RemoteEvent")
RequestSprintStart.Name = "RequestSprintStart"
RequestSprintStart.Parent = RemotesFolder

local RequestSprintStop = Instance.new("RemoteEvent")
RequestSprintStop.Name = "RequestSprintStop"
RequestSprintStop.Parent = RemotesFolder

local RequestMovementInput = Instance.new("RemoteEvent")
RequestMovementInput.Name = "RequestMovementInput"
RequestMovementInput.Parent = RemotesFolder

-- RemoteEvents for server -> client updates
local UpdateMovementState = Instance.new("RemoteEvent")
UpdateMovementState.Name = "UpdateMovementState"
UpdateMovementState.Parent = RemotesFolder

local UpdateStamina = Instance.new("RemoteEvent")
UpdateStamina.Name = "UpdateStamina"
UpdateStamina.Parent = RemotesFolder

local MovementViolation = Instance.new("RemoteEvent")
MovementViolation.Name = "MovementViolation"
MovementViolation.Parent = RemotesFolder

-- Export references
MovementRemotes.Folder = RemotesFolder
MovementRemotes.RequestJump = RequestJump
MovementRemotes.RequestSprintStart = RequestSprintStart
MovementRemotes.RequestSprintStop = RequestSprintStop
MovementRemotes.RequestMovementInput = RequestMovementInput
MovementRemotes.UpdateMovementState = UpdateMovementState
MovementRemotes.UpdateStamina = UpdateStamina
MovementRemotes.MovementViolation = MovementViolation

return MovementRemotes
