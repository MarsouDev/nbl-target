--[[
    NBL-TARGET EXAMPLES
    
    This file demonstrates all features of nbl-target.
    It is NOT included in fxmanifest.lua - copy what you need into your own resources.
    
    All examples use the exports API:
        exports['nbl-target']:exportName(...)
]]

-- ============================================================================
-- BASIC: Target any vehicle
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Lock/Unlock',
    icon = 'fas fa-lock',
    onSelect = function(data)
        print('Vehicle:', data.entity)
        print('Coords:', data.coords)
        print('Distance:', data.distance)
    end
})

-- ============================================================================
-- BASIC: Target any ped (NPC)
-- ============================================================================

exports['nbl-target']:addGlobalPed({
    label = 'Talk',
    icon = 'fas fa-comment',
    distance = 2.0,
    onSelect = function(data)
        print('Talking to ped:', data.entity)
    end
})

-- ============================================================================
-- BASIC: Target any player
-- ============================================================================

exports['nbl-target']:addGlobalPlayer({
    label = 'Give Money',
    icon = 'fas fa-money-bill',
    distance = 3.0,
    onSelect = function(data)
        local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
        print('Giving money to player server ID:', serverId)
    end
})

-- ============================================================================
-- BASIC: Target yourself
-- ============================================================================

exports['nbl-target']:addGlobalSelf({
    label = 'Open Inventory',
    icon = 'fas fa-backpack',
    onSelect = function(data)
        print('Opening inventory')
    end
})

-- ============================================================================
-- MODEL: Target specific object models (like ATMs)
-- ============================================================================

exports['nbl-target']:addModel({'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, {
    label = 'Access ATM',
    icon = 'fas fa-credit-card',
    distance = 1.5,
    onSelect = function(data)
        print('ATM model hash:', GetEntityModel(data.entity))
    end
})

-- ============================================================================
-- CUSTOM KEYS: Pass extra data to your callbacks
-- ============================================================================

-- Any key that isn't a reserved nbl-target key gets passed through to callbacks!
-- This is useful for storing metadata, IDs, flags, etc.

exports['nbl-target']:addModel('prop_vend_snak_01', {
    label = 'Buy Snack',
    icon = 'fas fa-cookie',
    
    -- Custom keys - these will be available in data.xxx
    itemName = 'snack',
    itemPrice = 50,
    shopType = 'vending',
    metadata = {
        category = 'food',
        restores = 10
    },
    
    onSelect = function(data)
        -- Access your custom keys directly from data
        print('Item:', data.itemName)           -- "snack"
        print('Price:', data.itemPrice)         -- 50
        print('Shop:', data.shopType)           -- "vending"
        print('Category:', data.metadata.category) -- "food"
        
        -- Standard keys are also available
        print('Entity:', data.entity)
        print('Distance:', data.distance)
    end
})

-- ============================================================================
-- CUSTOM KEYS: Complex example with zone info
-- ============================================================================

exports['nbl-target']:addGlobalObject({
    label = 'Collect',
    icon = 'fas fa-box',
    
    -- Your custom data
    zoneId = 'warehouse_01',
    jobRequired = 'trucker',
    payoutMin = 100,
    payoutMax = 500,
    cooldown = 300,
    
    canInteract = function(data)
        -- Use custom data in canInteract
        -- data.entity, data.coords, data.distance, data.bone, data.name
        -- + all your custom keys (jobRequired, zoneId, etc.)
        local job = GetPlayerJob() -- your framework function
        if job ~= data.jobRequired then
            return false
        end
        return true
    end,
    
    onSelect = function(data)
        local payout = math.random(data.payoutMin, data.payoutMax)
        print('Zone:', data.zoneId)
        print('Payout:', payout)
    end
})

-- ============================================================================
-- BONE TARGETING: Vehicle doors
-- ============================================================================

-- Show option only when aiming at specific vehicle bones
exports['nbl-target']:addGlobalVehicle({
    label = 'Open Door',
    icon = 'fas fa-door-open',
    distance = 2.0,
    
    -- Only show when aiming at these bones
    bones = {'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r'},
    
    onSelect = function(data)
        print('Opening door:', data.bone)
        -- data.bone contains the bone name you were aiming at
    end
})

-- ============================================================================
-- BONE TARGETING: Vehicle trunk
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Open Trunk',
    icon = 'fas fa-box-open',
    distance = 2.0,
    bones = {'boot'},
    
    onSelect = function(data)
        SetVehicleDoorOpen(data.entity, 5, false, false)
    end
})

-- ============================================================================
-- BONE TARGETING: Vehicle hood
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Check Engine',
    icon = 'fas fa-car-battery',
    distance = 2.0,
    bones = {'bonnet', 'engine'},
    
    onSelect = function(data)
        local health = GetVehicleEngineHealth(data.entity)
        print('Engine health:', health)
    end
})

