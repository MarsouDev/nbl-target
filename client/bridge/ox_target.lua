local function RegisterExport(name, fn)
    local ok, err = pcall(function()
        AddEventHandler(('__cfx_export_ox_target_%s'):format(name), function(setCB)
            setCB(fn)
        end)
    end)
    if not ok then
        print('^1[nbl-target] Failed to register ox_target export "' .. name .. '": ' .. tostring(err) .. '^7')
    end
end

local function IsValidEntity(entity)
    return entity and type(entity) == 'number' and entity ~= 0
end

local function IsValidTable(t)
    return t ~= nil and type(t) == 'table'
end

local function IsArrayLike(t)
    if not IsValidTable(t) then return false end
    for k in pairs(t) do
        if type(k) ~= 'number' then return false end
    end
    return true
end

local function IsOptionObject(t)
    if not IsValidTable(t) then return false end
    return t.label ~= nil or t.name ~= nil or t.icon ~= nil or
           t.onSelect ~= nil or t.event ~= nil or t.serverEvent ~= nil or
           t.command ~= nil or t.canInteract ~= nil
end

local function CreateDataObject(entity, coords, opt)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local entityCoords = pedCoords
    local model = nil

    if coords and type(coords) == 'vector3' then
        entityCoords = coords
    elseif IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
        entityCoords = GetEntityCoords(entity)
        model = GetEntityModel(entity)
    end

    local data = {
        entity = entity or 0,
        coords = entityCoords,
        distance = #(pedCoords - entityCoords),
        model = model,
        name = opt and opt.name or nil,
        bone = nil,
        resource = opt and opt.resource or GetInvokingResource() or GetCurrentResourceName()
    }

    if IsValidTable(opt) then
        for k, v in pairs(opt) do
            if data[k] == nil and type(v) ~= 'function' then
                data[k] = v
            end
        end
    end

    return data
end

local function ConvertOption(opt)
    if not IsValidTable(opt) then return nil end
    if not opt.label and not opt.name then return nil end

    local converted = {
        label = opt.label or opt.name or 'Interact',
        name = opt.name or opt.label,
        icon = opt.icon,
        distance = opt.distance,
        shouldClose = opt.shouldClose ~= false
    }

    local conditionWrapper = TargetFramework and TargetFramework.CreateConditionWrapper(opt) or nil

    local originalCanInteract = nil
    if opt.canInteract then
        local original = opt.canInteract
        local optionName = opt.label or opt.name or 'unknown'
        originalCanInteract = function(entity, distance, coords, name, bone)
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
                print('^1[nbl-target] ox_target canInteract error for "' .. tostring(optionName) .. '": ' .. tostring(result) .. '^7')
            end
            return false
        end
    end

    if conditionWrapper or originalCanInteract then
        converted.canInteract = TargetFramework and TargetFramework.WrapCanInteract(originalCanInteract, conditionWrapper) or originalCanInteract
    end

    if opt.onSelect then
        local original = opt.onSelect
        local optionName = opt.label or opt.name or 'unknown'
        converted.onSelect = function(entity, coords)
            local data = CreateDataObject(entity, coords, opt)
            local ok, err = pcall(original, data)
            if not ok then
                if Config and Config.Debug and Config.Debug.enabled then
                    print('^1[nbl-target] ox_target onSelect error for "' .. tostring(optionName) .. '": ' .. tostring(err) .. '^7')
                end
            end
        end
    elseif opt.export then
        local exportStr = opt.export
        if type(exportStr) == 'string' then
            local dotIdx = exportStr:find('%.')
            if dotIdx then
                local resName = exportStr:sub(1, dotIdx - 1)
                local expName = exportStr:sub(dotIdx + 1)
                converted.onSelect = function(entity, coords)
                    local data = CreateDataObject(entity, coords, opt)
                    if exports[resName] and exports[resName][expName] then
                        local ok, err = pcall(exports[resName][expName], data)
                        if not ok then
                            if Config and Config.Debug and Config.Debug.enabled then
                                print('^1[nbl-target] ox_target export "' .. exportStr .. '" error: ' .. tostring(err) .. '^7')
                            end
                        end
                    elseif Config and Config.Debug and Config.Debug.enabled then
                        print('^3[nbl-target] ox_target export not found: ' .. exportStr .. '^7')
                    end
                end
            end
        end
    elseif opt.event then
        converted.onSelect = function(entity, coords)
            TriggerEvent(opt.event, CreateDataObject(entity, coords, opt))
        end
    elseif opt.serverEvent then
        converted.onSelect = function(entity, coords)
            TriggerServerEvent(opt.serverEvent, CreateDataObject(entity, coords, opt))
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
        local c = ConvertOption(options)
        if c then result[1] = c end
        return result
    end

    if IsValidTable(options) then
        for _, opt in pairs(options) do
            if IsValidTable(opt) then
                if IsOptionObject(opt) then
                    local c = ConvertOption(opt)
                    if c then
                        idx = idx + 1
                        result[idx] = c
                    end
                elseif opt.options then
                    for _, subOpt in pairs(opt.options) do
                        local c = ConvertOption(subOpt)
                        if c then
                            idx = idx + 1
                            result[idx] = c
                        end
                    end
                end
            end
        end
    end

    return result
