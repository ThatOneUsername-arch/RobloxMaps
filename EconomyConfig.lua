-- Economy Configuration & Formulas
local Config = {}

-- MATHEMATICAL FORMULAS REFERENCE

--[[
CORE FORMULAS:

1. Mining Rate = BASE_RATE × PICKAXE_MULT × DRILL_MULT × (1 + LEVEL × 0.02)

2. Upgrade Cost Progression = BASE_COST × (GROWTH_RATE ^ TIER)
   - Pickaxes: Exponential growth ~2.5x per tier
   - Drills: Exponential growth ~3x per tier

3. Dynamic Pricing = BASE_COST × DEMAND_MULT × SUPPLY_MULT
   - Demand: 1 + (demand - 1) × 0.3
   - Supply: max(0.7, 2 - supply/1M)

4. Inflation Rate = (Current_Price - Historical_Price) / Historical_Price

5. Economy Health = CIRCULATION_RATIO / TARGET_RATIO × WEALTH_FACTOR

6. Prestige Cost = 1M × (2.5 ^ prestige_level)

7. Trading Fee = AMOUNT × BASE_FEE × VOLUME_MULTIPLIER
]]

-- BALANCE TARGETS
Config.TARGETS = {
    circulation_ratio = 0.6, -- 60% of crystals should be spent
    max_inflation = 0.15, -- 15% maximum price increase
    progression_rate = 2.5, -- crystals per hour target
    wealth_distribution = 0.3, -- Gini coefficient target
    prestige_frequency = 0.05 -- 5% of players should prestige weekly
}

-- ECONOMIC SINKS BREAKDOWN
Config.SINKS = {
    -- Primary sinks (permanent crystal removal)
    upgrades = {percentage = 45, permanent = true},
    prestige = {percentage = 10, permanent = true},
    
    -- Secondary sinks (temporary/cosmetic)
    cosmetics = {percentage = 20, permanent = false},
    boosters = {percentage = 15, permanent = false},
    
    -- Market sinks (redistribution)
    trading_fees = {percentage = 10, permanent = true}
}

-- REBALANCE THRESHOLDS
Config.REBALANCE = {
    emergency = {
        inflation_rate = 0.25, -- 25% inflation = emergency
        circulation_drop = 0.4, -- Below 40% circulation
        wealth_concentration = 0.8 -- Top 10% own 80% of crystals
    },
    
    warning = {
        inflation_rate = 0.15,
        circulation_drop = 0.5,
        wealth_concentration = 0.6
    }
}

return Config