
local function RegisterExport(name, fn)
    local success, err = pcall(function()
        AddEventHandler(('__cfx_export_qb-target_%s'):format(name), function(setCB)
            setCB(fn)
        end)
    end)
    if not success then
        print('^1[nbl-target] Failed to register qb-target export "' .. name .. '": ' .. tostring(err) .. '^7')
    end
end

local function RegisterQTargetExport(name, fn)
    local success, err = pcall(function()
        AddEventHandler(('__cfx_export_qtarget_%s'):format(name), function(setCB)
            setCB(fn)
        end)
    end)
    if not success then
        print('^1[nbl-target] Failed to register qtarget export "' .. name .. '": ' .. tostring(err) .. '^7')
    end
end

local function RegisterBothExports(name, fn)
    RegisterExport(name, fn)
    RegisterQTargetExport(name, fn)
end


local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local success, result = pcall(fn, ...)
    if not success then
        if Config and Config.Debug and Config.Debug.enabled then
            print('^1[nbl-target] qb-target bridge callback error: ' .. tostring(result) .. '^7')
        end
        return nil
    end
    return result
end

local function IsValidEntity(entity)
    if not entity then return false end
    if type(entity) ~= "number" then return false end
    if entity == 0 then return false end
    return true
end

local function IsValidTable(t)
    return t ~= nil and type(t) == "table"
end

local function TableLength(t)
    if not IsValidTable(t) then return 0 end
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function ShallowCopy(t)
    if not IsValidTable(t) then return {} end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

local function IsOptionObject(t)
    if not IsValidTable(t) then return false end
    return t.label ~= nil or t.name ~= nil or t.icon ~= nil or 
           t.action ~= nil or t.event ~= nil or t.canInteract ~= nil
end

local function IsOptionsArray(t)
    if not IsValidTable(t) then return false end
    local hasNumericKeys = false
    for k, v in pairs(t) do
        if type(k) == "number" then
            hasNumericKeys = true
            if IsValidTable(v) and (v.label or v.name or v.action or v.event) then
                return true
            end
        end
    end
    return hasNumericKeys
end


local function CreateDataObject(entity, coords, opt)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local entityCoords
    if coords and type(coords) == "vector3" then
        entityCoords = coords
    elseif IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
        entityCoords = GetEntityCoords(entity)
    else
        entityCoords = playerCoords
    end
    
    local dist = 0.0
    if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
        dist = #(playerCoords - entityCoords)
    elseif coords then
        dist = #(playerCoords - entityCoords)
    end
    
    local entityModel = nil
    local entityType = nil
    if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
        entityModel = GetEntityModel(entity)
        entityType = GetEntityType(entity)
    end
    
    local data = {
        entity = entity or 0,
        coords = entityCoords,
        distance = dist,
        model = entityModel,
        hash = entityModel,
        type = entityType,
        bone = nil,
        name = opt and (opt.name or opt.label) or nil,
        label = opt and opt.label or nil
    }
    
    if IsValidTable(opt) then
        for k, v in pairs(opt) do
            if data[k] == nil and type(v) ~= "function" then
                data[k] = v
            end
        end
    end
    
    return data
end