end

local Handlers = {
    byKey = {},
    byId = {}
}

local function StoreHandlers(key, list)
    if not list or #list == 0 then return end
    Handlers.byKey[key] = list
    for i = 1, #list do
        local h = list[i]
        if h then
            local hId = type(h.getId) == 'function' and h:getId() or h
            Handlers.byId[hId] = h
        end
    end
end

local function RemoveHandlersByKey(key)
    local list = Handlers.byKey[key]
    if not list then return false end
    for i = 1, #list do
        local h = list[i]
        if h and type(h.remove) == 'function' then
            pcall(h.remove, h)
        end
    end
    Handlers.byKey[key] = nil
    return true
end

local function RemoveHandlersByIds(ids)
    if not ids then return end
    local list = type(ids) == 'table' and ids or {ids}
    for i = 1, #list do
        local id = list[i]
        if id then
            if type(id) == 'table' and type(id.remove) == 'function' then
                pcall(id.remove, id)
            elseif Handlers.byId[id] then
                local h = Handlers.byId[id]
                if type(h.remove) == 'function' then
                    pcall(h.remove, h)
                end
                Handlers.byId[id] = nil
            end
        end
    end
end

local ZoneWarnings = {}

local function WarnZone(name, zoneType)
    local key = tostring(zoneType) .. '_' .. tostring(name)
    if not ZoneWarnings[key] then
        ZoneWarnings[key] = true
        print('^3[nbl-target] ' .. zoneType .. ' "' .. tostring(name) .. '" not supported - use entity/model targeting instead^7')
    end
    return nil
end

local function MakeKey(prefix, id)
    return prefix .. '_' .. tostring(id)
end

