--[[
    NBL Context Menu - Test File
    
    This file creates test objects with target options.
    Uncomment the line in fxmanifest.lua to enable.
    
    Commands:
    /testpad - Create a test ped with options
    /testcar - Create a test car with options
    /cleartest - Remove all test objects
]]

local TestObjects = {}

-- ============================================================================
-- CREATE TEST PED
-- ============================================================================

RegisterCommand('testpad', function()
    -- Remove existing test ped
    if TestObjects.ped then
        if TestObjects.ped.entity and DoesEntityExist(TestObjects.ped.entity) then
            DeleteEntity(TestObjects.ped.entity)
        end
        for _, id in ipairs(TestObjects.ped.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
    end
    
    -- Get spawn position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnPos = playerCoords + forward * 2.0
    
    -- Load ped model (random NPC)
    local pedModels = {
        'a_m_m_skater_01',
        'a_m_y_hipster_01',
        'a_f_y_hipster_01',
        's_m_y_cop_01',
        's_m_m_paramedic_01'
    }
    local randomModel = pedModels[math.random(#pedModels)]
    local model = GetHashKey(randomModel)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    -- Create ped
    local ped = CreatePed(4, model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(playerPed), true, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    -- Store reference
    TestObjects.ped = {
        entity = ped,
        optionIds = {}
    }
    
    -- Add options
    local ids = TestObjects.ped.optionIds
    
    -- Option 1: Talk
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Talk",
        icon = "fas fa-comments",
        name = "test_talk",
        distance = 2.0,
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Talking to ped!")
            TaskTurnPedToFaceEntity(entity, PlayerPedId(), 2000)
            TaskLookAtEntity(entity, PlayerPedId(), 2000, 2048, 2)
        end
    })
    
    -- Option 2: Search
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Search",
        icon = "fas fa-hand-sparkles",
        name = "test_search",
        distance = 1.5,
        canInteract = function(entity, distance)
            -- Only show if very close
            return distance <= 1.5
        end,
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Searching ped!")
            local model = GetEntityModel(entity)
            print("^3[TEST]^7 Ped model: " .. model)
        end
    })
    
    -- Option 3: Give Item (with submenu)
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Give Item",
        icon = "fas fa-gift",
        name = "test_give",
        distance = 2.0,
        items = {
            {
                id = 9001,
                label = "Give Money",
                icon = "fas fa-dollar-sign"
            },
            {
                id = 9002,
                label = "Give Food",
                icon = "fas fa-utensils"
            },
            {
                id = 9003,
                label = "Give Weapon",
                icon = "fas fa-gun"
            }
        },
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Giving item to ped!")
        end
    })
    
    -- Option 4: Follow
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Follow Me",
        icon = "fas fa-walking",
        name = "test_follow",
        distance = 3.0,
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Ped will follow you!")
            TaskGoToEntity(entity, PlayerPedId(), -1, 2.0, 1.0, 1073741824, 0)
        end
    })
    
    -- Option 5: Delete
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Delete",
        icon = "fas fa-trash",
        name = "test_delete_ped",
        distance = 3.0,
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Deleting ped!")
            -- Remove options first
            for _, optId in ipairs(TestObjects.ped.optionIds) do
                exports['nbl-contextmenu']:removeEntity(optId)
            end
            -- Delete entity
            DeleteEntity(entity)
            TestObjects.ped = nil
        end
    })
    
    print("^2[TEST]^7 Test ped created with " .. #ids .. " options")
    print("^3[TEST]^7 Entity ID: " .. ped)
    print("^3[TEST]^7 Model: " .. randomModel)
    
end, false)

-- ============================================================================
-- CREATE TEST CAR
-- ============================================================================

