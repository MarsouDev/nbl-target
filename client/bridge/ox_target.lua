
local function RegisterExport(name, fn)
    local success, err = pcall(function()
        AddEventHandler(('__cfx_export_ox_target_%s'):format(name), function(setCB)
            setCB(fn)
        end)
    end)
    if not success then
        print('^1[nbl-target] Failed to register ox_target export "' .. name .. '": ' .. tostring(err) .. '^7')
    end
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local success, result = pcall(fn, ...)
    if not success then
        if Config and Config.Debug and Config.Debug.enabled then
            print('^1[nbl-target] ox_target bridge callback error: ' .. tostring(result) .. '^7')
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

local function IsArrayLike(t)
    if not IsValidTable(t) then return false end
    local count = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" then return false end
        count = count + 1
    end
    return count > 0
end

local function IsOptionObject(t)
    if not IsValidTable(t) then return false end
    return t.label ~= nil or t.name ~= nil or t.icon ~= nil or 
           t.onSelect ~= nil or t.event ~= nil or t.serverEvent ~= nil or 
           t.command ~= nil or t.canInteract ~= nil
end


local function CreateDataObject(entity, coords, opt, extraData)
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
    if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
        entityModel = GetEntityModel(entity)
    end
    
    local data = {
        entity = entity or 0,
        coords = entityCoords,
        distance = dist,
        zone = extraData and extraData.zone or nil,
        name = opt and opt.name or nil,
        model = entityModel,
        bone = nil,
        resource = opt and opt.resource or GetInvokingResource() or GetCurrentResourceName()
    }
    
    if IsValidTable(opt) then
        for k, v in pairs(opt) do
            if data[k] == nil and type(v) ~= "function" then
                data[k] = v
            end
        end
    end
    
    if IsValidTable(extraData) then
        for k, v in pairs(extraData) do
            if data[k] == nil and type(v) ~= "function" then
                data[k] = v
            end
        end
    end
    
    return data
end


local function ConvertOption(opt)
    if not IsValidTable(opt) then
        return nil
    end
    
    if not opt.label and not opt.name then
        return nil
    end
    
    local converted = {
        label = opt.label or opt.name or "Interact",
        name = opt.name or opt.label,
        icon = opt.icon,
        distance = opt.distance,
        shouldClose = opt.shouldClose ~= false
    }
    
    if opt.groups then
        converted.groups = opt.groups
    end
    
    if opt.items then
        converted.requiredItems = opt.items
    end
    
    if opt.canInteract then
        local original = opt.canInteract
        converted.canInteract = function(entity, distance, coords, name, bone)
            local data = CreateDataObject(entity, coords, opt)
            data.distance = distance
            data.bone = bone
            
            local ok, result = pcall(original, data)
            if ok then
                return result == true or result == nil
            end
            ok, result = pcall(original, entity, distance, coords, name, bone)
            if ok then
                return result == true or result == nil
            end
            
            if Config and Config.Debug and Config.Debug.enabled then
                print('^3[nbl-target] ox_target canInteract error for "' .. tostring(opt.label) .. '"^7')
            end
            return false
        end
    end
    
    if opt.onSelect then
        local original = opt.onSelect
        converted.onSelect = function(entity, coords, reg)
            local data = CreateDataObject(entity, coords, opt)
            local ok, err = pcall(original, data)
            if not ok then
                print('^1[nbl-target] ox_target bridge onSelect error: ' .. tostring(err) .. '^7')
            end
        end
    elseif opt.export then
        local exportStr = opt.export
        if type(exportStr) == "string" then
            local dotIndex = exportStr:find("%.")
            if dotIndex then
                local resourceName = exportStr:sub(1, dotIndex - 1)
                local exportName = exportStr:sub(dotIndex + 1)
                converted.onSelect = function(entity, coords, reg)
                    local data = CreateDataObject(entity, coords, opt)
                    if exports[resourceName] and exports[resourceName][exportName] then
                        local ok, err = pcall(exports[resourceName][exportName], data)
                        if not ok then
                            print('^1[nbl-target] ox_target export call error: ' .. tostring(err) .. '^7')
                        end
                    else
                        print('^3[nbl-target] ox_target export not found: ' .. tostring(exportStr) .. '^7')
                    end
                end
            end
        end
    elseif opt.event then
        converted.onSelect = function(entity, coords, reg)
            local data = CreateDataObject(entity, coords, opt)
            TriggerEvent(opt.event, data)
        end
    elseif opt.serverEvent then
        converted.onSelect = function(entity, coords, reg)
            local data = CreateDataObject(entity, coords, opt)
            TriggerServerEvent(opt.serverEvent, data)
        end
    elseif opt.command then
        converted.command = opt.command
    end
    
    return converted