RegisterExport('addGlobalVehicle', function(options)
    if not options then return {} end
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        local h = Registry:AddGlobalVehicle(converted[i])
        if h then handlers[#handlers + 1] = h end
    end
    if #handlers > 0 then StoreHandlers('globalVehicle', handlers) end
    return handlers
end)

RegisterExport('removeGlobalVehicle', RemoveHandlersByIds)

RegisterExport('addGlobalPed', function(options)
    if not options then return {} end
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        local h = Registry:AddGlobalPed(converted[i])
        if h then handlers[#handlers + 1] = h end
    end
    if #handlers > 0 then StoreHandlers('globalPed', handlers) end
    return handlers
end)

RegisterExport('removeGlobalPed', RemoveHandlersByIds)

RegisterExport('addGlobalPlayer', function(options)
    if not options then return {} end
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        local h = Registry:AddGlobalPlayer(converted[i])
        if h then handlers[#handlers + 1] = h end
    end
    if #handlers > 0 then StoreHandlers('globalPlayer', handlers) end
    return handlers
end)

RegisterExport('removeGlobalPlayer', RemoveHandlersByIds)

RegisterExport('addGlobalObject', function(options)
    if not options then return {} end
    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        local h = Registry:AddGlobalObject(converted[i])
        if h then handlers[#handlers + 1] = h end
    end
    if #handlers > 0 then StoreHandlers('globalObject', handlers) end
    return handlers
end)

RegisterExport('removeGlobalObject', RemoveHandlersByIds)

RegisterExport('addModel', function(models, options)
    if not models or not options then return {} end
    local converted = ConvertOptions(options)
    if #converted == 0 then return {} end

    local allHandlers = {}
    local modelList = type(models) == 'table' and not IsOptionObject(models) and models or {models}

    for m = 1, #modelList do
        local model = modelList[m]
        if model then
            local hash = type(model) == 'string' and joaat(model) or model
            local key = MakeKey('model', hash)
            local handlers = {}
            for i = 1, #converted do
                local h = Registry:AddModel(hash, converted[i])
                if h then
                    handlers[#handlers + 1] = h
                    allHandlers[#allHandlers + 1] = h
                end
            end
            if #handlers > 0 then StoreHandlers(key, handlers) end
        end
    end

    return allHandlers
end)

RegisterExport('removeModel', function(models, ids)
    if ids then
        RemoveHandlersByIds(ids)
    elseif models then
        local list = type(models) == 'table' and models or {models}
        for m = 1, #list do
            local model = list[m]
            if model then
                local hash = type(model) == 'string' and joaat(model) or model
                RemoveHandlersByKey(MakeKey('model', hash))
            end
        end
    end
end)

RegisterExport('addEntity', function(netIds, options)
    if not netIds or not options then return {} end
    local converted = ConvertOptions(options)
    if #converted == 0 then return {} end

    local handlers = {}
    local netIdList = type(netIds) == 'table' and netIds or {netIds}

    for n = 1, #netIdList do
        local netId = netIdList[n]
        if netId then
            local entity = 0
            local ok, result = pcall(NetworkGetEntityFromNetworkId, netId)
            if ok and result and result ~= 0 then
                entity = result
            elseif type(netId) == 'number' and netId > 0 then
                local eType = GetEntityType(netId)
                if eType ~= 0 then
                    entity = netId
                end
            end

            if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
                local key = MakeKey('entity', netId)
                local modelHandlers = {}
                for i = 1, #converted do
                    local h = Registry:AddEntity(entity, converted[i])
                    if h then
                        modelHandlers[#modelHandlers + 1] = h
                        handlers[#handlers + 1] = h
                    end
                end
                if #modelHandlers > 0 then StoreHandlers(key, modelHandlers) end
            end
        end
    end

    return handlers
end)

RegisterExport('removeEntity', function(netIds, ids)
    if ids then
        RemoveHandlersByIds(ids)
    elseif netIds then
        local list = type(netIds) == 'table' and netIds or {netIds}
        for n = 1, #list do
            if list[n] then RemoveHandlersByKey(MakeKey('entity', list[n])) end
        end
    end
end)

RegisterExport('addLocalEntity', function(entities, options)
    if not entities or not options then return {} end
    local converted = ConvertOptions(options)
    if #converted == 0 then return {} end

    local handlers = {}
    local entityList = type(entities) == 'table' and entities or {entities}

    for e = 1, #entityList do
        local entity = entityList[e]
        if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
            local key = MakeKey('localEntity', entity)
            local entityHandlers = {}
            for i = 1, #converted do
                local h = Registry:AddLocalEntity(entity, converted[i])
                if h then
                    entityHandlers[#entityHandlers + 1] = h
                    handlers[#handlers + 1] = h
                end
            end
            if #entityHandlers > 0 then StoreHandlers(key, entityHandlers) end
        end
    end

    return handlers
end)

RegisterExport('removeLocalEntity', function(entities, ids)
    if ids then
        RemoveHandlersByIds(ids)
    elseif entities then
        local list = type(entities) == 'table' and entities or {entities}
        for e = 1, #list do
            if list[e] then RemoveHandlersByKey(MakeKey('localEntity', list[e])) end
        end
    end
end)

RegisterExport('addSphereZone', function(data)
    return IsValidTable(data) and WarnZone(data.name, 'SphereZone') or nil
end)

RegisterExport('addBoxZone', function(data)
    return IsValidTable(data) and WarnZone(data.name, 'BoxZone') or nil
end)

RegisterExport('addPolyZone', function(data)
    return IsValidTable(data) and WarnZone(data.name, 'PolyZone') or nil
end)

RegisterExport('removeZone', function()
    return true
end)

RegisterExport('disableTargeting', function(state)
    if state then
        Registry:Disable()
    else
        Registry:Enable()
    end
end)

RegisterExport('isActive', function()
    local ok, result = pcall(exports['nbl-target'].isActive, exports['nbl-target'])
    return ok and result or false
end)

RegisterExport('getEntityOptions', function()
    return nil
end)

RegisterExport('getZoneOptions', function()
    return nil
end)

RegisterExport('getGlobalOptions', function()
    return nil
end)

RegisterExport('getCurrentTarget', function()
    local ok, result = pcall(exports['nbl-target'].getCurrentTarget, exports['nbl-target'])
    return ok and result or nil
end)

RegisterExport('getTarget', function()
    local ok, result = pcall(exports['nbl-target'].getSelectedEntity, exports['nbl-target'])
    return ok and result or nil
end)

RegisterExport('setEntityOptions', function(entity, options)
    if not IsValidEntity(entity) then return {} end
    RemoveHandlersByKey(MakeKey('localEntity', entity))
    if not options then return {} end

    local converted = ConvertOptions(options)
    local handlers = {}
    for i = 1, #converted do
        local h = Registry:AddLocalEntity(entity, converted[i])
        if h then handlers[#handlers + 1] = h end
    end
    if #handlers > 0 then StoreHandlers(MakeKey('localEntity', entity), handlers) end
    return handlers
end)

RegisterExport('enable', function()
    Registry:Enable()
end)

RegisterExport('disable', function()
    Registry:Disable()
end)

RegisterExport('debug', function(state)
    if Config and Config.Debug then
        Config.Debug.enabled = state == true
    end
end)

if Config and Config.Debug and Config.Debug.enabled then
    print('^2[nbl-target] ox_target bridge loaded^7')
end
