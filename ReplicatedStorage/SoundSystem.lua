-- SoundSystem: Creates sounds in SoundService accessible to all scripts
-- NOTE: This must be a ModuleScript in Roblox Studio
local SoundService = game:GetService("SoundService")

local sounds = {}

sounds.MineHit = Instance.new("Sound")
sounds.MineHit.SoundId = "rbxassetid://4843088994"
sounds.MineHit.Volume = 0.3
sounds.MineHit.Parent = SoundService

sounds.CrystalBreak = Instance.new("Sound")
sounds.CrystalBreak.SoundId = "rbxassetid://3581383408"
sounds.CrystalBreak.Volume = 0.5
sounds.CrystalBreak.Parent = SoundService

sounds.CoinCollect = Instance.new("Sound")
sounds.CoinCollect.SoundId = "rbxassetid://5153845714"
sounds.CoinCollect.Volume = 0.4
sounds.CoinCollect.Parent = SoundService

sounds.Purchase = Instance.new("Sound")
sounds.Purchase.SoundId = "rbxassetid://5153845714"
sounds.Purchase.Volume = 0.5
sounds.Purchase.Parent = SoundService

sounds.PowerUpActivate = Instance.new("Sound")
sounds.PowerUpActivate.SoundId = "rbxassetid://6895079853"
sounds.PowerUpActivate.Volume = 0.6
sounds.PowerUpActivate.Parent = SoundService

sounds.PortalUnlock = Instance.new("Sound")
sounds.PortalUnlock.SoundId = "rbxassetid://6895079853"
sounds.PortalUnlock.Volume = 0.7
sounds.PortalUnlock.Parent = SoundService

return {
	PlaySound = function(soundName)
		local sound = sounds[soundName]
		if sound then
			sound:Play()
		end
	end
}