-- ============================================================================
-- CONDITIONAL: Only show for certain jobs (ESX/QBCore)
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Impound Vehicle',
    icon = 'fas fa-truck-ramp-box',
    
    -- Framework conditions (handled automatically)
    job = 'police',           -- Single job
    -- job = {'police', 'sheriff'},  -- Multiple jobs
    -- job = { police = 2 },         -- Job with minimum grade
    
    onSelect = function(data)
        print('Impounding vehicle')
    end
})

-- ============================================================================
-- CONDITIONAL: canInteract callback
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Repair',
    icon = 'fas fa-wrench',
    
    canInteract = function(data)
        -- Only show if vehicle is damaged
        -- data.entity, data.distance, data.coords, data.bone, data.name
        local health = GetVehicleEngineHealth(data.entity)
        return health < 1000.0
    end,
    
    onSelect = function(data)
        SetVehicleEngineHealth(data.entity, 1000.0)
        SetVehicleFixed(data.entity)
        print('Vehicle repaired!')
    end
})

-- ============================================================================
-- HANDLER: Store and modify later
-- ============================================================================

local myHandler = exports['nbl-target']:addGlobalVehicle({
    name = 'my_unique_option',
    label = 'My Option',
    icon = 'fas fa-star',
    onSelect = function(data) end
})

-- Later, update it:
myHandler:setLabel('Updated Label')
myHandler:setIcon('fas fa-heart')
myHandler:setEnabled(false)
myHandler:setDistance(5.0)

-- Set any key (including custom ones):
myHandler:set('myCustomKey', 'new value')

-- Get values:
local label = myHandler:get('label')
local customData = myHandler:getData() -- returns table of custom keys only

-- Remove when done:
myHandler:remove()

-- ============================================================================
-- SUBMENUS: Nested options
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Vehicle Options',
    icon = 'fas fa-car',
    
    items = {
        {
            label = 'Lock',
            icon = 'fas fa-lock',
            onSelect = function(data)
                SetVehicleDoorsLocked(data.entity, 2)
            end
        },
        {
            label = 'Unlock',
            icon = 'fas fa-unlock',
            onSelect = function(data)
                SetVehicleDoorsLocked(data.entity, 0)
            end
        },
        {
            label = 'Engine',
            icon = 'fas fa-power-off',
            items = {
                {
                    label = 'Start',
                    icon = 'fas fa-play',
                    onSelect = function(data)
                        SetVehicleEngineOn(data.entity, true, true, false)
                    end
                },
                {
                    label = 'Stop',
                    icon = 'fas fa-stop',
                    onSelect = function(data)
                        SetVehicleEngineOn(data.entity, false, true, false)
                    end
                }
            }
        }
    }
})

-- ============================================================================
-- CHECKBOX: Toggle options
-- ============================================================================

local engineState = false

exports['nbl-target']:addGlobalVehicle({
    label = 'Engine Running',
    icon = 'fas fa-power-off',
    checkbox = true,
    checked = function() return engineState end,
    
    onCheck = function(data)
        -- data.checked contains the new checkbox state
        engineState = data.checked
        SetVehicleEngineOn(data.entity, data.checked, true, false)
    end
})

-- ============================================================================
-- EVENTS: Trigger events instead of callbacks
-- ============================================================================

exports['nbl-target']:addGlobalPed({
    label = 'Open Shop',
    icon = 'fas fa-store',
    event = 'myresource:openShop',  -- Client event
    
    -- Custom data passed to event
    shopId = 'general_store_1',
    shopType = 'general'
})

-- Your event handler:
AddEventHandler('myresource:openShop', function(data)
    print('Shop ID:', data.shopId)
    print('Entity:', data.entity)
end)

-- ============================================================================
-- SERVER EVENTS: Trigger server events
-- ============================================================================

exports['nbl-target']:addGlobalObject({
    label = 'Pickup Item',
    icon = 'fas fa-hand-grab',
    serverEvent = 'myresource:server:pickupItem',
    
    itemId = 'loot_123',
    quantity = 1
})

-- ============================================================================
-- EXPORTS: Call another resource's export
-- ============================================================================

exports['nbl-target']:addModel('prop_vend_water_01', {
    label = 'Buy Water',
    icon = 'fas fa-bottle-water',
    export = 'ox_inventory.openNearbyInventory',
    
    -- Data passed to the export
    itemName = 'water'
})

-- ============================================================================
-- SPECIFIC ENTITY: Target one spawned entity
-- ============================================================================

