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
                canInteract = opt.canInteract,
                shouldClose = true
            }
            
            if opt.action then
                newOpt.onSelect = opt.action
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
    exports['qb-target']:AddTargetEntity(entities, options)
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
    exports['qb-target']:RemoveTargetEntity(entities, labels)
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
    exports['qb-target']:AddTargetModel(models, options)
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
    exports['qb-target']:RemoveTargetModel(models, labels)
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
    exports['qb-target']:AddGlobalPed(options)
end)

RegisterExport('RemoveGlobalPed', function(labels)
    RemoveHandlers("globalPed", labels)
end)
RegisterQTargetExport('RemovePed', function(labels)
    exports['qb-target']:RemoveGlobalPed(labels)
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
    exports['qb-target']:AddGlobalVehicle(options)
end)

RegisterExport('RemoveGlobalVehicle', function(labels)
    RemoveHandlers("globalVehicle", labels)
end)
RegisterQTargetExport('RemoveVehicle', function(labels)
    exports['qb-target']:RemoveGlobalVehicle(labels)
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
    exports['qb-target']:AddGlobalObject(options)
end)

RegisterExport('RemoveGlobalObject', function(labels)
    RemoveHandlers("globalObject", labels)
end)
RegisterQTargetExport('RemoveObject', function(labels)
    exports['qb-target']:RemoveGlobalObject(labels)
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
    exports['qb-target']:AddGlobalPlayer(options)
end)

RegisterExport('RemoveGlobalPlayer', function(labels)
    RemoveHandlers("globalPlayer", labels)
end)
RegisterQTargetExport('RemovePlayer', function(labels)
    exports['qb-target']:RemoveGlobalPlayer(labels)
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
    exports['qb-target']:AddTargetBone(bones, options)
end)

RegisterExport('RemoveTargetBone', function(bones, labels)
    RemoveHandlers("bones", labels)
end)

RegisterExport('AddBoxZone', function(name, center, length, width, options, targetoptions)
    return nil
end)
RegisterQTargetExport('AddBoxZone', function(name, center, length, width, options, targetoptions)
    return nil
end)

RegisterExport('AddPolyZone', function(name, points, options, targetoptions)
    return nil
end)
RegisterQTargetExport('AddPolyZone', function(name, points, options, targetoptions)
    return nil
end)

RegisterExport('AddCircleZone', function(name, center, radius, options, targetoptions)
    return nil
end)
RegisterQTargetExport('AddCircleZone', function(name, center, radius, options, targetoptions)
    return nil
end)

RegisterExport('RemoveZone', function(name)
    return nil
end)
RegisterQTargetExport('RemoveZone', function(name)
    return nil
end)

RegisterExport('SpawnPed', function(data)
    return nil
end)

RegisterExport('DeletePed', function(data)
    return nil
end)

RegisterExport('IsTargetActive', function()
    return exports['nbl-target']:isActive()
end)

RegisterExport('IsTargetSuccess', function()
    return exports['nbl-target']:isMenuOpen()
end)

RegisterExport('GetEntityZone', function(entity)
    return nil
end)

RegisterExport('GetTargetEntity', function()
    return exports['nbl-target']:getSelectedEntity()
end)

