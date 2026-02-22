-- Crystal Empire Economy System
local EconomySystem = {}

-- CORE CONSTANTS
local BASE_MINING_RATE = 1 -- crystals per second
local INFLATION_THRESHOLD = 0.15 -- 15% price increase trigger
local ECONOMY_BALANCE_TARGET = 0.6 -- 60% crystals should be in circulation

-- UPGRADE PROGRESSION FORMULAS
local PICKAXE_TIERS = {
    {cost = 0, multiplier = 1},
    {cost = 100, multiplier = 1.5},
    {cost = 500, multiplier = 2.2},
    {cost = 2500, multiplier = 3.5},
    {cost = 15000, multiplier = 5.5},
    {cost = 75000, multiplier = 8.5},
    {cost = 400000, multiplier = 13},
    {cost = 2000000, multiplier = 20},
    {cost = 10000000, multiplier = 30},
    {cost = 20000000, multiplier = 45}
}

local DRILL_TIERS = {
    {cost = 0, multiplier = 1, autoRate = 0},
    {cost = 1000, multiplier = 2, autoRate = 0.5},
    {cost = 5000, multiplier = 3, autoRate = 1.2},
    {cost = 25000, multiplier = 5, autoRate = 2.8},
    {cost = 125000, multiplier = 8, autoRate = 6.5},
    {cost = 625000, multiplier = 12, autoRate = 15},
    {cost = 3000000, multiplier = 18, autoRate = 35},
    {cost = 10000000, multiplier = 25, autoRate = 80}
}

-- MINING RATE CALCULATION
function EconomySystem.calculateMiningRate(pickaxeTier, drillTier, playerLevel)
    local pickaxeMultiplier = PICKAXE_TIERS[pickaxeTier + 1].multiplier
    local drillMultiplier = DRILL_TIERS[drillTier + 1].multiplier
    local levelBonus = 1 + (playerLevel * 0.02) -- 2% per level
    
    return BASE_MINING_RATE * pickaxeMultiplier * drillMultiplier * levelBonus
end

-- AUTO-MINING RATE
function EconomySystem.calculateAutoRate(drillTier, playerLevel)
    local autoRate = DRILL_TIERS[drillTier + 1].autoRate
    local levelBonus = 1 + (playerLevel * 0.015) -- 1.5% per level for auto
    
    return autoRate * levelBonus
end

-- DYNAMIC PRICING SYSTEM
function EconomySystem.calculateDynamicPrice(baseCost, marketDemand, totalSupply)
    local demandMultiplier = 1 + (marketDemand - 1) * 0.3 -- 30% price swing max
    local supplyMultiplier = math.max(0.7, 2 - (totalSupply / 1000000)) -- Supply pressure
    
    return math.floor(baseCost * demandMultiplier * supplyMultiplier)
end

-- ECONOMIC SINKS (What players spend crystals on)
local ECONOMIC_SINKS = {
    upgrades = 0.45, -- 45% of crystals spent on pickaxes/drills
    cosmetics = 0.20, -- 20% on skins, effects, trails
    boosters = 0.15, -- 15% on temporary multipliers
    trading = 0.10, -- 10% trading fees
    prestige = 0.10  -- 10% prestige system costs
}

-- INFLATION PREVENTION
function EconomySystem.checkInflation(currentPrices, historicalPrices)
    local inflationRate = (currentPrices - historicalPrices) / historicalPrices
    
    if inflationRate > INFLATION_THRESHOLD then
        return {
            adjustSupply = true,
            priceReduction = 0.85, -- 15% price cut
            bonusEvents = true -- Increase crystal generation events
        }
    end
    
    return {adjustSupply = false}
end

-- ECONOMY BALANCE CALCULATOR
function EconomySystem.calculateEconomyHealth(totalCrystalsGenerated, totalCrystalsSpent, activePlayers)
    local circulationRatio = totalCrystalsSpent / totalCrystalsGenerated
    local crystalsPerPlayer = totalCrystalsGenerated / activePlayers
    
    local healthScore = 1.0
    
    -- Penalize if too many crystals hoarded
    if circulationRatio < ECONOMY_BALANCE_TARGET then
        healthScore = healthScore * (circulationRatio / ECONOMY_BALANCE_TARGET)
    end
    
    -- Adjust for player wealth distribution
    if crystalsPerPlayer > 1000000 then -- High wealth threshold
        healthScore = healthScore * 0.9
    end
    
    return {
        score = healthScore,
        needsRebalance = healthScore < 0.7,
        recommendedAction = healthScore < 0.7 and "increase_sinks" or "maintain"
    }
end

-- PRESTIGE SYSTEM (Major crystal sink)
function EconomySystem.calculatePrestigeCost(currentPrestige)
    return math.floor(1000000 * math.pow(2.5, currentPrestige))
end

function EconomySystem.calculatePrestigeBonus(prestigeLevel)
    return 1 + (prestigeLevel * 0.25) -- 25% bonus per prestige
end

-- MARKET SIMULATION
function EconomySystem.simulateMarket(playerCount, avgPlayTime, days)
    local totalCrystalsGenerated = 0
    local totalCrystalsSpent = 0
    
    for day = 1, days do
        -- Daily generation
        local dailyGeneration = playerCount * avgPlayTime * 3600 * BASE_MINING_RATE * 2.5 -- avg multiplier
        totalCrystalsGenerated = totalCrystalsGenerated + dailyGeneration
        
        -- Daily spending (based on economic sinks)
        local dailySpending = dailyGeneration * 0.7 -- 70% of generated crystals spent
        totalCrystalsSpent = totalCrystalsSpent + dailySpending
    end
    
    return {
        generated = totalCrystalsGenerated,
        spent = totalCrystalsSpent,
        circulation = totalCrystalsSpent / totalCrystalsGenerated,
        avgWealth = (totalCrystalsGenerated - totalCrystalsSpent) / playerCount
    }
end

return EconomySystem