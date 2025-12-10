local function RegisterExport(exportName, func)
    AddEventHandler(('__cfx_export_ox_target_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local function ConvertOptions(options)
    if not options then return {} end
    
    local converted = {}
    
    for i, opt in ipairs(options) do
        local newOpt = {
            label = opt.label or opt.name,
            name = opt.name or opt.label,
            icon = opt.icon,
            distance = opt.distance,
            canInteract = opt.canInteract,
            onSelect = opt.onSelect,
            event = opt.event,
            serverEvent = opt.serverEvent,
            command = opt.command,
            shouldClose = opt.shouldClose ~= false
        }
        
        if opt.groups then
            local originalCanInteract = newOpt.canInteract
            newOpt.canInteract = function(entity, distance, worldPos, name)
                if originalCanInteract then
                    local success, result = pcall(originalCanInteract, entity, distance, worldPos, name)
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

local function ConvertSingleOption(options)
    if not options then return nil end
    
    if options[1] and type(options[1]) == "table" then
        return ConvertOptions(options)
    end
    
    return {
        label = options.label or options.name,
        name = options.name or options.label,
        icon = options.icon,
        distance = options.distance,
        canInteract = options.canInteract,
        onSelect = options.onSelect,
        event = options.event,
        serverEvent = options.serverEvent,
        command = options.command,
        shouldClose = options.shouldClose ~= false
    }
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
    return nil
end)

RegisterExport('addBoxZone', function(data)
    return nil
end)

RegisterExport('addPolyZone', function(data)
    return nil
end)

RegisterExport('removeZone', function(id)
    return nil
end)

