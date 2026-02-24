local Config = require(script.Parent.Data.GameConfig)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local powerUpRemote = ReplicatedStorage:WaitForChild("ActivatePowerUp")
local PowerUpSystem = require(script.Parent.PowerUpSystem)

powerUpRemote.OnServerEvent:Connect(function(player)
	PowerUpSystem.ActivatePowerUp(player)
end)