local function ConvertOption(opt, defaultDist)
    if not IsValidTable(opt) then
        return nil
    end
    
    if not opt.label and not opt.name and not opt.action and not opt.event then
        return nil
    end
    
    local converted = {
        label = opt.label or opt.name or "Interact",
        name = opt.name or opt.label,
        icon = opt.icon or opt.targeticon,
        distance = opt.distance or defaultDist,
        shouldClose = true
    }
    
    if opt.job then
        converted.job = opt.job
    end
    
    if opt.gang then
        converted.gang = opt.gang
    end
    
    if opt.item then
        converted.requiredItem = opt.item
    end
    
    if opt.canInteract then
        local original = opt.canInteract
        converted.canInteract = function(entity, distance, coords, name, bone)
            local data = CreateDataObject(entity, coords, opt)
            data.distance = distance
            data.bone = bone
            
            local ok, result = pcall(original, entity, distance, data)
            if ok then
                return result == true or result == nil
            end
            
            ok, result = pcall(original, data)
            if ok then
                return result == true or result == nil
            end
            
            ok, result = pcall(original, entity)
            if ok then
                return result == true or result == nil
            end
            
            if Config and Config.Debug and Config.Debug.enabled then
                print('^3[nbl-target] qb-target canInteract error for "' .. tostring(opt.label) .. '"^7')
            end
            return false
        end
    end
    
    if opt.action then
        local original = opt.action
        converted.onSelect = function(entity, coords, reg)
            local data = CreateDataObject(entity, coords, opt)
            
            local ok, err = pcall(original, data)
            if not ok then
                ok, err = pcall(original, entity)
            end
            
            if not ok then
                print('^1[nbl-target] qb-target action error: ' .. tostring(err) .. '^7')
            end
        end
    elseif opt.event then
        local eventType = opt.type or "client"
        
        if eventType == "server" then
            converted.onSelect = function(entity, coords, reg)
                local data = CreateDataObject(entity, coords, opt)
                TriggerServerEvent(opt.event, data)
            end
        elseif eventType == "command" then
            converted.command = opt.event
        elseif eventType == "qbcommand" then
            converted.onSelect = function(entity, coords, reg)
                ExecuteCommand(opt.event)
            end
        else
            converted.onSelect = function(entity, coords, reg)
                local data = CreateDataObject(entity, coords, opt)
                TriggerEvent(opt.event, data)
            end
        end
    end
    
    return converted
end

local function ConvertOptions(options, defaultDist)
    if not options then return {} end
    
    local result = {}
    local idx = 0
    
    local opts = options
    local dist = defaultDist or Config.Target.defaultDistance
    
    if IsValidTable(options) then
        if options.options then
            opts = options.options
            dist = options.distance or dist
        end
        if options.distance and type(options.distance) == "number" then
            dist = options.distance
        end
    end
    
    if IsOptionObject(opts) and not IsOptionsArray(opts) and not opts.options then
        local converted = ConvertOption(opts, dist)
        if converted then
            result[1] = converted
        end
        return result
    end
    
    if IsValidTable(opts) then
        for k, opt in pairs(opts) do
            if IsValidTable(opt) then
                local converted = ConvertOption(opt, dist)
                if converted then
                    idx = idx + 1
                    result[idx] = converted
                end
            end
        end
    end
    
    return result
end


local Handlers = {}

