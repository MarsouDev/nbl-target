local function RegisterExport(name, fn)
    local ok, err = pcall(function()
        AddEventHandler(('__cfx_export_qb-target_%s'):format(name), function(setCB)
            setCB(fn)
        end)
    end)
    if not ok then
        print('^1[nbl-target] Failed to register qb-target export "' .. name .. '": ' .. tostring(err) .. '^7')
    end
end

local function RegisterQTargetExport(name, fn)
    local ok, err = pcall(function()
        AddEventHandler(('__cfx_export_qtarget_%s'):format(name), function(setCB)
            setCB(fn)
        end)
    end)
    if not ok then
        print('^1[nbl-target] Failed to register qtarget export "' .. name .. '": ' .. tostring(err) .. '^7')
    end
end

local function RegisterBothExports(name, fn)
    RegisterExport(name, fn)
    RegisterQTargetExport(name, fn)
end

local function IsValidEntity(entity)
    return entity and type(entity) == 'number' and entity ~= 0
end

local function IsValidTable(t)
    return t ~= nil and type(t) == 'table'
end

local function IsOptionObject(t)
    if not IsValidTable(t) then return false end
    return t.label ~= nil or t.name ~= nil or t.icon ~= nil or
           t.action ~= nil or t.event ~= nil or t.canInteract ~= nil
end

local function IsOptionsArray(t)
    if not IsValidTable(t) then return false end
    for k, v in pairs(t) do
        if type(k) == 'number' and IsValidTable(v) and (v.label or v.name or v.action or v.event) then
            return true
        end
    end
    return false
end

