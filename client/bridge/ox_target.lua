local function RegisterExport(name, fn)
    AddEventHandler(('__cfx_export_ox_target_%s'):format(name), function(setCB)
        setCB(fn)
    end)
end

local function CreateDataObject(entity, coords, opt)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = coords or (entity and entity ~= 0 and GetEntityCoords(entity) or playerCoords)
    local dist = entity and entity ~= 0 and #(playerCoords - entityCoords) or 0.0
    
    local data = {
        entity = entity or 0,
        coords = entityCoords,
        distance = dist,
        zone = nil,
        name = opt and opt.name or nil,
        model = entity and entity ~= 0 and GetEntityModel(entity) or nil
    }
    
    if opt then
        for k, v in pairs(opt) do
            if data[k] == nil and type(v) ~= "function" then
                data[k] = v
            end
        end
    end
    
    return data
end

local function ConvertOption(opt)
    local converted = {
        label = opt.label or opt.name,
        name = opt.name or opt.label,
        icon = opt.icon,
        distance = opt.distance,
        shouldClose = opt.shouldClose ~= false
    }
    
    if opt.canInteract then
        local original = opt.canInteract
        converted.canInteract = function(entity, distance, coords, name)
            local data = CreateDataObject(entity, coords, opt)
            data.distance = distance
            local ok, result = pcall(original, entity, distance, coords, name, nil)
            if not ok then
                ok, result = pcall(original, data)
            end
            return result
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
    for i = 1, #options do
        result[i] = ConvertOption(options[i])
    end
    return result
end

local function WarnZone(name)
    print('^3[nbl-target] Zone "' .. tostring(name) .. '" not supported - use entity targeting instead^7')
end

RegisterExport('addGlobalVehicle', function(options)
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        handlers[i] = exports['nbl-target']:addGlobalVehicle(converted[i])
    end
    return handlers
end)

RegisterExport('removeGlobalVehicle', function(ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addGlobalPed', function(options)
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        handlers[i] = exports['nbl-target']:addGlobalPed(converted[i])
    end
    return handlers
end)

RegisterExport('removeGlobalPed', function(ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addGlobalPlayer', function(options)
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        handlers[i] = exports['nbl-target']:addGlobalPlayer(converted[i])
    end
    return handlers
end)

RegisterExport('removeGlobalPlayer', function(ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addGlobalObject', function(options)
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        handlers[i] = exports['nbl-target']:addGlobalObject(converted[i])
    end
    return handlers
end)

RegisterExport('removeGlobalObject', function(ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addModel', function(models, options)
    local converted = ConvertOptions(options)
    local handlers = {}
    local idx = 0
    if type(models) ~= "table" then models = {models} end
    for m = 1, #models do
        local model = models[m]
        if type(model) == "string" then model = GetHashKey(model) end
        for i = 1, #converted do
            idx = idx + 1
            handlers[idx] = exports['nbl-target']:addModel(model, converted[i])
        end
    end
    return handlers
end)

RegisterExport('removeModel', function(models, ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addEntity', function(netIds, options)
    local converted = ConvertOptions(options)
    local handlers = {}
    local idx = 0
    if type(netIds) ~= "table" then netIds = {netIds} end
    for n = 1, #netIds do
        local entity = NetworkGetEntityFromNetworkId(netIds[n])
        if entity and entity ~= 0 then
            for i = 1, #converted do
                idx = idx + 1
                handlers[idx] = exports['nbl-target']:addEntity(entity, converted[i])
            end
        end
    end
    return handlers
end)

RegisterExport('addLocalEntity', function(entities, options)
    local converted = ConvertOptions(options)
    local handlers = {}
    local idx = 0
    if type(entities) ~= "table" then entities = {entities} end
    for e = 1, #entities do
        local entity = entities[e]
        if entity and entity ~= 0 then
            for i = 1, #converted do
                idx = idx + 1
                handlers[idx] = exports['nbl-target']:addLocalEntity(entity, converted[i])
            end
        end
    end
    return handlers
end)

RegisterExport('removeEntity', function(_, ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('removeLocalEntity', function(_, ids)
    if type(ids) == "table" then
        for i = 1, #ids do
            if ids[i] and ids[i].remove then ids[i]:remove() end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('disableTargeting', function(state)
    if state then
        exports['nbl-target']:disable()
    else
        exports['nbl-target']:enable()
    end
end)

RegisterExport('isActive', function()
    return exports['nbl-target']:isActive()
end)

RegisterExport('addSphereZone', function(data)
    WarnZone(data and data.name)
    return nil
end)

RegisterExport('addBoxZone', function(data)
    WarnZone(data and data.name)
    return nil
end)

RegisterExport('addPolyZone', function(data)
    WarnZone(data and data.name)
    return nil
end)

RegisterExport('removeZone', function() return nil end)
RegisterExport('getEntityOptions', function() return nil end)
RegisterExport('getZoneOptions', function() return nil end)
RegisterExport('getGlobalOptions', function() return nil end)
