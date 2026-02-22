-- Economy Balance Monitor
local BalanceMonitor = {}

-- REAL-TIME ECONOMY TRACKING
local economyData = {
    totalCrystals = 0,
    crystalsInCirculation = 0,
    averagePlayerWealth = 0,
    priceHistory = {},
    inflationRate = 0,
    lastRebalance = 0
}

-- AUTOMATIC REBALANCING TRIGGERS
function BalanceMonitor.checkRebalanceNeeds()
    local triggers = {
        inflation = economyData.inflationRate > 0.15,
        hoarding = (economyData.crystalsInCirculation / economyData.totalCrystals) < 0.5,
        wealth_gap = economyData.averagePlayerWealth > 5000000,
        time_based = tick() - economyData.lastRebalance > 86400 -- 24 hours
    }
    
    return triggers
end

-- DYNAMIC EVENT SYSTEM (Economic Stimulation)
local ECONOMY_EVENTS = {
    crystal_rush = {
        trigger = "low_circulation",
        effect = {multiplier = 2.0, duration = 3600}, -- 2x crystals for 1 hour
        cooldown = 21600 -- 6 hour cooldown
    },
    
    discount_day = {
        trigger = "high_inflation",
        effect = {priceReduction = 0.7, duration = 7200}, -- 30% off for 2 hours
        cooldown = 43200 -- 12 hour cooldown
    },
    
    bonus_prestige = {
        trigger = "wealth_accumulation",
        effect = {prestigeBonus = 1.5, duration = 1800}, -- 50% prestige bonus for 30 min
        cooldown = 86400 -- 24 hour cooldown
    }
}

-- PLAYER PROGRESSION BALANCE
function BalanceMonitor.calculateProgressionBalance(playerLevel, totalCrystals, hoursPlayed)
    local expectedWealth = hoursPlayed * 3600 * 2.5 -- Expected crystals per hour
    local actualRatio = totalCrystals / expectedWealth
    
    -- Progression health (1.0 = perfect, <0.8 = too slow, >1.5 = too fast)
    local progressionHealth = math.min(2.0, math.max(0.5, actualRatio))
    
    return {
        health = progressionHealth,
        recommendation = progressionHealth < 0.8 and "boost_rates" or 
                        progressionHealth > 1.5 and "add_sinks" or "balanced"
    }
end

-- TRADING SYSTEM INTEGRATION
function BalanceMonitor.calculateTradingFees(crystalAmount, marketVolume)
    local baseFee = 0.05 -- 5% base trading fee
    local volumeMultiplier = math.max(0.8, 1.2 - (marketVolume / 10000000)) -- Lower fees for high volume
    
    return math.floor(crystalAmount * baseFee * volumeMultiplier)
end

return BalanceMonitor