end

local function ConvertOptions(options)
    if not options then return {} end
    
    local result = {}
    local idx = 0
    
    if IsOptionObject(options) and not IsArrayLike(options) then
        local converted = ConvertOption(options)
        if converted then
            result[1] = converted
        end
        return result
    end
    
    if IsValidTable(options) then
        for k, opt in pairs(options) do
            if IsValidTable(opt) then
                local converted = ConvertOption(opt)
                if converted then
                    idx = idx + 1
                    result[idx] = converted
                end
            end
        end
    end
    
    return result
end


local HandlerStorage = {
    byKey = {},
    byId = {}
}

local function GenerateKey(prefix, identifier)
    if type(identifier) == "table" then
        local parts = {}
        for i, v in ipairs(identifier) do
            parts[i] = tostring(v)
        end
        return prefix .. "_" .. table.concat(parts, "_")
    end
    return prefix .. "_" .. tostring(identifier)
end

local function StoreHandlers(key, handlers)
    if not IsValidTable(handlers) then return end
    if not HandlerStorage.byKey[key] then
        HandlerStorage.byKey[key] = {}
    end
    for i = 1, #handlers do
        local h = handlers[i]
        if h then
            table.insert(HandlerStorage.byKey[key], h)
            if h.getId then
                local id = h:getId()
                if type(id) == "table" then
                    for _, subId in ipairs(id) do
                        HandlerStorage.byId[subId] = h
                    end
                else
                    HandlerStorage.byId[id] = h
                end
            end
        end
    end
end

local function RemoveHandlers(key)
    local stored = HandlerStorage.byKey[key]
    if not stored then return false end
    
    for i = 1, #stored do
        local h = stored[i]
        if h then
            if type(h.remove) == "function" then
                pcall(h.remove, h)
            elseif type(h) == "table" and h.remove then
                pcall(function() h:remove() end)
            end
        end
    end
    
    HandlerStorage.byKey[key] = nil
    return true
end

local function RemoveHandlersByIds(ids)
    if not ids then return end
    
    local toRemove = type(ids) == "table" and ids or {ids}
    
    for i = 1, #toRemove do
        local id = toRemove[i]
        if id then
            if type(id) == "table" and type(id.remove) == "function" then
                pcall(id.remove, id)
            elseif type(id) == "table" and id.remove then
                pcall(function() id:remove() end)
            elseif HandlerStorage.byId[id] then
                local h = HandlerStorage.byId[id]
                if type(h.remove) == "function" then
                    pcall(h.remove, h)
                end
                HandlerStorage.byId[id] = nil
            end
        end
    end
end


local ZoneWarnings = {}

local function WarnZone(zoneName, zoneType)
    local key = tostring(zoneType) .. "_" .. tostring(zoneName)
    if not ZoneWarnings[key] then
        ZoneWarnings[key] = true
        print('^3[nbl-target] ' .. tostring(zoneType) .. ' zone "' .. tostring(zoneName) .. '" not supported - use entity targeting instead^7')
    end
    return nil
end


RegisterExport('addGlobalVehicle', function(options)
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    local handlers = {}
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalVehicle(converted[i])
        end)
        if success and handler then
            handlers[i] = handler
        end
    end
    
    if #handlers > 0 then
        StoreHandlers("globalVehicle", handlers)
    end
    
    return handlers
end)

RegisterExport('removeGlobalVehicle', function(ids)
    RemoveHandlersByIds(ids)
end)

