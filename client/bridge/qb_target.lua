local function RegisterExport(exportName, func)
    AddEventHandler(('__cfx_export_qb-target_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local function RegisterQTargetExport(exportName, func)
    AddEventHandler(('__cfx_export_qtarget_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

local zoneWarningShown = false

local function WarnZoneNotSupported(zoneName)
    if not zoneWarningShown then
        print('^3[nbl-target] WARNING: Zones are not supported by NBL Target.^7')
        print('^3[nbl-target] The following zone exports return nil: AddBoxZone, AddPolyZone, AddCircleZone, RemoveZone^7')
        print('^3[nbl-target] Consider using entity-based targeting instead (AddTargetModel, AddTargetEntity).^7')
        zoneWarningShown = true
    end
    if zoneName then
        print('^1[nbl-target] Zone "' .. tostring(zoneName) .. '" was not created (zones not supported).^7')
    end
end

local function BuildDataObject(entity, worldPos, opt)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = worldPos or (entity and entity ~= 0 and GetEntityCoords(entity) or playerCoords)
    local distance = entity and entity ~= 0 and #(playerCoords - entityCoords) or 0.0
    local entityModel = entity and entity ~= 0 and GetEntityModel(entity) or nil
    local entityType = entity and entity ~= 0 and GetEntityType(entity) or nil
    
    return {
        entity = entity,
        coords = entityCoords,
        distance = distance,
        model = entityModel,
        type = entityType,
        hash = entityModel,
        bone = nil,
        name = opt and (opt.name or opt.label) or nil,
        label = opt and opt.label or nil,
        icon = opt and opt.icon or nil,
        options = opt
    }
end

local function WrapAction(originalAction, opt)
    if not originalAction or type(originalAction) ~= "function" then
        return nil
    end
    
    return function(entity, worldPos, registration)
        local data = BuildDataObject(entity, worldPos, opt)
        return originalAction(data)
    end
end

local function WrapCanInteract(originalCanInteract, opt)
    if not originalCanInteract or type(originalCanInteract) ~= "function" then
        return nil
    end
    
    return function(entity, distance, worldPos, name)
        local data = BuildDataObject(entity, worldPos, opt)
        data.distance = distance
        data.name = name or (opt and opt.name)
        
        local success, result = pcall(originalCanInteract, entity, distance, data)
        if not success then
            success, result = pcall(originalCanInteract, data)
        end
        
        return result
    end
end

local function ConvertOptions(options, defaultDistance)
    if not options then return {} end
    
    local optionsArray = options.options or options
    
    if type(optionsArray) ~= "table" then
        return {}
    end
    
    local converted = {}
    local idx = 0
    
    for k, opt in pairs(optionsArray) do
        if type(opt) == "table" then
            idx = idx + 1
            
            local newOpt = {
                label = opt.label or opt.name,
                name = opt.name or opt.label,
                icon = opt.icon,
                distance = opt.distance or defaultDistance,
                canInteract = WrapCanInteract(opt.canInteract, opt),
                shouldClose = true
            }
            
            if opt.action then
                newOpt.onSelect = WrapAction(opt.action, opt)
            elseif opt.event then
                if opt.type == "server" then
                    newOpt.serverEvent = opt.event
                elseif opt.type == "command" then
                    newOpt.command = opt.event
                else
                    newOpt.event = opt.event
                end
            end
            
            if opt.job then
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
            
            converted[idx] = newOpt
        end
    end
    
    return converted
end

local handlers = {}

local function RegisterHandler(name, handler)
    if not handlers[name] then
        handlers[name] = {}
    end
    handlers[name][#handlers[name] + 1] = handler
end

local function RemoveHandlers(name, labels)
    if not handlers[name] then return end
    
    if labels then
        if type(labels) ~= "table" then
            labels = { labels }
        end
        
        local labelSet = {}
        for _, label in ipairs(labels) do
            labelSet[label] = true
        end
        
        local newHandlers = {}
        for _, handler in ipairs(handlers[name]) do
            if handler.label and labelSet[handler.label] then
                if handler.handler and handler.handler.remove then
                    handler.handler:remove()
                end
            else
                newHandlers[#newHandlers + 1] = handler
            end
        end
        handlers[name] = newHandlers
    else
        for _, handler in ipairs(handlers[name]) do
            if handler.handler and handler.handler.remove then
                handler.handler:remove()
            end
        end
        handlers[name] = {}
    end
end

RegisterExport('AddTargetEntity', function(entities, options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    if type(entities) ~= "table" then
        entities = { entities }
    end
    
    for _, entity in ipairs(entities) do
        if entity and entity ~= 0 then
            for _, opt in ipairs(converted) do
                local handler = nil
                if NetworkGetEntityIsNetworked(entity) then
                    handler = exports['nbl-target']:addEntity(entity, opt)
                else
                    handler = exports['nbl-target']:addLocalEntity(entity, opt)
                end
                
                if handler then
                    RegisterHandler("entity_" .. entity, { handler = handler, label = opt.label })
                end
            end
        end
    end
end)
RegisterQTargetExport('AddTargetEntity', function(entities, options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    if type(entities) ~= "table" then
        entities = { entities }
    end
    
    for _, entity in ipairs(entities) do
        if entity and entity ~= 0 then
            for _, opt in ipairs(converted) do
                local handler = nil
                if NetworkGetEntityIsNetworked(entity) then
                    handler = exports['nbl-target']:addEntity(entity, opt)
                else
                    handler = exports['nbl-target']:addLocalEntity(entity, opt)
                end
                
                if handler then
                    RegisterHandler("entity_" .. entity, { handler = handler, label = opt.label })
                end
            end
        end
    end
end)

RegisterExport('RemoveTargetEntity', function(entities, labels)
    if type(entities) ~= "table" then
        entities = { entities }
    end
    
    for _, entity in ipairs(entities) do
        RemoveHandlers("entity_" .. entity, labels)
    end
end)
RegisterQTargetExport('RemoveTargetEntity', function(entities, labels)
    if type(entities) ~= "table" then
        entities = { entities }
    end
    
    for _, entity in ipairs(entities) do
        RemoveHandlers("entity_" .. entity, labels)
    end
end)

RegisterExport('AddTargetModel', function(models, options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    if type(models) ~= "table" then
        models = { models }
    end
    
    for _, model in ipairs(models) do
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        
        for _, opt in ipairs(converted) do
            local handler = exports['nbl-target']:addModel(modelHash, opt)
            if handler then
                RegisterHandler("model_" .. modelHash, { handler = handler, label = opt.label })
            end
        end
    end
end)
RegisterQTargetExport('AddTargetModel', function(models, options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    if type(models) ~= "table" then
        models = { models }
    end
    
    for _, model in ipairs(models) do
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        
        for _, opt in ipairs(converted) do
            local handler = exports['nbl-target']:addModel(modelHash, opt)
            if handler then
                RegisterHandler("model_" .. modelHash, { handler = handler, label = opt.label })
            end
        end
    end
end)

RegisterExport('RemoveTargetModel', function(models, labels)
    if type(models) ~= "table" then
        models = { models }
    end
    
    for _, model in ipairs(models) do
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        RemoveHandlers("model_" .. modelHash, labels)
    end
end)
RegisterQTargetExport('RemoveTargetModel', function(models, labels)
    if type(models) ~= "table" then
        models = { models }
    end
    
    for _, model in ipairs(models) do
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        RemoveHandlers("model_" .. modelHash, labels)
    end
end)

RegisterExport('AddGlobalPed', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalPed(opt)
        if handler then
            RegisterHandler("globalPed", { handler = handler, label = opt.label })
        end
    end
end)
RegisterQTargetExport('Ped', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalPed(opt)
        if handler then
            RegisterHandler("globalPed", { handler = handler, label = opt.label })
        end
    end
end)

RegisterExport('RemoveGlobalPed', function(labels)
    RemoveHandlers("globalPed", labels)
end)
RegisterQTargetExport('RemovePed', function(labels)
    RemoveHandlers("globalPed", labels)
end)

RegisterExport('AddGlobalVehicle', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalVehicle(opt)
        if handler then
            RegisterHandler("globalVehicle", { handler = handler, label = opt.label })
        end
    end
end)
RegisterQTargetExport('Vehicle', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalVehicle(opt)
        if handler then
            RegisterHandler("globalVehicle", { handler = handler, label = opt.label })
        end
    end
end)

RegisterExport('RemoveGlobalVehicle', function(labels)
    RemoveHandlers("globalVehicle", labels)
end)
RegisterQTargetExport('RemoveVehicle', function(labels)
    RemoveHandlers("globalVehicle", labels)
end)

RegisterExport('AddGlobalObject', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalObject(opt)
        if handler then
            RegisterHandler("globalObject", { handler = handler, label = opt.label })
        end
    end
end)
RegisterQTargetExport('Object', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalObject(opt)
        if handler then
            RegisterHandler("globalObject", { handler = handler, label = opt.label })
        end
    end
end)

RegisterExport('RemoveGlobalObject', function(labels)
    RemoveHandlers("globalObject", labels)
end)
RegisterQTargetExport('RemoveObject', function(labels)
    RemoveHandlers("globalObject", labels)
end)

RegisterExport('AddGlobalPlayer', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalPlayer(opt)
        if handler then
            RegisterHandler("globalPlayer", { handler = handler, label = opt.label })
        end
    end
end)
RegisterQTargetExport('Player', function(options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    for _, opt in ipairs(converted) do
        local handler = exports['nbl-target']:addGlobalPlayer(opt)
        if handler then
            RegisterHandler("globalPlayer", { handler = handler, label = opt.label })
        end
    end
end)

RegisterExport('RemoveGlobalPlayer', function(labels)
    RemoveHandlers("globalPlayer", labels)
end)
RegisterQTargetExport('RemovePlayer', function(labels)
    RemoveHandlers("globalPlayer", labels)
end)

RegisterExport('AddTargetBone', function(bones, options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    if type(bones) ~= "table" then
        bones = { bones }
    end
    
    for _, opt in ipairs(converted) do
        opt.bones = bones
        local handler = exports['nbl-target']:addGlobalVehicle(opt)
        if handler then
            RegisterHandler("bones", { handler = handler, label = opt.label })
        end
    end
end)
RegisterQTargetExport('AddTargetBone', function(bones, options)
    local distance = options.distance
    local converted = ConvertOptions(options, distance)
    
    if type(bones) ~= "table" then
        bones = { bones }
    end
    
    for _, opt in ipairs(converted) do
        opt.bones = bones
        local handler = exports['nbl-target']:addGlobalVehicle(opt)
        if handler then
            RegisterHandler("bones", { handler = handler, label = opt.label })
        end
    end
end)

RegisterExport('RemoveTargetBone', function(bones, labels)
    RemoveHandlers("bones", labels)
end)
RegisterQTargetExport('RemoveTargetBone', function(bones, labels)
    RemoveHandlers("bones", labels)
end)

RegisterExport('AddBoxZone', function(name, center, length, width, options, targetoptions)
    WarnZoneNotSupported(name)
    return nil
end)
RegisterQTargetExport('AddBoxZone', function(name, center, length, width, options, targetoptions)
    WarnZoneNotSupported(name)
    return nil
end)

RegisterExport('AddPolyZone', function(name, points, options, targetoptions)
    WarnZoneNotSupported(name)
    return nil
end)
RegisterQTargetExport('AddPolyZone', function(name, points, options, targetoptions)
    WarnZoneNotSupported(name)
    return nil
end)

RegisterExport('AddCircleZone', function(name, center, radius, options, targetoptions)
    WarnZoneNotSupported(name)
    return nil
end)
RegisterQTargetExport('AddCircleZone', function(name, center, radius, options, targetoptions)
    WarnZoneNotSupported(name)
    return nil
end)

RegisterExport('RemoveZone', function(name)
    return nil
end)
RegisterQTargetExport('RemoveZone', function(name)
    return nil
end)

RegisterExport('SpawnPed', function(data)
    print('^3[nbl-target] WARNING: SpawnPed is not supported by NBL Target.^7')
    return nil
end)

RegisterExport('DeletePed', function(data)
    return nil
end)

RegisterExport('IsTargetActive', function()
    return exports['nbl-target']:isActive()
end)
RegisterQTargetExport('IsTargetActive', function()
    return exports['nbl-target']:isActive()
end)

RegisterExport('IsTargetSuccess', function()
    return exports['nbl-target']:isMenuOpen()
end)
RegisterQTargetExport('IsTargetSuccess', function()
    return exports['nbl-target']:isMenuOpen()
end)

RegisterExport('GetEntityZone', function(entity)
    return nil
end)
RegisterQTargetExport('GetEntityZone', function(entity)
    return nil
end)

RegisterExport('GetTargetEntity', function()
    return exports['nbl-target']:getSelectedEntity()
end)
RegisterQTargetExport('GetTargetEntity', function()
    return exports['nbl-target']:getSelectedEntity()
end)

RegisterExport('AddEntityZone', function(name, entity, options, targetoptions)
    local distance = targetoptions and targetoptions.distance or (options and options.distance) or 2.0
    local converted = ConvertOptions(targetoptions or options, distance)
    
    if entity and entity ~= 0 then
        for _, opt in ipairs(converted) do
            local handler = nil
            if NetworkGetEntityIsNetworked(entity) then
                handler = exports['nbl-target']:addEntity(entity, opt)
            else
                handler = exports['nbl-target']:addLocalEntity(entity, opt)
            end
            
            if handler then
                RegisterHandler("entityzone_" .. name, { handler = handler, label = opt.label })
            end
        end
    end
end)
RegisterQTargetExport('AddEntityZone', function(name, entity, options, targetoptions)
    local distance = targetoptions and targetoptions.distance or (options and options.distance) or 2.0
    local converted = ConvertOptions(targetoptions or options, distance)
    
    if entity and entity ~= 0 then
        for _, opt in ipairs(converted) do
            local handler = nil
            if NetworkGetEntityIsNetworked(entity) then
                handler = exports['nbl-target']:addEntity(entity, opt)
            else
                handler = exports['nbl-target']:addLocalEntity(entity, opt)
            end
            
            if handler then
                RegisterHandler("entityzone_" .. name, { handler = handler, label = opt.label })
            end
        end
    end
end)

RegisterExport('RemoveEntityZone', function(name)
    RemoveHandlers("entityzone_" .. name, nil)
end)
RegisterQTargetExport('RemoveEntityZone', function(name)
    RemoveHandlers("entityzone_" .. name, nil)
end)

RegisterExport('RemoveType', function(entityType, labels)
    local handlerName = nil
    if entityType == 1 then
        handlerName = "globalPed"
    elseif entityType == 2 then
        handlerName = "globalVehicle"
    elseif entityType == 3 then
        handlerName = "globalObject"
    elseif entityType == 4 then
        handlerName = "globalPlayer"
    end
    
    if handlerName then
        RemoveHandlers(handlerName, labels)
    end
end)
RegisterQTargetExport('RemoveType', function(entityType, labels)
    local handlerName = nil
    if entityType == 1 then
        handlerName = "globalPed"
    elseif entityType == 2 then
        handlerName = "globalVehicle"
    elseif entityType == 3 then
        handlerName = "globalObject"
    elseif entityType == 4 then
        handlerName = "globalPlayer"
    end
    
    if handlerName then
        RemoveHandlers(handlerName, labels)
    end
end)

RegisterExport('RaycastCamera', function(flag, coords)
    local cursorPos = vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
    local maxDistance = 100.0
    local hit, worldPos, _, entity, material = Raycast:FromScreen(cursorPos, maxDistance, flag)
    
    if hit and entity and entity ~= 0 then
        local distance = coords and #(coords - worldPos) or 0.0
        local entityType = GetEntityType(entity)
        return worldPos, distance, entity, entityType
    end
    
    return coords or vector3(0, 0, 0), 0.0, 0, 0
end)
RegisterQTargetExport('RaycastCamera', function(flag, coords)
    local cursorPos = vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
    local maxDistance = 100.0
    local hit, worldPos, _, entity, material = Raycast:FromScreen(cursorPos, maxDistance, flag)
    
    if hit and entity and entity ~= 0 then
        local distance = coords and #(coords - worldPos) or 0.0
        local entityType = GetEntityType(entity)
        return worldPos, distance, entity, entityType
    end
    
    return coords or vector3(0, 0, 0), 0.0, 0, 0
end)

RegisterExport('AllowTargeting', function(state)
    if state == false then
        exports['nbl-target']:disable()
    else
        exports['nbl-target']:enable()
    end
end)

RegisterQTargetExport('AllowTargeting', function(state)
    if state == false then
        exports['nbl-target']:disable()
    else
        exports['nbl-target']:enable()
    end
end)