local function CreateDataObject(entity, coords, opt)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local entityCoords = pedCoords
    local model, eType = nil, nil

    if coords and type(coords) == 'vector3' then
        entityCoords = coords
    elseif IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
        entityCoords = GetEntityCoords(entity)
        model = GetEntityModel(entity)
        eType = GetEntityType(entity)
    end

    local data = {
        entity = entity or 0,
        coords = entityCoords,
        distance = #(pedCoords - entityCoords),
        model = model,
        hash = model,
        type = eType,
        bone = nil,
        name = opt and (opt.name or opt.label) or nil,
        label = opt and opt.label or nil
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

local function ConvertOption(opt, defaultDist)
    if not IsValidTable(opt) then return nil end
    if not opt.label and not opt.name and not opt.action and not opt.event then return nil end

    local converted = {
        label = opt.label or opt.name or 'Interact',
        name = opt.name or opt.label,
        icon = opt.icon or opt.targeticon,
        distance = opt.distance or defaultDist,
        shouldClose = true
    }

    local conditionWrapper = TargetFramework and TargetFramework.CreateConditionWrapper(opt) or nil

    local originalCanInteract = nil
    if opt.canInteract then
        local original = opt.canInteract
        originalCanInteract = function(entity, distance, coords, name, bone)
            local data = CreateDataObject(entity, coords, opt)
            data.distance = distance
            data.bone = bone

            local ok, result = pcall(original, entity, distance, data)
            if ok then return result == true or result == nil end

            ok, result = pcall(original, data)
            if ok then return result == true or result == nil end

            ok, result = pcall(original, entity)
            if ok then return result == true or result == nil end

            if Config and Config.Debug and Config.Debug.enabled then
                print('^3[nbl-target] qb-target canInteract failed for "' .. tostring(opt.label or opt.name) .. '"^7')
            end
            return false
        end
    end

    if conditionWrapper or originalCanInteract then
        converted.canInteract = TargetFramework and TargetFramework.WrapCanInteract(originalCanInteract, conditionWrapper) or originalCanInteract
    end

    if opt.action then
        local original = opt.action
        converted.onSelect = function(entity, coords)
            local data = CreateDataObject(entity, coords, opt)
            local ok, err = pcall(original, data)
            if not ok then
                ok, err = pcall(original, entity)
                if not ok and Config and Config.Debug and Config.Debug.enabled then
                    print('^1[nbl-target] qb-target action error: ' .. tostring(err) .. '^7')
                end
            end
        end
    elseif opt.event then
        local eventType = opt.type or 'client'
        if eventType == 'server' then
            converted.onSelect = function(entity, coords)
                TriggerServerEvent(opt.event, CreateDataObject(entity, coords, opt))
            end
        elseif eventType == 'command' then
            converted.command = opt.event
        elseif eventType == 'qbcommand' then
            converted.onSelect = function()
                ExecuteCommand(opt.event)
            end
        else
            converted.onSelect = function(entity, coords)
                TriggerEvent(opt.event, CreateDataObject(entity, coords, opt))
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
        if options.distance and type(options.distance) == 'number' then
            dist = options.distance
        end
    end

    if IsOptionObject(opts) and not IsOptionsArray(opts) and not opts.options then
        local c = ConvertOption(opts, dist)
        if c then result[1] = c end
        return result
    end

    if IsValidTable(opts) then
        for _, opt in pairs(opts) do
            if IsValidTable(opt) then
                local c = ConvertOption(opt, dist)
                if c then
                    idx = idx + 1
                    result[idx] = c
                end
            end
        end
    end

    return result
end

local Handlers = {}

local function MakeKey(prefix, id)
    return prefix .. '_' .. tostring(id)
end

local function StoreHandler(key, handler, label)
    if not Handlers[key] then Handlers[key] = {} end
    Handlers[key][#Handlers[key] + 1] = { handler = handler, label = label }
end

local function RemoveHandlers(key, labels)
    local stored = Handlers[key]
    if not stored then return end

    if not labels then
        for i = 1, #stored do
            local h = stored[i].handler
            if h and type(h.remove) == 'function' then
                pcall(h.remove, h)
            end
        end
        Handlers[key] = nil
        return
    end

    local labelSet = {}
    if type(labels) == 'table' then
        for i = 1, #labels do labelSet[labels[i]] = true end
    else
        labelSet[labels] = true
    end

    local remaining = {}
    for i = 1, #stored do
        local item = stored[i]
        if labelSet[item.label] then
            if item.handler and type(item.handler.remove) == 'function' then
                pcall(item.handler.remove, item.handler)
            end
        else
            remaining[#remaining + 1] = item
        end
    end
    Handlers[key] = #remaining > 0 and remaining or nil
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

local function AddTargetEntity(entities, options)
    if not entities or not options then return end
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    if #converted == 0 then return end

    local entityList = type(entities) == 'table' and entities or {entities}

    for e = 1, #entityList do
        local entity = entityList[e]
        if IsValidEntity(entity) and GetEntityType(entity) ~= 0 then
            local key = MakeKey('entity', entity)
            local isNetworked = NetworkGetEntityIsNetworked(entity)
            for i = 1, #converted do
                local h = isNetworked and Registry:AddEntity(entity, converted[i]) or Registry:AddLocalEntity(entity, converted[i])
                if h then StoreHandler(key, h, converted[i].label) end
            end
        end
    end
end

local function RemoveTargetEntity(entities, labels)
    if not entities then return end
    local entityList = type(entities) == 'table' and entities or {entities}
    for e = 1, #entityList do
        if entityList[e] then RemoveHandlers(MakeKey('entity', entityList[e]), labels) end
    end
end

local function AddTargetModel(models, options)
    if not models or not options then return end
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    if #converted == 0 then return end

    local modelList = type(models) == 'table' and models or {models}

    for m = 1, #modelList do
        local model = modelList[m]
        if model then
            local hash = type(model) == 'string' and joaat(model) or model
            local key = MakeKey('model', hash)
            for i = 1, #converted do
                local h = Registry:AddModel(hash, converted[i])
                if h then StoreHandler(key, h, converted[i].label) end
            end
        end
    end
end

local function RemoveTargetModel(models, labels)
    if not models then return end
    local modelList = type(models) == 'table' and models or {models}
    for m = 1, #modelList do
        local model = modelList[m]
        if model then
            local hash = type(model) == 'string' and joaat(model) or model
            RemoveHandlers(MakeKey('model', hash), labels)
        end
    end
end

local function AddGlobalPed(options)
    if not options then return end
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = Registry:AddGlobalPed(converted[i])
        if h then StoreHandler('globalPed', h, converted[i].label) end
    end
end

local function AddGlobalVehicle(options)
    if not options then return end
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = Registry:AddGlobalVehicle(converted[i])
        if h then StoreHandler('globalVehicle', h, converted[i].label) end
    end
end

local function AddGlobalObject(options)
    if not options then return end
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = Registry:AddGlobalObject(converted[i])
        if h then StoreHandler('globalObject', h, converted[i].label) end
    end
end

local function AddGlobalPlayer(options)
    if not options then return end
    local dist = options.distance or Config.Target.defaultDistance
    local converted = ConvertOptions(options, dist)
    for i = 1, #converted do
        local h = Registry:AddGlobalPlayer(converted[i])
        if h then StoreHandler('globalPlayer', h, converted[i].label) end
    end
end

local BoneWarned = false

local function AddTargetBone()
    if not BoneWarned then
        BoneWarned = true
        print('^3[nbl-target] Bone targeting not supported - use entity or model targeting instead^7')
    end
    return nil
end

local function RemoveTargetBone()
    return nil
end

local function AddEntityZone(name, entity, options, targetoptions)
    if not name or not IsValidEntity(entity) then return nil end
    local opts = targetoptions or options
    if not opts then return nil end

    local dist = opts.distance or 2.0
    local converted = ConvertOptions(opts, dist)
    if #converted == 0 then return nil end

    local key = MakeKey('entityzone', name)
    local isNetworked = NetworkGetEntityIsNetworked(entity)

    for i = 1, #converted do
        local h = isNetworked and Registry:AddEntity(entity, converted[i]) or Registry:AddLocalEntity(entity, converted[i])
        if h then StoreHandler(key, h, converted[i].label) end
    end

    return name
end

local function RemoveEntityZone(name)
    if name then RemoveHandlers(MakeKey('entityzone', name)) end
end

local function AddBoxZone(name)
    return WarnZone(name, 'BoxZone')
end

local function AddCircleZone(name)
    return WarnZone(name, 'CircleZone')
end

local function AddPolyZone(name)
    return WarnZone(name, 'PolyZone')
end

local function RemoveZone(name)
    if name then RemoveHandlers(MakeKey('entityzone', name)) end
    return nil
end

local function SpawnPed()
    print('^3[nbl-target] SpawnPed not supported - use your own ped spawning system^7')
    return nil
end

local function DeletePed()
    return nil
end

local function AllowTargeting(state)
    if state == false then
        Registry:Disable()
    else
        Registry:Enable()
    end
end

local function IsTargetActive()
    local ok, result = pcall(exports['nbl-target'].isActive, exports['nbl-target'])
    return ok and result or false
end

local function IsTargetSuccess()
    local ok, result = pcall(exports['nbl-target'].isMenuOpen, exports['nbl-target'])
    return ok and result or false
end

local function GetTargetEntity()
    local ok, result = pcall(exports['nbl-target'].getSelectedEntity, exports['nbl-target'])
    return ok and result or nil
end

local function GetEntityZone()
    return nil
end

local function RaycastCamera(flag, playerCoords)
    local hit, pos, entity
    local ok = pcall(function()
        local cursor = vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
        hit, pos, _, entity = Raycast:FromScreen(cursor, 100.0, flag or 287)
    end)

    if ok and hit and entity and entity ~= 0 then
        local dist = playerCoords and #(playerCoords - pos) or 0.0
        return pos, dist, entity, GetEntityType(entity)
    end

    return playerCoords or vector3(0, 0, 0), 0.0, 0, 0
end

local function RemoveType(entityType, labels)
    local typeMap = {
        [1] = 'globalPed',
        [2] = 'globalVehicle',
        [3] = 'globalObject',
        [4] = 'globalPlayer'
    }
    local key = typeMap[entityType]
    if key then RemoveHandlers(key, labels) end
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
    RemoveGlobalPed = function(labels) RemoveHandlers('globalPed', labels) end,
    RemovePed = function(labels) RemoveHandlers('globalPed', labels) end,
    AddGlobalVehicle = AddGlobalVehicle,
    Vehicle = AddGlobalVehicle,
    RemoveGlobalVehicle = function(labels) RemoveHandlers('globalVehicle', labels) end,
    RemoveVehicle = function(labels) RemoveHandlers('globalVehicle', labels) end,
    AddGlobalObject = AddGlobalObject,
    Object = AddGlobalObject,
    RemoveGlobalObject = function(labels) RemoveHandlers('globalObject', labels) end,
    RemoveObject = function(labels) RemoveHandlers('globalObject', labels) end,
    AddGlobalPlayer = AddGlobalPlayer,
    Player = AddGlobalPlayer,
    RemoveGlobalPlayer = function(labels) RemoveHandlers('globalPlayer', labels) end,
    RemovePlayer = function(labels) RemoveHandlers('globalPlayer', labels) end,
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
RegisterBothExports('RemoveGlobalPed', function(labels) RemoveHandlers('globalPed', labels) end)
RegisterBothExports('RemovePed', function(labels) RemoveHandlers('globalPed', labels) end)
RegisterBothExports('AddGlobalVehicle', AddGlobalVehicle)
RegisterBothExports('Vehicle', AddGlobalVehicle)
RegisterBothExports('RemoveGlobalVehicle', function(labels) RemoveHandlers('globalVehicle', labels) end)
RegisterBothExports('RemoveVehicle', function(labels) RemoveHandlers('globalVehicle', labels) end)
RegisterBothExports('AddGlobalObject', AddGlobalObject)
RegisterBothExports('Object', AddGlobalObject)
RegisterBothExports('RemoveGlobalObject', function(labels) RemoveHandlers('globalObject', labels) end)
RegisterBothExports('RemoveObject', function(labels) RemoveHandlers('globalObject', labels) end)
RegisterBothExports('AddGlobalPlayer', AddGlobalPlayer)
RegisterBothExports('Player', AddGlobalPlayer)
RegisterBothExports('RemoveGlobalPlayer', function(labels) RemoveHandlers('globalPlayer', labels) end)
RegisterBothExports('RemovePlayer', function(labels) RemoveHandlers('globalPlayer', labels) end)
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

if Config and Config.Debug and Config.Debug.enabled then
    print('^2[nbl-target] qb-target/qtarget bridge loaded^7')
end