RegisterCommand('testcar', function()
    -- Remove existing test car
    if TestObjects.car then
        if TestObjects.car.entity and DoesEntityExist(TestObjects.car.entity) then
            DeleteEntity(TestObjects.car.entity)
        end
        for _, id in ipairs(TestObjects.car.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
    end
    
    -- Get spawn position
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnPos = playerCoords + forward * 4.0
    
    -- Load model
    local model = GetHashKey('adder')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    -- Create vehicle
    local car = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(playerPed), true, true)
    
    -- Store reference
    TestObjects.car = {
        entity = car,
        optionIds = {}
    }
    
    -- Add options
    local ids = TestObjects.car.optionIds
    
    -- Option 1: Enter
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(car, {
        label = "Enter Vehicle",
        icon = "fas fa-car-side",
        name = "test_enter",
        distance = 3.0,
        onSelect = function(entity, coords)
            TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
        end
    })
    
    -- Option 2: Lock/Unlock
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(car, {
        label = "Lock / Unlock",
        icon = "fas fa-lock",
        name = "test_lock",
        distance = 5.0,
        onSelect = function(entity, coords)
            local locked = GetVehicleDoorLockStatus(entity)
            if locked == 2 then
                SetVehicleDoorsLocked(entity, 1)
                print("^2[TEST]^7 Vehicle unlocked!")
            else
                SetVehicleDoorsLocked(entity, 2)
                print("^2[TEST]^7 Vehicle locked!")
            end
        end
    })
    
    -- Option 3: Engine
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(car, {
        label = "Toggle Engine",
        icon = "fas fa-key",
        name = "test_engine",
        distance = 3.0,
        onSelect = function(entity, coords)
            local running = GetIsVehicleEngineRunning(entity)
            SetVehicleEngineOn(entity, not running, true, false)
            print("^2[TEST]^7 Engine " .. (running and "off" or "on") .. "!")
        end
    })
    
    -- Option 4: Delete
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(car, {
        label = "Delete Vehicle",
        icon = "fas fa-trash",
        name = "test_delete_car",
        distance = 5.0,
        onSelect = function(entity, coords)
            for _, optId in ipairs(TestObjects.car.optionIds) do
                exports['nbl-contextmenu']:removeEntity(optId)
            end
            DeleteEntity(entity)
            TestObjects.car = nil
            print("^2[TEST]^7 Vehicle deleted!")
        end
    })
    
    print("^2[TEST]^7 Test car created with " .. #ids .. " options")
    print("^3[TEST]^7 Entity ID: " .. car)
    
end, false)

-- ============================================================================
-- CLEAR ALL TEST OBJECTS
-- ============================================================================

RegisterCommand('cleartest', function()
    -- Clear ped
    if TestObjects.ped then
        if TestObjects.ped.entity and DoesEntityExist(TestObjects.ped.entity) then
            DeleteEntity(TestObjects.ped.entity)
        end
        for _, id in ipairs(TestObjects.ped.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
        TestObjects.ped = nil
    end
    
    -- Clear car
    if TestObjects.car then
        if TestObjects.car.entity and DoesEntityExist(TestObjects.car.entity) then
            DeleteEntity(TestObjects.car.entity)
        end
        for _, id in ipairs(TestObjects.car.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
        TestObjects.car = nil
    end
    
    print("^2[TEST]^7 All test objects cleared!")
    
end, false)

-- ============================================================================
-- ADD GLOBAL OPTIONS FOR TESTING
-- ============================================================================

CreateThread(function()
    Wait(1000)
    
    -- Global option for all objects
    exports['nbl-contextmenu']:addGlobalObject({
        label = "Examine Object",
        icon = "fas fa-eye",
        name = "global_examine",
        distance = 3.0,
        onSelect = function(entity, coords)
            local model = GetEntityModel(entity)
            print("^3[Global]^7 Object model: " .. model)
        end
    })
    
    -- Global option for all vehicles
    exports['nbl-contextmenu']:addGlobalVehicle({
        label = "Check Vehicle",
        icon = "fas fa-car",
        name = "global_check_vehicle",
        distance = 5.0,
        onSelect = function(entity, coords)
            local health = GetVehicleEngineHealth(entity)
            print("^3[Global]^7 Vehicle health: " .. math.floor(health))
        end
    })
    
    print("^2[TEST]^7 Global test options registered")
end)

