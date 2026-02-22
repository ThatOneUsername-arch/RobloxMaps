-- Example Implementation
local Economy = require(script.CrystalEconomySystem)
local Monitor = require(script.BalanceMonitor)

-- PLAYER DATA EXAMPLE
local playerData = {
    crystals = 50000,
    pickaxeTier = 3,
    drillTier = 2,
    level = 15,
    prestigeLevel = 0,
    hoursPlayed = 25
}

-- CALCULATE CURRENT MINING RATES
local miningRate = Economy.calculateMiningRate(playerData.pickaxeTier, playerData.drillTier, playerData.level)
local autoRate = Economy.calculateAutoRate(playerData.drillTier, playerData.level)

print("Mining Rate:", miningRate, "crystals/second")
print("Auto Rate:", autoRate, "crystals/second")

-- CHECK UPGRADE COSTS
local nextPickaxeCost = Economy.PICKAXE_TIERS[playerData.pickaxeTier + 2].cost
local nextDrillCost = Economy.DRILL_TIERS[playerData.drillTier + 2].cost

print("Next Pickaxe Cost:", nextPickaxeCost)
print("Next Drill Cost:", nextDrillCost)

-- SIMULATE 30-DAY ECONOMY
local simulation = Economy.simulateMarket(1000, 2, 30) -- 1000 players, 2 hours avg, 30 days
print("30-Day Simulation:")
print("Generated:", simulation.generated)
print("Spent:", simulation.spent)
print("Circulation:", simulation.circulation)
print("Avg Wealth:", simulation.avgWealth)