-- When you spawn an entity and want to add options just to it:
local myPed = CreatePed(4, `a_m_y_business_01`, 100.0, 200.0, 30.0, 0.0, false, true)

local entityHandler = exports['nbl-target']:addLocalEntity(myPed, {
    label = 'Talk to Bob',
    icon = 'fas fa-user',
    
    npcName = 'Bob',
    dialogue = 'quest_01',
    
    onSelect = function(data)
        print('Starting dialogue:', data.dialogue, 'with', data.npcName)
    end
})

-- Entity is automatically cleaned up when it no longer exists

-- ============================================================================
-- NAMED OPTIONS: Remove by name
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    name = 'police_cuff_option',
    label = 'Cuff Driver',
    icon = 'fas fa-handcuffs',
    job = 'police',
    onSelect = function(data) end
})

-- Later, remove by name:
exports['nbl-target']:removeByName('police_cuff_option')

-- ============================================================================
-- MULTIPLE OPTIONS: Register many at once
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    {
        label = 'Option 1',
        icon = 'fas fa-1',
        onSelect = function(data) end
    },
    {
        label = 'Option 2', 
        icon = 'fas fa-2',
        onSelect = function(data) end
    },
    {
        label = 'Option 3',
        icon = 'fas fa-3',
        onSelect = function(data) end
    }
})

-- ============================================================================
-- COMPLETE SHOP EXAMPLE
-- ============================================================================

local shops = {
    {
        model = 'prop_vend_soda_01',
        items = {
            { name = 'cola', label = 'Cola', price = 5, icon = 'fas fa-wine-bottle' },
            { name = 'sprunk', label = 'Sprunk', price = 5, icon = 'fas fa-wine-bottle' }
        }
    },
    {
        model = 'prop_vend_snak_01', 
        items = {
            { name = 'chips', label = 'Chips', price = 3, icon = 'fas fa-cookie' },
            { name = 'candy', label = 'Candy', price = 2, icon = 'fas fa-candy-cane' }
        }
    }
}

for _, shop in ipairs(shops) do
    local menuItems = {}
    
    for _, item in ipairs(shop.items) do
        menuItems[#menuItems + 1] = {
            label = item.label .. ' ($' .. item.price .. ')',
            icon = item.icon,
            
            -- Custom keys for each item
            itemName = item.name,
            itemPrice = item.price,
            
            onSelect = function(data)
                TriggerServerEvent('shop:buyItem', data.itemName, data.itemPrice)
            end
        }
    end
    
    exports['nbl-target']:addModel(shop.model, {
        label = 'Buy',
        icon = 'fas fa-shopping-cart',
        items = menuItems
    })
end

-- ============================================================================
-- COMPLETE VEHICLE MECHANIC EXAMPLE
-- ============================================================================

exports['nbl-target']:addGlobalVehicle({
    label = 'Mechanic',
    icon = 'fas fa-wrench',
    job = 'mechanic',
    distance = 3.0,
    
    items = {
        {
            label = 'Repair Engine',
            icon = 'fas fa-engine',
            cost = 500,
            repairType = 'engine',
            
            canInteract = function(data)
                return GetVehicleEngineHealth(data.entity) < 1000
            end,
            
            onSelect = function(data)
                print('Repairing engine, cost:', data.cost)
                SetVehicleEngineHealth(data.entity, 1000.0)
            end
        },
        {
            label = 'Repair Body',
            icon = 'fas fa-car-side',
            cost = 750,
            repairType = 'body',
            
            canInteract = function(data)
                return GetVehicleBodyHealth(data.entity) < 1000
            end,
            
            onSelect = function(data)
                print('Repairing body, cost:', data.cost)
                SetVehicleBodyHealth(data.entity, 1000.0)
            end
        },
        {
            label = 'Full Repair',
            icon = 'fas fa-car-burst',
            cost = 2000,
            repairType = 'full',
            
            onSelect = function(data)
                print('Full repair, cost:', data.cost)
                SetVehicleFixed(data.entity)
            end
        }
    }
})

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

-- Check if target is active
local isActive = exports['nbl-target']:isActive()

-- Check if menu is open
local menuOpen = exports['nbl-target']:isMenuOpen()

-- Get current target info
local target = exports['nbl-target']:getCurrentTarget()
if target then
    print('Entity:', target.entity)
    print('Type:', target.entityType)
    print('Coords:', target.worldPos)
    print('Bone:', target.bone)
end

-- Close menu programmatically
exports['nbl-target']:closeMenu()

-- Disable/enable targeting
exports['nbl-target']:disable()
exports['nbl-target']:enable()

-- Check if enabled
local enabled = exports['nbl-target']:isEnabled()

-- Deactivate (close everything)
exports['nbl-target']:deactivate()

