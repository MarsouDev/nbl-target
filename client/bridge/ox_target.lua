local function RegisterExport(exportName, func)
    AddEventHandler(('__cfx_export_ox_target_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local function WrapOnSelect(originalOnSelect, optionName)
    if not originalOnSelect or type(originalOnSelect) ~= "function" then
        return nil
    end
    
    return function(entity, worldPos, registration)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local entityCoords = worldPos or (entity and entity ~= 0 and GetEntityCoords(entity) or playerCoords)
        local distance = entity and entity ~= 0 and #(playerCoords - entityCoords) or 0.0
        
        local data = {
            entity = entity,
            coords = entityCoords,
            distance = distance,
            zone = nil,
            name = optionName or (registration and registration.name),
            model = entity and entity ~= 0 and GetEntityModel(entity) or nil,
            type = entity and entity ~= 0 and GetEntityType(entity) or nil
        }
        
        return originalOnSelect(data)
    end
end

local function WrapCanInteract(originalCanInteract)
    if not originalCanInteract or type(originalCanInteract) ~= "function" then
        return nil
    end
    
    return function(entity, distance, worldPos, name)
        local data = {
            entity = entity,
            coords = worldPos,
            distance = distance,
            zone = nil,
            name = name,
            model = entity and entity ~= 0 and GetEntityModel(entity) or nil,
            type = entity and entity ~= 0 and GetEntityType(entity) or nil
        }
        
        local success, result = pcall(originalCanInteract, entity, distance, worldPos, name, nil)
        if not success then
            success, result = pcall(originalCanInteract, data)
        end
        
        return result
    end
end

local function ConvertOptions(options)
    if not options then return {} end
    
    local converted = {}
    
    for i, opt in ipairs(options) do
        local optionName = opt.name or opt.label
        
        local newOpt = {
            label = opt.label or opt.name,
            name = optionName,
            icon = opt.icon,
            distance = opt.distance,
            canInteract = WrapCanInteract(opt.canInteract),
            onSelect = WrapOnSelect(opt.onSelect, optionName),
            event = opt.event,
            serverEvent = opt.serverEvent,
            command = opt.command,
            shouldClose = opt.shouldClose ~= false
        }
        
        if opt.groups then
            local wrappedCanInteract = newOpt.canInteract
            newOpt.canInteract = function(entity, distance, worldPos, name)
                if wrappedCanInteract then
                    local success, result = pcall(wrappedCanInteract, entity, distance, worldPos, name)
                    if not success or not result then
                        return false
                    end
                end
                return true
            end
        end
        
        converted[i] = newOpt
    end
    
    return converted
end

local zoneWarningShown = false

local function WarnZoneNotSupported(zoneName)
    if not zoneWarningShown then
        print('^3[nbl-target] WARNING: Zones are not supported by NBL Target.^7')
        print('^3[nbl-target] The following zone exports return nil: addSphereZone, addBoxZone, addPolyZone, removeZone^7')
        print('^3[nbl-target] Consider using entity-based targeting instead (addModel, addEntity, addLocalEntity).^7')
        zoneWarningShown = true
    end
    if zoneName then
        print('^1[nbl-target] Zone "' .. tostring(zoneName) .. '" was not created (zones not supported).^7')
    end
end

RegisterExport('addGlobalVehicle', function(options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalVehicle(opt)
        if handler then
            ids[#ids + 1] = handler
        end
    end
    
    return ids
end)

RegisterExport('removeGlobalVehicle', function(ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addGlobalPed', function(options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalPed(opt)
        if handler then
            ids[#ids + 1] = handler
        end
    end
    
    return ids
end)

RegisterExport('removeGlobalPed', function(ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addGlobalPlayer', function(options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalPlayer(opt)
        if handler then
            ids[#ids + 1] = handler
        end
    end
    
    return ids
end)

RegisterExport('removeGlobalPlayer', function(ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addGlobalObject', function(options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalObject(opt)
        if handler then
            ids[#ids + 1] = handler
        end
    end
    
    return ids
end)

RegisterExport('removeGlobalObject', function(ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addModel', function(models, options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addModel(models, opt)
        if handler then
            ids[#ids + 1] = handler
        end
    end
    
    return ids
end)

RegisterExport('removeModel', function(models, ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('addEntity', function(netIds, options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    if type(netIds) ~= "table" then
        netIds = { netIds }
    end
    
    for _, netId in ipairs(netIds) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 then
            for _, opt in ipairs(converted) do
                local handler = exports['nbl-target']:addEntity(entity, opt)
                if handler then
                    ids[#ids + 1] = handler
                end
            end
        end
    end
    
    return ids
end)

RegisterExport('addLocalEntity', function(entities, options)
    local converted = ConvertOptions(options)
    local ids = {}
    
    if type(entities) ~= "table" then
        entities = { entities }
    end
    
    for _, entity in ipairs(entities) do
        if entity and entity ~= 0 then
            for _, opt in ipairs(converted) do
                local handler = exports['nbl-target']:addLocalEntity(entity, opt)
                if handler then
                    ids[#ids + 1] = handler
                end
            end
        end
    end
    
    return ids
end)

RegisterExport('removeEntity', function(netIds, ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
        end
    elseif ids and ids.remove then
        ids:remove()
    end
end)

RegisterExport('removeLocalEntity', function(entities, ids)
    if type(ids) == "table" and ids[1] then
        for _, handler in ipairs(ids) do
            if handler and handler.remove then
                handler:remove()
            end
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
    WarnZoneNotSupported(data and data.name)
    return nil
end)

RegisterExport('addBoxZone', function(data)
    WarnZoneNotSupported(data and data.name)
    return nil
end)

RegisterExport('addPolyZone', function(data)
    WarnZoneNotSupported(data and data.name)
    return nil
end)

RegisterExport('removeZone', function(id)
    return nil
end)

RegisterExport('getEntityOptions', function(entity)
    return nil
end)

RegisterExport('getZoneOptions', function(id)
    return nil
end)

RegisterExport('getGlobalOptions', function(type)
    return nil
end)