local function StoreHandler(key, handler, label)
    if not handler then return end
    if not Handlers[key] then Handlers[key] = {} end
    Handlers[key][#Handlers[key] + 1] = {h = handler, l = label}
end

local function RemoveHandlers(key, labels)
    if not Handlers[key] then return end
    
    if labels then
        local labelsToRemove = type(labels) ~= "table" and {labels} or labels
        local labelSet = {}
        for i = 1, #labelsToRemove do
            if labelsToRemove[i] then
                labelSet[labelsToRemove[i]] = true
            end
        end
        
        local keep = {}
        for i = 1, #Handlers[key] do
            local item = Handlers[key][i]
            if item then
                if item.l and labelSet[item.l] then
                    if item.h then
                        if type(item.h.remove) == "function" then
                            pcall(item.h.remove, item.h)
                        elseif type(item.h) == "table" and item.h.remove then
                            pcall(function() item.h:remove() end)
                        end
                    end
                else
                    keep[#keep + 1] = item
                end
            end
        end
        
        if #keep > 0 then
            Handlers[key] = keep
        else
            Handlers[key] = nil
        end
    else
        for i = 1, #Handlers[key] do
            local item = Handlers[key][i]
            if item and item.h then
                if type(item.h.remove) == "function" then
                    pcall(item.h.remove, item.h)
                elseif type(item.h) == "table" and item.h.remove then
                    pcall(function() item.h:remove() end)
                end
            end
        end
        Handlers[key] = nil
    end
end

local function GetHandlerKey(prefix, identifier)
    if type(identifier) == "string" then
        return prefix .. "_" .. identifier
    elseif type(identifier) == "number" then
        return prefix .. "_" .. tostring(identifier)
    else
        return prefix
    end
end


local ZoneWarnings = {}

local function WarnZone(zoneName, zoneType)
    local key = tostring(zoneType) .. "_" .. tostring(zoneName)
    if not ZoneWarnings[key] then
        ZoneWarnings[key] = true
        print('^3[nbl-target] ' .. tostring(zoneType or "Zone") .. ' "' .. tostring(zoneName) .. '" not supported - use entity targeting instead^7')
    end
    return nil
end


local function AddTargetEntity(entities, options)
    if not entities then return end
    if not options then return end
    
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    
    if #converted == 0 then return end
    
    local entityList = entities
    if type(entities) ~= "table" then
        entityList = {entities}
    end
    
    for e = 1, #entityList do
        local entity = entityList[e]
        if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
            local key = GetHandlerKey("entity", entity)
            
            for i = 1, #converted do
                local handler = nil
                local success, err = pcall(function()
                    if NetworkGetEntityIsNetworked(entity) then
                        handler = exports['nbl-target']:addEntity(entity, converted[i])
                    else
                        handler = exports['nbl-target']:addLocalEntity(entity, converted[i])
                    end
                end)
                
                if success and handler then
                    StoreHandler(key, handler, converted[i].label)
                elseif not success then
                    print('^1[nbl-target] AddTargetEntity error: ' .. tostring(err) .. '^7')
                end
            end
        end
    end
end

local function RemoveTargetEntity(entities, labels)
    if entities == nil then return end
    
    local entityList = type(entities) ~= "table" and {entities} or entities
    
    for e = 1, #entityList do
        local entity = entityList[e]
        if entity ~= nil then
            RemoveHandlers(GetHandlerKey("entity", entity), labels)
        end
    end
end


local function AddTargetModel(models, options)
    if not models then return end
    if not options then return end
    
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    
    if #converted == 0 then return end
    
    local modelList = models
    if type(models) ~= "table" then
        modelList = {models}
    end
    
    for m = 1, #modelList do
        local model = modelList[m]
        if model then
            local modelHash = model
            if type(model) == "string" then
                modelHash = GetHashKey(model)
            end
            
            local key = GetHandlerKey("model", modelHash)
            
            for i = 1, #converted do
                local success, handler = pcall(function()
                    return exports['nbl-target']:addModel(modelHash, converted[i])
                end)
                
                if success and handler then
                    StoreHandler(key, handler, converted[i].label)
                end
            end
        end
    end
end

local function RemoveTargetModel(models, labels)
    if not models then return end
    
    local modelList = type(models) ~= "table" and {models} or models
    
    for m = 1, #modelList do
        local model = modelList[m]
        if model then
            local modelHash = type(model) == "string" and GetHashKey(model) or model
            RemoveHandlers(GetHandlerKey("model", modelHash), labels)
        end
    end
end


local function AddGlobalPed(options)
    if not options then return end
    
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalPed(converted[i])
        end)
        
        if success and handler then
            StoreHandler("globalPed", handler, converted[i].label)
        end
    end
end

local function AddGlobalVehicle(options)
    if not options then return end
    
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalVehicle(converted[i])
        end)
        
        if success and handler then
            StoreHandler("globalVehicle", handler, converted[i].label)
        end
    end
end

local function AddGlobalObject(options)
    if not options then return end
    
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalObject(converted[i])
        end)
        
        if success and handler then
            StoreHandler("globalObject", handler, converted[i].label)
        end
    end
end

local function AddGlobalPlayer(options)
    if not options then return end
    
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalPlayer(converted[i])
        end)
        
        if success and handler then
            StoreHandler("globalPlayer", handler, converted[i].label)
        end
    end
end


local BoneWarned = false

local function AddTargetBone(bones, options)
    if not BoneWarned then
        BoneWarned = true
        print('^3[nbl-target] Bone targeting not supported - use entity or model targeting instead^7')
    end
    return nil
end

local function RemoveTargetBone(bones, labels)
    return nil
end


local function AddEntityZone(name, entity, options, targetoptions)
    if not name then return nil end
    if not IsValidEntity(entity) then return nil end
    
    local opts = targetoptions or options
    if not opts then return nil end
    
    local dist = opts.distance or 2.0
    local converted = ConvertOptions(opts, dist)
    
    if #converted == 0 then return nil end
    
    local key = GetHandlerKey("entityzone", name)
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            if NetworkGetEntityIsNetworked(entity) then
                return exports['nbl-target']:addEntity(entity, converted[i])
            else
                return exports['nbl-target']:addLocalEntity(entity, converted[i])
            end
        end)
        
        if success and handler then
            StoreHandler(key, handler, converted[i].label)
        end
    end
    
    return name