RegisterExport('addGlobalPed', function(options)
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    local handlers = {}
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalPed(converted[i])
        end)
        if success and handler then
            handlers[i] = handler
        end
    end
    
    if #handlers > 0 then
        StoreHandlers("globalPed", handlers)
    end
    
    return handlers
end)

RegisterExport('removeGlobalPed', function(ids)
    RemoveHandlersByIds(ids)
end)

RegisterExport('addGlobalPlayer', function(options)
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    local handlers = {}
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalPlayer(converted[i])
        end)
        if success and handler then
            handlers[i] = handler
        end
    end
    
    if #handlers > 0 then
        StoreHandlers("globalPlayer", handlers)
    end
    
    return handlers
end)

RegisterExport('removeGlobalPlayer', function(ids)
    RemoveHandlersByIds(ids)
end)

RegisterExport('addGlobalObject', function(options)
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    local handlers = {}
    
    for i = 1, #converted do
        local success, handler = pcall(function()
            return exports['nbl-target']:addGlobalObject(converted[i])
        end)
        if success and handler then
            handlers[i] = handler
        end
    end
    
    if #handlers > 0 then
        StoreHandlers("globalObject", handlers)
    end
    
    return handlers
end)

RegisterExport('removeGlobalObject', function(ids)
    RemoveHandlersByIds(ids)
end)


RegisterExport('addModel', function(models, options)
    if not models then return {} end
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    if #converted == 0 then return {} end
    
    local handlers = {}
    local idx = 0
    
    local modelList = models
    if type(models) ~= "table" then
        modelList = {models}
    elseif IsOptionObject(models) then
        modelList = {models}
    end
    
    for m = 1, #modelList do
        local model = modelList[m]
        if model then
            local modelHash = model
            if type(model) == "string" then
                modelHash = GetHashKey(model)
            end
            
            for i = 1, #converted do
                local success, handler = pcall(function()
                    return exports['nbl-target']:addModel(modelHash, converted[i])
                end)
                if success and handler then
                    idx = idx + 1
                    handlers[idx] = handler
                end
            end
            
            if #handlers > 0 then
                StoreHandlers(GenerateKey("model", modelHash), handlers)
            end
        end
    end
    
    return handlers
end)

RegisterExport('removeModel', function(models, ids)
    if ids then
        RemoveHandlersByIds(ids)
    elseif models then
        local modelList = type(models) == "table" and models or {models}
        for m = 1, #modelList do
            local model = modelList[m]
            if model then
                local modelHash = type(model) == "string" and GetHashKey(model) or model
                RemoveHandlers(GenerateKey("model", modelHash))
            end
        end
    end
end)


RegisterExport('addEntity', function(netIds, options)
    if not netIds then return {} end
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    if #converted == 0 then return {} end
    
    local handlers = {}
    local idx = 0
    
    local netIdList = netIds
    if type(netIds) ~= "table" then
        netIdList = {netIds}
    end
    
    for n = 1, #netIdList do
        local netId = netIdList[n]
        if netId then
            local entity = 0
            
            local success, result = pcall(function()
                return NetworkGetEntityFromNetworkId(netId)
            end)
            
            if success and result and result ~= 0 then
                entity = result
            elseif type(netId) == "number" and netId > 0 then
                if GetEntityType(netId) ~= 0 then
                    entity = netId
                end
            end
            
            if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
                for i = 1, #converted do
                    local addSuccess, handler = pcall(function()
                        return exports['nbl-target']:addEntity(entity, converted[i])
                    end)
                    if addSuccess and handler then
                        idx = idx + 1
                        handlers[idx] = handler
                    end
                end
                
                if #handlers > 0 then
                    StoreHandlers(GenerateKey("entity", netId), handlers)
                end
            end
        end
    end
    
    return handlers
end)

RegisterExport('removeEntity', function(netIds, ids)
    if ids then
        RemoveHandlersByIds(ids)
    elseif netIds then
        local netIdList = type(netIds) == "table" and netIds or {netIds}
        for n = 1, #netIdList do
            local netId = netIdList[n]
            if netId then
                RemoveHandlers(GenerateKey("entity", netId))
            end
        end
    end
end)


