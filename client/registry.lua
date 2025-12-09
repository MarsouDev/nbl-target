Registry = {
    entities = {},
    localEntities = {},
    models = {},
    globalTypes = {},
    byName = {},
    byResource = {},
    nextId = 1,
    enabled = true
}

local function GenerateId()
    local id = Registry.nextId
    Registry.nextId = Registry.nextId + 1
    return id
end

local function GetSourceResource()
    local invokingResource = GetInvokingResource()
    if invokingResource then
        return invokingResource
    end
    return GetCurrentResourceName()
end

local function NormalizeModels(models)
    if type(models) == "table" then
        local result = {}
        for _, model in ipairs(models) do
            if type(model) == "string" then
                result[#result + 1] = GetHashKey(model)
            else
                result[#result + 1] = model
            end
        end
        return result
    elseif type(models) == "string" then
        return { GetHashKey(models) }
    else
        return { models }
    end
end

local function NormalizeEntities(entities)
    if type(entities) == "table" and not entities.label then
        return entities
    else
        return { entities }
    end
end

local function CreateHandler(ids, registryType, storage)
    local handler = {
        ids = type(ids) == "table" and ids or { ids },
        registryType = registryType
    }
    
    function handler:remove()
        local count = 0
        for _, id in ipairs(self.ids) do
            if Registry:RemoveById(id) then
                count = count + 1
            end
        end
        return count > 0
    end
    
    function handler:setLabel(newLabel)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry.label = newLabel
            end
        end
        return self
    end
    
    function handler:setIcon(newIcon)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry.icon = newIcon
            end
        end
        return self
    end
    
    function handler:setEnabled(enabled)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry.enabled = enabled
            end
        end
        return self
    end
    
    function handler:setDistance(distance)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry.distance = distance
            end
        end
        return self
    end
    
    function handler:setCanInteract(fn)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry.canInteract = fn
            end
        end
        return self
    end
    
    function handler:setOnSelect(fn)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry.onSelect = fn
            end
        end
        return self
    end
    
    function handler:getId()
        if #self.ids == 1 then
            return self.ids[1]
        end
        return self.ids
    end
    
    return handler
end

local function CreateEntry(id, baseData, options)
    options = options or {}
    
    local entry = {
        id = id,
        label = options.label or "Interact",
        name = options.name,
        icon = options.icon or "fas fa-hand-pointer",
        distance = options.distance or Config.Target.defaultDistance,
        canInteract = options.canInteract,
        onSelect = options.onSelect,
        export = options.export,
        event = options.event,
        serverEvent = options.serverEvent,
        command = options.command,
        items = options.items,
        enabled = options.enabled ~= false,
        shouldClose = options.shouldClose or false,
        resource = options.resource or GetSourceResource()
    }
    
    for k, v in pairs(baseData) do
        entry[k] = v
    end
    
    if entry.name then
        Registry.byName[entry.name] = entry
    end
    
    if entry.resource then
        if not Registry.byResource[entry.resource] then
            Registry.byResource[entry.resource] = {}
        end
        Registry.byResource[entry.resource][id] = entry
    end
    
    return entry
end

local function RemoveEntry(storage, id)
    if storage[id] then
        local entry = storage[id]
        if entry.name then
            Registry.byName[entry.name] = nil
        end
        if entry.resource and Registry.byResource[entry.resource] then
            Registry.byResource[entry.resource][id] = nil
        end
        storage[id] = nil
        return true
    end
    return false
end

function Registry:Enable()
    self.enabled = true
end

function Registry:Disable()
    self.enabled = false
end

function Registry:IsEnabled()
    return self.enabled
end

function Registry:AddEntity(entities, options)
    if not entities then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddEntity: Invalid entity/entities")
        end
        return nil
    end
    
    local normalizedEntities = NormalizeEntities(entities)
    local ids = {}
    
    for _, entity in ipairs(normalizedEntities) do
        if entity and entity ~= 0 then
            local id = GenerateId()
            local entry = CreateEntry(id, {
                entity = entity,
                registryType = "entity"
            }, options)
            
            self.entities[id] = entry
            ids[#ids + 1] = id
        end
    end
    
    if #ids == 0 then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddEntity: No valid entities")
        end
        return nil
    end
    
    return CreateHandler(ids, "entity", self.entities)
end

function Registry:AddLocalEntity(entities, options)
    if not entities then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddLocalEntity: Invalid entity/entities")
        end
        return nil
    end
    
    local normalizedEntities = NormalizeEntities(entities)
    local ids = {}
    
    for _, entity in ipairs(normalizedEntities) do
        if entity and entity ~= 0 then
            local id = GenerateId()
            local entry = CreateEntry(id, {
                entity = entity,
                registryType = "localEntity"
            }, options)
            
            self.localEntities[id] = entry
            ids[#ids + 1] = id
        end
    end
    
    if #ids == 0 then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddLocalEntity: No valid entities")
        end
        return nil
    end
    
    return CreateHandler(ids, "localEntity", self.localEntities)
end

function Registry:AddModel(models, options)
    if not models then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddModel: Invalid model(s)")
        end
        return nil
    end
    
    local normalizedModels = NormalizeModels(models)
    local ids = {}
    
    for _, modelHash in ipairs(normalizedModels) do
        local id = GenerateId()
        local entry = CreateEntry(id, {
            model = modelHash,
            registryType = "model"
        }, options)
        
        self.models[id] = entry
        ids[#ids + 1] = id
    end
    
    return CreateHandler(ids, "model", self.models)
end

local function IsOptionsArray(options)
    if type(options) ~= "table" then return false end
    if options[1] and type(options[1]) == "table" then
        return options[1].label ~= nil or options[1].name ~= nil or options[1].icon ~= nil or options[1].onSelect ~= nil
    end
    return false
end

function Registry:AddGlobalType(entityType, options)
    if IsOptionsArray(options) then
        local ids = {}
        for _, opt in ipairs(options) do
            local id = GenerateId()
            local entry = CreateEntry(id, {
                entityType = entityType,
                registryType = "global"
            }, opt)
            
            self.globalTypes[id] = entry
            ids[#ids + 1] = id
        end
        return CreateHandler(ids, "global", self.globalTypes)
    else
        local id = GenerateId()
        local entry = CreateEntry(id, {
            entityType = entityType,
            registryType = "global"
        }, options)
        
        self.globalTypes[id] = entry
        return CreateHandler(id, "global", self.globalTypes)
    end
end

function Registry:AddGlobalVehicle(options)
    return self:AddGlobalType("vehicle", options)
end

function Registry:AddGlobalPed(options)
    return self:AddGlobalType("ped", options)
end

function Registry:AddGlobalPlayer(options)
    return self:AddGlobalType("player", options)
end

function Registry:AddGlobalSelf(options)
    return self:AddGlobalType("self", options)
end

function Registry:AddGlobalObject(options)
    return self:AddGlobalType("object", options)
end

function Registry:AddGlobalOption(entityType, options)
    return self:AddGlobalType(entityType, options)
end

function Registry:RemoveEntity(id)
    return RemoveEntry(self.entities, id)
end

function Registry:RemoveLocalEntity(id)
    return RemoveEntry(self.localEntities, id)
end

function Registry:RemoveModel(id)
    return RemoveEntry(self.models, id)
end

function Registry:RemoveGlobalType(id)
    return RemoveEntry(self.globalTypes, id)
end

function Registry:RemoveGlobalOption(id)
    return self:RemoveGlobalType(id)
end

function Registry:RemoveGlobalVehicle(id)
    return self:RemoveGlobalType(id)
end

function Registry:RemoveGlobalPed(id)
    return self:RemoveGlobalType(id)
end

function Registry:RemoveGlobalPlayer(id)
    return self:RemoveGlobalType(id)
end

function Registry:RemoveGlobalObject(id)
    return self:RemoveGlobalType(id)
end

function Registry:RemoveByName(name)
    local entry = self.byName[name]
    if not entry then return false end
    
    local storage
    if entry.registryType == "entity" then
        storage = self.entities
    elseif entry.registryType == "localEntity" then
        storage = self.localEntities
    elseif entry.registryType == "model" then
        storage = self.models
    elseif entry.registryType == "global" then
        storage = self.globalTypes
    end
    
    if storage then
        return RemoveEntry(storage, entry.id)
    end
    
    return false
end

function Registry:RemoveByResource(resourceName)
    if not self.byResource[resourceName] then return 0 end
    
    local count = 0
    local toRemove = {}
    
    for id, entry in pairs(self.byResource[resourceName]) do
        toRemove[#toRemove + 1] = {id = id, type = entry.registryType}
    end
    
    for _, item in ipairs(toRemove) do
        local storage
        if item.type == "entity" then
            storage = self.entities
        elseif item.type == "localEntity" then
            storage = self.localEntities
        elseif item.type == "model" then
            storage = self.models
        elseif item.type == "global" then
            storage = self.globalTypes
        end
        
        if storage and RemoveEntry(storage, item.id) then
            count = count + 1
        end
    end
    
    self.byResource[resourceName] = nil
    
    if Config.Debug.enabled and count > 0 then
        print("^3[NBL-Target]^7 Removed " .. count .. " entries from resource: " .. resourceName)
    end
    
    return count
end

function Registry:CleanupInvalidEntities()
    local removed = 0
    
    for id, entry in pairs(self.entities) do
        if entry.entity and not DoesEntityExist(entry.entity) then
            RemoveEntry(self.entities, id)
            removed = removed + 1
        end
    end
    
    for id, entry in pairs(self.localEntities) do
        if entry.entity and not DoesEntityExist(entry.entity) then
            RemoveEntry(self.localEntities, id)
            removed = removed + 1
        end
    end
    
    return removed
end

function Registry:GetEntityRegistrations(entity)
    local results = {}
    
    for _, entry in pairs(self.entities) do
        if entry.entity == entity and entry.enabled then
            results[#results + 1] = entry
        end
    end
    
    for _, entry in pairs(self.localEntities) do
        if entry.entity == entity and entry.enabled then
            results[#results + 1] = entry
        end
    end
    
    return results
end

function Registry:GetModelRegistrations(entity)
    if not entity or entity == 0 then return {} end
    
    local entityModel = GetEntityModel(entity)
    if not entityModel then return {} end
    
    local results = {}
    
    for _, entry in pairs(self.models) do
        if entry.model == entityModel and entry.enabled then
            results[#results + 1] = entry
        end
    end
    
    return results
end

function Registry:GetGlobalTypeRegistrations(entityType)
    local results = {}
    
    for _, entry in pairs(self.globalTypes) do
        if entry.entityType == entityType and entry.enabled then
            results[#results + 1] = entry
        end
    end
    
    return results
end

function Registry:GetAllRegistrations(entity, entityType)
    local results = {}
    
    for _, reg in ipairs(self:GetEntityRegistrations(entity)) do
        results[#results + 1] = reg
    end
    
    for _, reg in ipairs(self:GetModelRegistrations(entity)) do
        results[#results + 1] = reg
    end
    
    for _, reg in ipairs(self:GetGlobalTypeRegistrations(entityType)) do
        results[#results + 1] = reg
    end
    
    return results
end

function Registry:CanInteract(registration, entity, worldPos, bone)
    if not registration.enabled then return false end
    
    local distance = Entity:GetDistance(entity, worldPos)
    if distance > registration.distance then
        return false
    end
    
    if registration.canInteract then
        local success, result = pcall(
            registration.canInteract,
            entity, distance, worldPos, registration.name, bone
        )
        
        if not success then
            if Config.Debug.enabled then
                print("^1[NBL-Target]^7 canInteract error: " .. tostring(result))
            end
            return false
        end
        
        return result == true
    end
    
    return true
end

function Registry:HasAvailableOptions(entity, entityType, worldPos)
    local registrations = self:GetAllRegistrations(entity, entityType)
    
    for _, reg in ipairs(registrations) do
        if self:CanInteract(reg, entity, worldPos, nil) then
            return true
        end
    end
    
    return false
end

function Registry:FilterSubItems(items, entity, worldPos)
    if not items or #items == 0 then return nil end
    
    local filtered = {}
    
    for _, item in ipairs(items) do
        local canShow = true
        
        if item.canInteract then
            local distance = Entity:GetDistance(entity, worldPos)
            local success, result = pcall(item.canInteract, entity, distance, worldPos, item.name or item.id)
            
            if not success then
                if Config.Debug.enabled then
                    print("^1[NBL-Target]^7 SubItem canInteract error: " .. tostring(result))
                end
                canShow = false
            else
                canShow = result == true
            end
        end
        
        if canShow then
            filtered[#filtered + 1] = {
                id = item.id,
                label = item.label,
                icon = item.icon,
                name = item.name,
                shouldClose = item.shouldClose
            }
        end
    end
    
    if #filtered == 0 then return nil end
    return filtered
end

function Registry:GetAvailableOptions(entity, entityType, worldPos)
    local registrations = self:GetAllRegistrations(entity, entityType)
    local available = {}
    
    for _, reg in ipairs(registrations) do
        if self:CanInteract(reg, entity, worldPos, nil) then
            local filteredItems = self:FilterSubItems(reg.items, entity, worldPos)
            
            available[#available + 1] = {
                id = reg.id,
                label = reg.label,
                icon = reg.icon,
                name = reg.name,
                items = filteredItems,
                shouldClose = reg.shouldClose
            }
        end
    end
    
    return available
end

function Registry:ExecuteAction(registration, entity, worldPos)
    if registration.export then
        local dotIndex = string.find(registration.export, "%.")
        if dotIndex then
            local resourceName = string.sub(registration.export, 1, dotIndex - 1)
            local exportName = string.sub(registration.export, dotIndex + 1)
            
            if exports[resourceName] and exports[resourceName][exportName] then
                local success, err = pcall(function()
                    exports[resourceName][exportName](entity, worldPos, registration)
                end)
                if not success and Config.Debug.enabled then
                    print("^1[NBL-Target]^7 Export error: " .. tostring(err))
                end
            end
        end
    elseif registration.event then
        TriggerEvent(registration.event, entity, worldPos, registration)
    elseif registration.serverEvent then
        TriggerServerEvent(registration.serverEvent, entity, worldPos, registration)
    elseif registration.command then
        ExecuteCommand(registration.command)
    elseif registration.onSelect then
        local success, err = pcall(registration.onSelect, entity, worldPos, registration)
        if not success and Config.Debug.enabled then
            print("^1[NBL-Target]^7 onSelect error: " .. tostring(err))
        end
    end
end

function Registry:OnSelect(optionId, entity, worldPos)
    local registration = self.entities[optionId]
        or self.localEntities[optionId]
        or self.models[optionId]
        or self.globalTypes[optionId]
    
    if registration then
        self:ExecuteAction(registration, entity, worldPos)
    end
end

function Registry:GetById(id)
    return self.entities[id]
        or self.localEntities[id]
        or self.models[id]
        or self.globalTypes[id]
end

function Registry:RemoveById(id)
    local entry = self:GetById(id)
    if not entry then return false end
    
    local storage
    if entry.registryType == "entity" then
        storage = self.entities
    elseif entry.registryType == "localEntity" then
        storage = self.localEntities
    elseif entry.registryType == "model" then
        storage = self.models
    elseif entry.registryType == "global" then
        storage = self.globalTypes
    end
    
    if storage then
        return RemoveEntry(storage, id)
    end
    
    return false
end

AddEventHandler('onResourceStop', function(resourceName)
    Registry:RemoveByResource(resourceName)
end)

CreateThread(function()
    while true do
        Wait(30000)
        Registry:CleanupInvalidEntities()
    end
end)
