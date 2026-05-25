local Players = game:GetService("Players")
local Config = require(script.Parent.Data.GameConfig)
local ShopSystem = require(script.Parent.ShopSystem)

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

		local hasPickaxe = false
		for _, item in ipairs(player.Backpack:GetChildren()) do
			if item:IsA("Tool") and item.Name:find("Pickaxe") then
				hasPickaxe = true
				break
			end
		end

		if not hasPickaxe then
			local starterData = Config.Pickaxes.Starter
			local pickaxe = ShopSystem.CreatePickaxeTool("Starter", starterData)
			pickaxe.Parent = player.Backpack
		end
	end)
end)