end

local function RemoveEntityZone(name)
    if name then
        RemoveHandlers(GetHandlerKey("entityzone", name))
    end
end

local function AddBoxZone(name, coords, length, width, options, targetoptions)
    return WarnZone(name, "BoxZone")
end

local function AddCircleZone(name, coords, radius, options, targetoptions)
    return WarnZone(name, "CircleZone")
end

local function AddPolyZone(name, points, options, targetoptions)
    return WarnZone(name, "PolyZone")
end

local function RemoveZone(name)
    if name then
        RemoveHandlers(GetHandlerKey("entityzone", name))
    end
    return nil
end


local function SpawnPed(data)
    print('^3[nbl-target] SpawnPed not supported - use your own ped spawning system^7')
    return nil
end

local function DeletePed(pedName)
    return nil
end


local function AllowTargeting(state)
    local success, err = pcall(function()
        if state == false then
            exports['nbl-target']:disable()
        else
            exports['nbl-target']:enable()
        end
    end)
    
    if not success then
        print('^1[nbl-target] AllowTargeting error: ' .. tostring(err) .. '^7')
    end
end

local function IsTargetActive()
    local success, result = pcall(function()
        return exports['nbl-target']:isActive()
    end)
    return success and result or false
end

local function IsTargetSuccess()
    local success, result = pcall(function()
        return exports['nbl-target']:isMenuOpen()
    end)
    return success and result or false
end

local function GetTargetEntity()
    local success, result = pcall(function()
        return exports['nbl-target']:getSelectedEntity()
    end)
    return success and result or nil
end

local function GetEntityZone(entity)
    return nil
end


local function RaycastCamera(flag, playerCoords)
    local success, hit, pos, entity
    
    success = pcall(function()
        local cursorPos = vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
        hit, pos, _, entity = Raycast:FromScreen(cursorPos, 100.0, flag or 287)
    end)
    
    if success and hit and entity and entity ~= 0 then
        local dist = playerCoords and #(playerCoords - pos) or 0.0
        return pos, dist, entity, GetEntityType(entity)
    end
    
    return playerCoords or vector3(0, 0, 0), 0.0, 0, 0
end


local function RemoveType(entityType, labels)
    local typeMap = {
        [1] = "globalPed",
        [2] = "globalVehicle",
        [3] = "globalObject",
        [4] = "globalPlayer"
    }
    
    local key = typeMap[entityType]
    if key then
        RemoveHandlers(key, labels)
    end
end


local TargetObject = {
    AddEntity = AddTargetEntity,
    AddTargetEntity = AddTargetEntity,
    RemoveEntity = RemoveTargetEntity,
    RemoveTargetEntity = RemoveTargetEntity,
    
    AddModel = AddTargetModel,
    AddTargetModel = AddTargetModel,
    RemoveModel = RemoveTargetModel,
    RemoveTargetModel = RemoveTargetModel,
    
    AddGlobalPed = AddGlobalPed,
    Ped = AddGlobalPed,
    RemoveGlobalPed = function(labels) RemoveHandlers("globalPed", labels) end,
    RemovePed = function(labels) RemoveHandlers("globalPed", labels) end,
    
    AddGlobalVehicle = AddGlobalVehicle,
    Vehicle = AddGlobalVehicle,
    RemoveGlobalVehicle = function(labels) RemoveHandlers("globalVehicle", labels) end,
    RemoveVehicle = function(labels) RemoveHandlers("globalVehicle", labels) end,
    
    AddGlobalObject = AddGlobalObject,
    Object = AddGlobalObject,
    RemoveGlobalObject = function(labels) RemoveHandlers("globalObject", labels) end,
    RemoveObject = function(labels) RemoveHandlers("globalObject", labels) end,
    
    AddGlobalPlayer = AddGlobalPlayer,
    Player = AddGlobalPlayer,
    RemoveGlobalPlayer = function(labels) RemoveHandlers("globalPlayer", labels) end,
    RemovePlayer = function(labels) RemoveHandlers("globalPlayer", labels) end,
    
    AddTargetBone = AddTargetBone,
    RemoveTargetBone = RemoveTargetBone,
    
    AddEntityZone = AddEntityZone,
    RemoveEntityZone = RemoveEntityZone,
    AddBoxZone = AddBoxZone,
    AddCircleZone = AddCircleZone,
    AddPolyZone = AddPolyZone,
    RemoveZone = RemoveZone,
    
    SpawnPed = SpawnPed,
    DeletePed = DeletePed,
    
    AllowTargeting = AllowTargeting,
    IsTargetActive = IsTargetActive,
    IsTargetSuccess = IsTargetSuccess,
    GetTargetEntity = GetTargetEntity,
    GetEntityZone = GetEntityZone,
    
    RemoveType = RemoveType,
    RaycastCamera = RaycastCamera
}

