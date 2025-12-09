Registry = {
    entities = {},
    localEntities = {},
    models = {},
    globalTypes = {},
    
    byName = {},
    byResource = {},
    
    nextId = 1,
    subItemNextId = 10000,
    
    enabled = true,
    activeSubItems = {},
    subItemIdMap = {}
}

local function GenerateId()
    local id = Registry.nextId
    Registry.nextId = id + 1
    return id
end

local function GenerateSubItemId()
    local id = Registry.subItemNextId
    Registry.subItemNextId = id + 1
    return id
end

local function GetSourceResource()
    return GetInvokingResource() or GetCurrentResourceName()
end

local function NormalizeModels(models)
    local modelType = type(models)
    
    if modelType == "table" then
        local result = {}
        for i, model in ipairs(models) do
            result[i] = type(model) == "string" and GetHashKey(model) or model
        end
        return result
    elseif modelType == "string" then
        return { GetHashKey(models) }
    else
        return { models }
    end
end

local function NormalizeEntities(entities)
    if type(entities) == "table" and not entities.label then
        return entities
    end
    return { entities }
end

local function CreateHandler(ids, registryType)
    local handler = {
        ids = type(ids) == "table" and ids or { ids },
        registryType = registryType
    }
    
    local function UpdateEntries(self, key, value)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry then
                entry[key] = value
            end
        end
        return self
    end
    
    function handler:remove()
        local removed = 0
        for _, id in ipairs(self.ids) do
            if Registry:RemoveById(id) then
                removed = removed + 1
            end
        end
        return removed > 0
    end
    
    function handler:setLabel(label)
        return UpdateEntries(self, "label", label)
    end
    
    function handler:setIcon(icon)
        return UpdateEntries(self, "icon", icon)
    end
    
    function handler:setEnabled(enabled)
        return UpdateEntries(self, "enabled", enabled)
    end
    
    function handler:setDistance(distance)
        return UpdateEntries(self, "distance", distance)
    end
    
    function handler:setCanInteract(fn)
        return UpdateEntries(self, "canInteract", fn)
    end
    
    function handler:setOnSelect(fn)
        return UpdateEntries(self, "onSelect", fn)
    end
    
    function handler:setOnCheck(fn)
        return UpdateEntries(self, "onCheck", fn)
    end
    
    function handler:setChecked(checked)
        for _, id in ipairs(self.ids) do
            local entry = Registry:GetById(id)
            if entry and entry.checkbox then
                entry.checked = checked
            end
        end
        return self
    end
    
    function handler:getId()
        return #self.ids == 1 and self.ids[1] or self.ids
    end
    
    return handler
end

local function CreateEntry(id, baseData, options)
    options = options or {}
    
    local hasCheckbox = options.checkbox == true
    local hasItems = options.items and #options.items > 0
    
    if hasCheckbox and hasItems then
        if Config.Debug.enabled then
            print("^3[NBL-Target]^7 Warning: '" .. (options.label or "unknown") .. "' has both checkbox and items. Items ignored.")
        end
        hasItems = false
    end
    
    local resource = options.resource or GetSourceResource()
    
    local entry = {
        id = id,
        label = options.label or "Interact",
        name = options.name,
        icon = options.icon or "fas fa-hand-pointer",
        distance = options.distance or Config.Target.defaultDistance,
        enabled = options.enabled ~= false,
        shouldClose = options.shouldClose or false,
        resource = resource,
        canInteract = options.canInteract,
        onSelect = options.onSelect,
        onCheck = options.onCheck,
        checkbox = hasCheckbox,
        checked = options.checked,
        export = options.export,
        event = options.event,
        serverEvent = options.serverEvent,
        command = options.command,
        items = hasItems and options.items or nil
    }
    
    for key, value in pairs(baseData) do
        entry[key] = value
    end
    
    if entry.name then
        Registry.byName[entry.name] = entry
    end
    
    if not Registry.byResource[resource] then
        Registry.byResource[resource] = {}
    end
    Registry.byResource[resource][id] = entry
    
    return entry
end

local function RemoveEntry(storage, id)
    local entry = storage[id]
    if not entry then return false end
    
    if entry.name then
        Registry.byName[entry.name] = nil
    end
    
    if entry.resource and Registry.byResource[entry.resource] then
        Registry.byResource[entry.resource][id] = nil
    end
    
    storage[id] = nil
    return true
end