RegisterExport('addLocalEntity', function(entities, options)
    if not entities then return {} end
    if not options then return {} end
    
    local converted = ConvertOptions(options)
    if #converted == 0 then return {} end
    
    local handlers = {}
    local idx = 0
    
    local entityList = entities
    if type(entities) ~= "table" then
        entityList = {entities}
    end
    
    for e = 1, #entityList do
        local entity = entityList[e]
        if IsValidEntity(entity) then
            local entityType = GetEntityType(entity)
            if entityType ~= 0 then
                for i = 1, #converted do
                    local success, handler = pcall(function()
                        return exports['nbl-target']:addLocalEntity(entity, converted[i])
                    end)
                    if success and handler then
                        idx = idx + 1
                        handlers[idx] = handler
                    end
                end
                
                if #handlers > 0 then
                    StoreHandlers(GenerateKey("localEntity", entity), handlers)
                end
            end
        end
    end
    
    return handlers
end)

RegisterExport('removeLocalEntity', function(entities, ids)
    if ids then
        RemoveHandlersByIds(ids)
    elseif entities then
        local entityList = type(entities) == "table" and entities or {entities}
        for e = 1, #entityList do
            local entity = entityList[e]
            if entity then
                RemoveHandlers(GenerateKey("localEntity", entity))
            end
        end
    end
end)


RegisterExport('addSphereZone', function(data)
    if not IsValidTable(data) then return nil end
    return WarnZone(data.name, "SphereZone")
end)

RegisterExport('addBoxZone', function(data)
    if not IsValidTable(data) then return nil end
    return WarnZone(data.name, "BoxZone")
end)

RegisterExport('addPolyZone', function(data)
    if not IsValidTable(data) then return nil end
    return WarnZone(data.name, "PolyZone")
end)

RegisterExport('removeZone', function(id)
    return true
end)


RegisterExport('disableTargeting', function(state)
    local success, err = pcall(function()
        if state then
            exports['nbl-target']:disable()
        else
            exports['nbl-target']:enable()
        end
    end)
    if not success then
        print('^1[nbl-target] disableTargeting error: ' .. tostring(err) .. '^7')
    end
end)

RegisterExport('isActive', function()
    local success, result = pcall(function()
        return exports['nbl-target']:isActive()
    end)
    return success and result or false
end)


RegisterExport('getEntityOptions', function(entity)
    return nil
end)

RegisterExport('getZoneOptions', function(zoneName)
    return nil
end)

RegisterExport('getGlobalOptions', function(entityType)
    return nil
end)

RegisterExport('getCurrentTarget', function()
    local success, result = pcall(function()
        return exports['nbl-target']:getCurrentTarget()
    end)
    return success and result or nil
end)

RegisterExport('getTarget', function()
    local success, result = pcall(function()
        return exports['nbl-target']:getSelectedEntity()
    end)
    return success and result or nil
end)


RegisterExport('setEntityOptions', function(entity, options)
    if IsValidEntity(entity) then
        RemoveHandlers(GenerateKey("localEntity", entity))
        if options then
            local converted = ConvertOptions(options)
            local handlers = {}
            for i = 1, #converted do
                local success, handler = pcall(function()
                    return exports['nbl-target']:addLocalEntity(entity, converted[i])
                end)
                if success and handler then
                    handlers[#handlers + 1] = handler
                end
            end
            if #handlers > 0 then
                StoreHandlers(GenerateKey("localEntity", entity), handlers)
            end
            return handlers
        end
    end
    return {}
end)

RegisterExport('addEntity', function(netIds, options)
    return exports['ox_target']:addEntity(netIds, options)
end)

RegisterExport('enable', function()
    pcall(function()
        exports['nbl-target']:enable()
    end)
end)

RegisterExport('disable', function()
    pcall(function()
        exports['nbl-target']:disable()
    end)
end)

RegisterExport('debug', function(state)
    if Config and Config.Debug then
        Config.Debug.enabled = state == true
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
end)
if Config and Config.Debug and Config.Debug.enabled then
    print('^2[nbl-target] ox_target compatibility bridge loaded^7')
end