RegisterBothExports('AddTargetEntity', AddTargetEntity)
RegisterBothExports('RemoveTargetEntity', RemoveTargetEntity)

RegisterBothExports('AddTargetModel', AddTargetModel)
RegisterBothExports('RemoveTargetModel', RemoveTargetModel)

RegisterBothExports('AddGlobalPed', AddGlobalPed)
RegisterBothExports('Ped', AddGlobalPed)
RegisterBothExports('RemoveGlobalPed', function(labels) RemoveHandlers("globalPed", labels) end)
RegisterBothExports('RemovePed', function(labels) RemoveHandlers("globalPed", labels) end)

RegisterBothExports('AddGlobalVehicle', AddGlobalVehicle)
RegisterBothExports('Vehicle', AddGlobalVehicle)
RegisterBothExports('RemoveGlobalVehicle', function(labels) RemoveHandlers("globalVehicle", labels) end)
RegisterBothExports('RemoveVehicle', function(labels) RemoveHandlers("globalVehicle", labels) end)

RegisterBothExports('AddGlobalObject', AddGlobalObject)
RegisterBothExports('Object', AddGlobalObject)
RegisterBothExports('RemoveGlobalObject', function(labels) RemoveHandlers("globalObject", labels) end)
RegisterBothExports('RemoveObject', function(labels) RemoveHandlers("globalObject", labels) end)

RegisterBothExports('AddGlobalPlayer', AddGlobalPlayer)
RegisterBothExports('Player', AddGlobalPlayer)
RegisterBothExports('RemoveGlobalPlayer', function(labels) RemoveHandlers("globalPlayer", labels) end)
RegisterBothExports('RemovePlayer', function(labels) RemoveHandlers("globalPlayer", labels) end)

RegisterBothExports('AddTargetBone', AddTargetBone)
RegisterBothExports('RemoveTargetBone', RemoveTargetBone)

RegisterBothExports('AddEntityZone', AddEntityZone)
RegisterBothExports('RemoveEntityZone', RemoveEntityZone)
RegisterBothExports('AddBoxZone', AddBoxZone)
RegisterBothExports('AddCircleZone', AddCircleZone)
RegisterBothExports('AddPolyZone', AddPolyZone)
RegisterBothExports('RemoveZone', RemoveZone)

RegisterBothExports('SpawnPed', SpawnPed)
RegisterBothExports('DeletePed', DeletePed)

RegisterBothExports('AllowTargeting', AllowTargeting)
RegisterBothExports('IsTargetActive', IsTargetActive)
RegisterBothExports('IsTargetSuccess', IsTargetSuccess)
RegisterBothExports('GetTargetEntity', GetTargetEntity)
RegisterBothExports('GetEntityZone', GetEntityZone)

RegisterBothExports('RemoveType', RemoveType)
RegisterBothExports('RaycastCamera', RaycastCamera)

RegisterBothExports('Target', function() return TargetObject end)

_G.Target = TargetObject


AddEventHandler('onResourceStop', function(resourceName)
end)

if Config and Config.Debug and Config.Debug.enabled then
    print('^2[nbl-target] qb-target/qtarget compatibility bridge loaded^7')
end