local function GetStorageByType(registryType)
    local storageMap = {
        entity = Registry.entities,
        localEntity = Registry.localEntities,
        model = Registry.models,
        global = Registry.globalTypes
    }
    return storageMap[registryType]
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
            print("^1[NBL-Target]^7 AddEntity: Invalid entity")
        end
        return nil
    end
    
    local normalizedEntities = NormalizeEntities(entities)
    local ids = {}
    
    for _, entity in ipairs(normalizedEntities) do
        if entity and entity ~= 0 then
            local id = GenerateId()
            self.entities[id] = CreateEntry(id, { entity = entity, registryType = "entity" }, options)
            ids[#ids + 1] = id
        end
    end
    
    if #ids == 0 then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddEntity: No valid entities")
        end
        return nil
    end
    
    return CreateHandler(ids, "entity")
end

function Registry:AddLocalEntity(entities, options)
    if not entities then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddLocalEntity: Invalid entity")
        end
        return nil
    end
    
    local normalizedEntities = NormalizeEntities(entities)
    local ids = {}
    
    for _, entity in ipairs(normalizedEntities) do
        if entity and entity ~= 0 then
            local id = GenerateId()
            self.localEntities[id] = CreateEntry(id, { entity = entity, registryType = "localEntity" }, options)
            ids[#ids + 1] = id
        end
    end
    
    if #ids == 0 then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddLocalEntity: No valid entities")
        end
        return nil
    end
    
    return CreateHandler(ids, "localEntity")
end

function Registry:AddModel(models, options)
    if not models then
        if Config.Debug.enabled then
            print("^1[NBL-Target]^7 AddModel: Invalid model")
        end
        return nil
    end
    
    local normalizedModels = NormalizeModels(models)
    local ids = {}
    
    for _, modelHash in ipairs(normalizedModels) do
        local id = GenerateId()
        self.models[id] = CreateEntry(id, { model = modelHash, registryType = "model" }, options)
        ids[#ids + 1] = id
    end
    
    return CreateHandler(ids, "model")
end

local function IsOptionsArray(options)
    if type(options) ~= "table" then return false end
    local first = options[1]
    return first and type(first) == "table" and (first.label or first.name or first.icon or first.onSelect)
end

function Registry:AddGlobalType(entityType, options)
    local ids = {}
    local baseData = { entityType = entityType, registryType = "global" }
    
    if IsOptionsArray(options) then
        for _, opt in ipairs(options) do
            local id = GenerateId()
            self.globalTypes[id] = CreateEntry(id, baseData, opt)
            ids[#ids + 1] = id
        end
    else
        local id = GenerateId()
        self.globalTypes[id] = CreateEntry(id, baseData, options)
        ids[#ids + 1] = id
    end
    
    return CreateHandler(ids, "global")
end

function Registry:AddGlobalVehicle(options) return self:AddGlobalType("vehicle", options) end
function Registry:AddGlobalPed(options) return self:AddGlobalType("ped", options) end
function Registry:AddGlobalPlayer(options) return self:AddGlobalType("player", options) end
function Registry:AddGlobalSelf(options) return self:AddGlobalType("self", options) end
function Registry:AddGlobalObject(options) return self:AddGlobalType("object", options) end
function Registry:AddGlobalOption(entityType, options) return self:AddGlobalType(entityType, options) end

function Registry:RemoveEntity(id) return RemoveEntry(self.entities, id) end
function Registry:RemoveLocalEntity(id) return RemoveEntry(self.localEntities, id) end
function Registry:RemoveModel(id) return RemoveEntry(self.models, id) end
function Registry:RemoveGlobalType(id) return RemoveEntry(self.globalTypes, id) end
function Registry:RemoveGlobalOption(id) return self:RemoveGlobalType(id) end
function Registry:RemoveGlobalVehicle(id) return self:RemoveGlobalType(id) end
function Registry:RemoveGlobalPed(id) return self:RemoveGlobalType(id) end
function Registry:RemoveGlobalPlayer(id) return self:RemoveGlobalType(id) end
function Registry:RemoveGlobalObject(id) return self:RemoveGlobalType(id) end

function Registry:RemoveByName(name)
    local entry = self.byName[name]
    if not entry then return false end
    
    local storage = GetStorageByType(entry.registryType)
    return storage and RemoveEntry(storage, entry.id) or false
end

function Registry:RemoveByResource(resourceName)
    local resourceEntries = self.byResource[resourceName]
    if not resourceEntries then return 0 end
    
    local count = 0
    
    local toRemove = {}
    for id, entry in pairs(resourceEntries) do
        toRemove[#toRemove + 1] = { id = id, registryType = entry.registryType }
    end
    
    for _, item in ipairs(toRemove) do
        local storage = GetStorageByType(item.registryType)
        if storage and RemoveEntry(storage, item.id) then
            count = count + 1
        end
    end
    
    self.byResource[resourceName] = nil
    
    if Config.Debug.enabled and count > 0 then
        print("^3[NBL-Target]^7 Removed " .. count .. " entries from: " .. resourceName)
    end
    
    return count
end

function Registry:CleanupInvalidEntities()
    local removed = 0
    
    for _, storage in ipairs({ self.entities, self.localEntities }) do
        for id, entry in pairs(storage) do
            if entry.entity then
                if GetEntityType(entry.entity) == 0 then
                    RemoveEntry(storage, id)
                    removed = removed + 1
                end
            end
        end
    end
    
    return removed
end

function Registry:GetEntityRegistrations(entity)
    local results = {}
    
    for _, storage in ipairs({ self.entities, self.localEntities }) do
        for _, entry in pairs(storage) do
            if entry.entity == entity and entry.enabled then
                results[#results + 1] = entry
            end
        end
    end
    
    return results
end

function Registry:GetModelRegistrations(entity)
    if not entity or entity == 0 then return {} end
    if GetEntityType(entity) == 0 then return {} end
    
    local entityModel = GetEntityModel(entity)
    if not entityModel or entityModel == 0 then return {} end
    
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
    local count = 0
    
    local entityRegs = self:GetEntityRegistrations(entity)
    for i = 1, #entityRegs do
        count = count + 1
        results[count] = entityRegs[i]
    end
    
    local modelRegs = self:GetModelRegistrations(entity)
    for i = 1, #modelRegs do
        count = count + 1
        results[count] = modelRegs[i]
    end
    
    local globalRegs = self:GetGlobalTypeRegistrations(entityType)
    for i = 1, #globalRegs do
        count = count + 1
        results[count] = globalRegs[i]
    end
    
    return results
end

local DebugEnabled = Config.Debug.enabled

function Registry:CanInteract(registration, entity, worldPos, bone, cachedDistance)
    if not registration.enabled then return false end
    
    local distance = cachedDistance or Entity:GetDistance(entity, worldPos)
    if distance > registration.distance then
        return false
    end
    
    local canInteractFn = registration.canInteract
    if canInteractFn then
        local success, result = pcall(canInteractFn, entity, distance, worldPos, registration.name, bone)
        
        if not success then
            if DebugEnabled then
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
    local regCount = #registrations
    
    if regCount == 0 then return false end
    
    local distance = Entity:GetDistance(entity, worldPos)
    
    for i = 1, regCount do
        if self:CanInteract(registrations[i], entity, worldPos, nil, distance) then
            return true
        end
    end
    
    return false
end

function Registry:GetSubItemId(parentId, itemName, itemIndex)
    local key = parentId .. "_" .. (itemName or ("idx_" .. itemIndex))
    
    if not self.subItemIdMap[key] then
        self.subItemIdMap[key] = GenerateSubItemId()
    end
    
    return self.subItemIdMap[key]
end

function Registry:EvaluateChecked(checkedValue)
    if checkedValue == nil then return false end
    
    local valueType = type(checkedValue)
    
    if valueType == "function" or valueType == "table" then
        local success, result = pcall(checkedValue)
        return success and result == true
    end
    
    return checkedValue == true
end

function Registry:ProcessSubItems(items, entity, worldPos, parentId, depth)
    if not items or #items == 0 then return nil end
    
    depth = depth or 1
    local MAX_DEPTH = 2
    local distance = Entity:GetDistance(entity, worldPos)
    local filtered = {}
    
    for idx, item in ipairs(items) do
        local canShow = true
        
        if item.canInteract then
            local success, result = pcall(item.canInteract, entity, distance, worldPos, item.name)
            canShow = success and result == true
        end
        
        if canShow and item.distance and distance > item.distance then
            canShow = false
        end
        
        if canShow then
            local subItemId = self:GetSubItemId(parentId, item.name, idx)
            local hasCheckbox = item.checkbox == true
            local hasItems = item.items and #item.items > 0
            
            if hasCheckbox and hasItems then
                hasItems = false
            end
            
            if depth >= MAX_DEPTH then
                hasItems = false
            end
            
            self.activeSubItems[subItemId] = {
                id = subItemId,
                parentId = parentId,
                label = item.label,
                icon = item.icon,
                name = item.name,
                distance = item.distance,
                canInteract = item.canInteract,
                onSelect = item.onSelect,
                onCheck = item.onCheck,
                checkbox = hasCheckbox,
                checkedFn = item.checked,
                export = item.export,
                event = item.event,
                serverEvent = item.serverEvent,
                command = item.command,
                shouldClose = item.shouldClose,
                originalItems = hasItems and item.items or nil
            }
            
            local nestedItems = hasItems and self:ProcessSubItems(item.items, entity, worldPos, subItemId, depth + 1) or nil
            
            filtered[#filtered + 1] = {
                id = subItemId,
                label = item.label,
                icon = item.icon,
                name = item.name,
                checkbox = hasCheckbox,
                checked = hasCheckbox and self:EvaluateChecked(item.checked) or false,
                items = nestedItems,
                shouldClose = item.shouldClose
            }
        end
    end
    
    return #filtered > 0 and filtered or nil
end

function Registry:GetAvailableOptions(entity, entityType, worldPos)
    local registrations = self:GetAllRegistrations(entity, entityType)
    local regCount = #registrations
    
    if regCount == 0 then return {} end
    
    local available = {}
    local distance = Entity:GetDistance(entity, worldPos)
    
    for i = 1, regCount do
        local reg = registrations[i]
        if self:CanInteract(reg, entity, worldPos, nil, distance) then
            local hasCheckbox = reg.checkbox == true
            
            local processedItems = nil
            if not hasCheckbox and reg.items then
                processedItems = self:ProcessSubItems(reg.items, entity, worldPos, reg.id, 1)
            end
            
            available[#available + 1] = {
                id = reg.id,
                label = reg.label,
                icon = reg.icon,
                name = reg.name,
                checkbox = hasCheckbox,
                checked = hasCheckbox and self:EvaluateChecked(reg.checked) or false,
                items = processedItems,
                shouldClose = reg.shouldClose
            }
        end
    end
    
    return available
end

function Registry:ExecuteAction(registration, entity, worldPos)
    if not registration then return end
    
    if registration.export then
        local dotIndex = registration.export:find("%.")
        if dotIndex then
            local resourceName = registration.export:sub(1, dotIndex - 1)
            local exportName = registration.export:sub(dotIndex + 1)
            
            if exports[resourceName] and exports[resourceName][exportName] then
                local success, err = pcall(exports[resourceName][exportName], entity, worldPos, registration)
                if not success and Config.Debug.enabled then
                    print("^1[NBL-Target]^7 Export error: " .. tostring(err))
                end
            end
        end
        return
    end
    
    if registration.event then
        TriggerEvent(registration.event, entity, worldPos, registration)
        return
    end
    
    if registration.serverEvent then
        TriggerServerEvent(registration.serverEvent, entity, worldPos, registration)
        return
    end
    
    if registration.command then
        ExecuteCommand(registration.command)
        return
    end
    
    if registration.onSelect then
        local success, err = pcall(registration.onSelect, entity, worldPos, registration)
        if not success and Config.Debug.enabled then
            print("^1[NBL-Target]^7 onSelect error: " .. tostring(err))
        end
    end
end

local function FindRegistration(optionId)
    return Registry.entities[optionId]
        or Registry.localEntities[optionId]
        or Registry.models[optionId]
        or Registry.globalTypes[optionId]
        or Registry.activeSubItems[optionId]
end

function Registry:OnSelect(optionId, entity, worldPos)
    local registration = FindRegistration(optionId)
    if registration then
        self:ExecuteAction(registration, entity, worldPos)
    end
end

function Registry:OnCheck(optionId, entity, worldPos, newState)
    local registration = FindRegistration(optionId)
    if not registration then return end
    
    if registration.onCheck then
        local success, err = pcall(registration.onCheck, newState, entity, worldPos, registration)
        if not success and Config.Debug.enabled then
            print("^1[NBL-Target]^7 onCheck error: " .. tostring(err))
        end
    elseif registration.event then
        TriggerEvent(registration.event, newState, entity, worldPos, registration)
    elseif registration.serverEvent then
        TriggerServerEvent(registration.serverEvent, newState, entity, worldPos, registration)
    end
end

function Registry:ClearActiveSubItems()
    self.activeSubItems = {}
    self.subItemIdMap = {}
    self.subItemNextId = 10000
end

function Registry:GetById(id)
    return self.entities[id]
        or self.localEntities[id]
        or self.models[id]
        or self.globalTypes[id]
end

function Registry:GetRegisteredModels()
    local models = {}
    local seen = {}
    
    for _, entry in pairs(self.models) do
        if entry.model and not seen[entry.model] then
            seen[entry.model] = true
            models[#models + 1] = entry.model
        end
    end
    
    return models
end

function Registry:RemoveById(id)
    local entry = self:GetById(id)
    if not entry then return false end
    
    local storage = GetStorageByType(entry.registryType)
    return storage and RemoveEntry(storage, id) or false
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
