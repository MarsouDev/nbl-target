local function RegisterExport(name, fn)
    AddEventHandler(('__cfx_export_qb-target_%s'):format(name), function(setCB)
        setCB(fn)
    end)
end

local function RegisterQTargetExport(name, fn)
    AddEventHandler(('__cfx_export_qtarget_%s'):format(name), function(setCB)
        setCB(fn)
    end)
end

local function CreateDataObject(entity, coords, opt)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = coords or (entity and entity ~= 0 and GetEntityCoords(entity) or playerCoords)
    local dist = entity and entity ~= 0 and #(playerCoords - entityCoords) or 0.0
    local model = entity and entity ~= 0 and GetEntityModel(entity) or nil
    
    local data = {
        entity = entity or 0,
        coords = entityCoords,
        distance = dist,
        model = model,
        hash = model,
        type = entity and entity ~= 0 and GetEntityType(entity) or nil,
        bone = nil,
        name = opt and (opt.name or opt.label) or nil,
        label = opt and opt.label or nil
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

local function ConvertOption(opt, defaultDist)
    local converted = {
        label = opt.label or opt.name,
        name = opt.name or opt.label,
        icon = opt.icon,
        distance = opt.distance or defaultDist,
        shouldClose = true
    }
    
    if opt.canInteract then
        local original = opt.canInteract
        converted.canInteract = function(entity, distance, coords, name)
            local data = CreateDataObject(entity, coords, opt)
            data.distance = distance
            local ok, result = pcall(original, entity, distance, data)
            if not ok then
                ok, result = pcall(original, data)
            end
            return result
        end
    end
    
    if opt.action then
        local original = opt.action
        converted.onSelect = function(entity, coords, reg)
            local data = CreateDataObject(entity, coords, opt)
            local ok, err = pcall(original, data)
            if not ok then
                print('^1[nbl-target] qb-target bridge action error: ' .. tostring(err) .. '^7')
            end
        end
    elseif opt.event then
        if opt.type == "server" then
            converted.onSelect = function(entity, coords, reg)
                local data = CreateDataObject(entity, coords, opt)
                TriggerServerEvent(opt.event, data)
            end
        elseif opt.type == "command" then
            converted.command = opt.event
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
    local opts = options.options or options
    if type(opts) ~= "table" then return {} end
    
    local result = {}
    local idx = 0
    for _, opt in pairs(opts) do
        if type(opt) == "table" then
            idx = idx + 1
            result[idx] = ConvertOption(opt, defaultDist)
        end
    end
    return result
end

local handlers = {}

local function StoreHandler(key, handler, label)
    if not handlers[key] then handlers[key] = {} end
    handlers[key][#handlers[key] + 1] = {h = handler, l = label}
end

local function RemoveHandlers(key, labels)
    if not handlers[key] then return end
    if labels then
        if type(labels) ~= "table" then labels = {labels} end
        local labelSet = {}
        for i = 1, #labels do labelSet[labels[i]] = true end
        local keep = {}
        for i = 1, #handlers[key] do
            local item = handlers[key][i]
            if item and item.l and labelSet[item.l] then
                if item.h and type(item.h.remove) == "function" then
                    pcall(item.h.remove, item.h)
                end
            elseif item then
                keep[#keep + 1] = item
            end
        end
        handlers[key] = #keep > 0 and keep or nil
    else
        for i = 1, #handlers[key] do
            local item = handlers[key][i]
            if item and item.h and type(item.h.remove) == "function" then
                pcall(item.h.remove, item.h)
            end
        end
        handlers[key] = nil
    end
end

local function WarnZone(name)
    print('^3[nbl-target] Zone "' .. tostring(name) .. '" not supported - use entity targeting instead^7')
end

local function AddTargetEntity(entities, options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    if type(entities) ~= "table" then entities = {entities} end
    for e = 1, #entities do
        local entity = entities[e]
        if entity and entity ~= 0 then
            for i = 1, #converted do
                local h
                if NetworkGetEntityIsNetworked(entity) then
                    h = exports['nbl-target']:addEntity(entity, converted[i])
                else
                    h = exports['nbl-target']:addLocalEntity(entity, converted[i])
                end
                if h then StoreHandler("entity_" .. entity, h, converted[i].label) end
            end
        end
    end
end

local function RemoveTargetEntity(entities, labels)
    if entities == nil then return end
    if type(entities) ~= "table" then entities = {entities} end
    for e = 1, #entities do
        local entity = entities[e]
        if entity ~= nil then
            RemoveHandlers("entity_" .. entity, labels)
        end
    end
end

local function AddTargetModel(models, options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    if type(models) ~= "table" then models = {models} end
    for m = 1, #models do
        local model = models[m]
        if type(model) == "string" then model = GetHashKey(model) end
        for i = 1, #converted do
            local h = exports['nbl-target']:addModel(model, converted[i])
            if h then StoreHandler("model_" .. model, h, converted[i].label) end
        end
    end
end

local function RemoveTargetModel(models, labels)
    if type(models) ~= "table" then models = {models} end
    for m = 1, #models do
        local model = models[m]
        if type(model) == "string" then model = GetHashKey(model) end
        RemoveHandlers("model_" .. model, labels)
    end
end

local function AddGlobalPed(options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = exports['nbl-target']:addGlobalPed(converted[i])
        if h then StoreHandler("globalPed", h, converted[i].label) end
    end
end

local function AddGlobalVehicle(options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = exports['nbl-target']:addGlobalVehicle(converted[i])
        if h then StoreHandler("globalVehicle", h, converted[i].label) end
    end
end

local function AddGlobalObject(options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = exports['nbl-target']:addGlobalObject(converted[i])
        if h then StoreHandler("globalObject", h, converted[i].label) end
    end
end

local function AddGlobalPlayer(options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = exports['nbl-target']:addGlobalPlayer(converted[i])
        if h then StoreHandler("globalPlayer", h, converted[i].label) end
    end
end

local function AddTargetBone(bones, options)
    local dist = options.distance
    local converted = ConvertOptions(options, dist)
    if type(bones) ~= "table" then bones = {bones} end
    for i = 1, #converted do
        converted[i].bones = bones
        local h = exports['nbl-target']:addGlobalVehicle(converted[i])
        if h then StoreHandler("bones", h, converted[i].label) end
    end
end

local function AddEntityZone(name, entity, options, targetoptions)
    local opts = targetoptions or options
    local dist = opts and opts.distance or 2.0
    local converted = ConvertOptions(opts, dist)
    if entity and entity ~= 0 then
        for i = 1, #converted do
            local h
            if NetworkGetEntityIsNetworked(entity) then
                h = exports['nbl-target']:addEntity(entity, converted[i])
            else
                h = exports['nbl-target']:addLocalEntity(entity, converted[i])
            end
            if h then StoreHandler("entityzone_" .. name, h, converted[i].label) end
        end
    end
end

RegisterExport('AddTargetEntity', AddTargetEntity)
RegisterQTargetExport('AddTargetEntity', AddTargetEntity)

RegisterExport('RemoveTargetEntity', RemoveTargetEntity)
RegisterQTargetExport('RemoveTargetEntity', RemoveTargetEntity)

RegisterExport('AddTargetModel', AddTargetModel)
RegisterQTargetExport('AddTargetModel', AddTargetModel)

RegisterExport('RemoveTargetModel', RemoveTargetModel)
RegisterQTargetExport('RemoveTargetModel', RemoveTargetModel)

RegisterExport('AddGlobalPed', AddGlobalPed)
RegisterQTargetExport('Ped', AddGlobalPed)

RegisterExport('RemoveGlobalPed', function(labels) RemoveHandlers("globalPed", labels) end)
RegisterQTargetExport('RemovePed', function(labels) RemoveHandlers("globalPed", labels) end)

RegisterExport('AddGlobalVehicle', AddGlobalVehicle)
RegisterQTargetExport('Vehicle', AddGlobalVehicle)

RegisterExport('RemoveGlobalVehicle', function(labels) RemoveHandlers("globalVehicle", labels) end)
RegisterQTargetExport('RemoveVehicle', function(labels) RemoveHandlers("globalVehicle", labels) end)

RegisterExport('AddGlobalObject', AddGlobalObject)
RegisterQTargetExport('Object', AddGlobalObject)

RegisterExport('RemoveGlobalObject', function(labels) RemoveHandlers("globalObject", labels) end)
RegisterQTargetExport('RemoveObject', function(labels) RemoveHandlers("globalObject", labels) end)

RegisterExport('AddGlobalPlayer', AddGlobalPlayer)
RegisterQTargetExport('Player', AddGlobalPlayer)

RegisterExport('RemoveGlobalPlayer', function(labels) RemoveHandlers("globalPlayer", labels) end)
RegisterQTargetExport('RemovePlayer', function(labels) RemoveHandlers("globalPlayer", labels) end)

RegisterExport('AddTargetBone', AddTargetBone)
RegisterQTargetExport('AddTargetBone', AddTargetBone)

RegisterExport('RemoveTargetBone', function(_, labels) RemoveHandlers("bones", labels) end)
RegisterQTargetExport('RemoveTargetBone', function(_, labels) RemoveHandlers("bones", labels) end)

RegisterExport('AddEntityZone', AddEntityZone)
RegisterQTargetExport('AddEntityZone', AddEntityZone)

RegisterExport('RemoveEntityZone', function(name) RemoveHandlers("entityzone_" .. name) end)
RegisterQTargetExport('RemoveEntityZone', function(name) RemoveHandlers("entityzone_" .. name) end)

RegisterExport('AddBoxZone', function(name) WarnZone(name) return nil end)
RegisterQTargetExport('AddBoxZone', function(name) WarnZone(name) return nil end)

RegisterExport('AddPolyZone', function(name) WarnZone(name) return nil end)
RegisterQTargetExport('AddPolyZone', function(name) WarnZone(name) return nil end)

RegisterExport('AddCircleZone', function(name) WarnZone(name) return nil end)
RegisterQTargetExport('AddCircleZone', function(name) WarnZone(name) return nil end)

RegisterExport('RemoveZone', function() return nil end)
RegisterQTargetExport('RemoveZone', function() return nil end)

RegisterExport('SpawnPed', function() print('^3[nbl-target] SpawnPed not supported^7') return nil end)
RegisterExport('DeletePed', function() return nil end)

RegisterExport('IsTargetActive', function() return exports['nbl-target']:isActive() end)
RegisterQTargetExport('IsTargetActive', function() return exports['nbl-target']:isActive() end)

RegisterExport('IsTargetSuccess', function() return exports['nbl-target']:isMenuOpen() end)
RegisterQTargetExport('IsTargetSuccess', function() return exports['nbl-target']:isMenuOpen() end)

RegisterExport('GetEntityZone', function() return nil end)
RegisterQTargetExport('GetEntityZone', function() return nil end)

RegisterExport('GetTargetEntity', function() return exports['nbl-target']:getSelectedEntity() end)
RegisterQTargetExport('GetTargetEntity', function() return exports['nbl-target']:getSelectedEntity() end)

RegisterExport('RemoveType', function(entityType, labels)
    local names = {[1] = "globalPed", [2] = "globalVehicle", [3] = "globalObject", [4] = "globalPlayer"}
    if names[entityType] then RemoveHandlers(names[entityType], labels) end
end)
RegisterQTargetExport('RemoveType', function(entityType, labels)
    local names = {[1] = "globalPed", [2] = "globalVehicle", [3] = "globalObject", [4] = "globalPlayer"}
    if names[entityType] then RemoveHandlers(names[entityType], labels) end
end)

RegisterExport('AllowTargeting', function(state)
    if state == false then exports['nbl-target']:disable() else exports['nbl-target']:enable() end
end)
RegisterQTargetExport('AllowTargeting', function(state)
    if state == false then exports['nbl-target']:disable() else exports['nbl-target']:enable() end
end)

RegisterExport('RaycastCamera', function(flag, coords)
    local hit, pos, _, entity = Raycast:FromScreen(vector2(GetControlNormal(0, 239), GetControlNormal(0, 240)), 100.0, flag)
    if hit and entity and entity ~= 0 then
        return pos, coords and #(coords - pos) or 0.0, entity, GetEntityType(entity)
    end
    return coords or vector3(0, 0, 0), 0.0, 0, 0
end)
RegisterQTargetExport('RaycastCamera', function(flag, coords)
    local hit, pos, _, entity = Raycast:FromScreen(vector2(GetControlNormal(0, 239), GetControlNormal(0, 240)), 100.0, flag)
    if hit and entity and entity ~= 0 then
        return pos, coords and #(coords - pos) or 0.0, entity, GetEntityType(entity)
    end
    return coords or vector3(0, 0, 0), 0.0, 0, 0
end)
