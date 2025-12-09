local TestObjects = {}

RegisterCommand('testped', function()
    if TestObjects.ped then
        if TestObjects.ped.entity and DoesEntityExist(TestObjects.ped.entity) then
            DeleteEntity(TestObjects.ped.entity)
        end
        for _, id in ipairs(TestObjects.ped.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnPos = playerCoords + forward * 2.0
    
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
    
    local ped = CreatePed(4, model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(playerPed), true, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    TestObjects.ped = {
        entity = ped,
        optionIds = {}
    }
    
    local ids = TestObjects.ped.optionIds
    
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
    
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Search",
        icon = "fas fa-hand-sparkles",
        name = "test_search",
        distance = 1.5,
        canInteract = function(entity, distance)
            return distance <= 1.5
        end,
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Searching ped!")
            local model = GetEntityModel(entity)
            print("^3[TEST]^7 Ped model: " .. model)
        end
    })
    
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Give Item",
        icon = "fas fa-gift",
        name = "test_give",
        distance = 2.0,
        items = {
            {
                id = 9001,
                label = "Give Money",
                icon = "fas fa-dollar-sign",
                canInteract = function(entity, distance)
                    return distance <= 2.0
                end
            },
            {
                id = 9002,
                label = "Give Food",
                icon = "fas fa-utensils"
            },
            {
                id = 9003,
                label = "Give Weapon",
                icon = "fas fa-gun",
                canInteract = function(entity, distance)
                    return distance <= 1.0
                end
            }
        },
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Giving item to ped!")
        end
    })
    
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
    
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(ped, {
        label = "Delete",
        icon = "fas fa-trash",
        name = "test_delete_ped",
        distance = 3.0,
        shouldClose = true,
        onSelect = function(entity, coords)
            print("^2[TEST]^7 Deleting ped!")
            for _, optId in ipairs(TestObjects.ped.optionIds) do
                exports['nbl-contextmenu']:removeEntity(optId)
            end
            DeleteEntity(entity)
            TestObjects.ped = nil
        end
    })
    
    print("^2[TEST]^7 Test ped created with " .. #ids .. " options")
    print("^3[TEST]^7 Entity ID: " .. ped)
    print("^3[TEST]^7 Model: " .. randomModel)
    
end, false)

RegisterCommand('testcar', function()
    if TestObjects.car then
        if TestObjects.car.entity and DoesEntityExist(TestObjects.car.entity) then
            DeleteEntity(TestObjects.car.entity)
        end
        for _, id in ipairs(TestObjects.car.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnPos = playerCoords + forward * 4.0
    
    local model = GetHashKey('adder')
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end
    
    local car = CreateVehicle(model, spawnPos.x, spawnPos.y, spawnPos.z, GetEntityHeading(playerPed), true, true)
    
    TestObjects.car = {
        entity = car,
        optionIds = {}
    }
    
    local ids = TestObjects.car.optionIds
    
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(car, {
        label = "Enter Vehicle",
        icon = "fas fa-car-side",
        name = "test_enter",
        distance = 3.0,
        shouldClose = true,
        onSelect = function(entity, coords)
            TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
        end
    })
    
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
    
    ids[#ids + 1] = exports['nbl-contextmenu']:addEntity(car, {
        label = "Delete Vehicle",
        icon = "fas fa-trash",
        name = "test_delete_car",
        distance = 5.0,
        shouldClose = true,
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

RegisterCommand('cleartest', function()
    if TestObjects.ped then
        if TestObjects.ped.entity and DoesEntityExist(TestObjects.ped.entity) then
            DeleteEntity(TestObjects.ped.entity)
        end
        for _, id in ipairs(TestObjects.ped.optionIds or {}) do
            exports['nbl-contextmenu']:removeEntity(id)
        end
        TestObjects.ped = nil
    end
    
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

CreateThread(function()
    Wait(1000)
    
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
    
    exports['nbl-contextmenu']:addGlobalSelf({
        label = "Check Health",
        icon = "fas fa-heart",
        name = "self_check_health",
        distance = 5.0,
        onSelect = function(entity, coords)
            local health = GetEntityHealth(entity)
            print("^3[Self]^7 Your health: " .. health)
        end
    })
    
    exports['nbl-contextmenu']:addGlobalSelf({
        label = "Play Animation",
        icon = "fas fa-person-walking",
        name = "self_animation",
        distance = 5.0,
        shouldClose = true,
        onSelect = function(entity, coords)
            print("^3[Self]^7 Playing animation!")
            TaskStartScenarioInPlace(entity, "WORLD_HUMAN_CHEERING", 0, true)
        end
    })
    
    print("^2[TEST]^7 Global test options registered")
end)
