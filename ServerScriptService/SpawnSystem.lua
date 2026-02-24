local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Config = require(script.Parent.Data.GameConfig)

local SPAWN_POSITION = Vector3.new(0, 10, 0)
local POWER_UPS = {"SpeedBoost", "DoubleDrops", "InstantMine", "Shield"}

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats
	
	local powerUp = Instance.new("StringValue")
	powerUp.Name = "PowerUp"
	powerUp.Value = POWER_UPS[math.random(1, #POWER_UPS)]
	powerUp.Parent = player
	
	player.CharacterAdded:Connect(function(character)
		local hrp = character:WaitForChild("HumanoidRootPart")
		hrp.CFrame = CFrame.new(SPAWN_POSITION)
		
		local pickaxe = ServerStorage:FindFirstChild("StarterPickaxe")
		if not pickaxe then
			warn("StarterPickaxe not found in ServerStorage")
			return
		end
		pickaxe:Clone().Parent = player.Backpack
	end)
end)
