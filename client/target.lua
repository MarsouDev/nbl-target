TargetRegistry = {
    entities = {},
    globalTypes = {},
    models = {},
    localEntities = {},
    entitiesByName = {},
    nextId = 1,
    enabled = true
}

function TargetRegistry:GenerateId()
    local id = self.nextId
    self.nextId = self.nextId + 1
    return id
end

function TargetRegistry:DisableTargeting()
    self.enabled = false
end

function TargetRegistry:EnableTargeting()
    self.enabled = true
end

function TargetRegistry:IsTargetingEnabled()
    return self.enabled
end

local function CreateRegistryEntry(id, baseData, options)
    local entry = {
        id = id,
        options = options or {},
        label = options.label or "Interagir",
        name = options.name,
        icon = options.icon,
        distance = options.distance or Config.Registry.defaultDistance,
        canInteract = options.canInteract,
        onSelect = options.onSelect,
        export = options.export,
        event = options.event,
        serverEvent = options.serverEvent,
        command = options.command,
        enabled = options.enabled ~= false
    }
    
    for k, v in pairs(baseData) do
        entry[k] = v
    end
    
    if entry.name then
        TargetRegistry.entitiesByName[entry.name] = entry
    end
    
    return entry
end

function TargetRegistry:AddEntity(entity, options)
    if not entity or entity == 0 then
        print("^1[Target]^7 Invalid entity provided")
        return nil
    end
    
    local id = self:GenerateId()
    local entry = CreateRegistryEntry(id, {
        entity = entity,
        type = "entity"
    }, options)
    
    self.entities[id] = entry
    return id
end

function TargetRegistry:AddLocalEntity(entity, options)
    if not entity or entity == 0 then
        print("^1[Target]^7 Invalid entity provided")
        return nil
    end
    
    local id = self:GenerateId()
    local entry = CreateRegistryEntry(id, {
        entity = entity,
        type = "localEntity"
    }, options)
    
    self.localEntities[id] = entry
    return id
end

function TargetRegistry:AddGlobalType(entityType, options)
    local id = self:GenerateId()
    local entry = CreateRegistryEntry(id, {
        entityType = entityType,
        type = "global"
    }, options)
    
    self.globalTypes[id] = entry
    return id
end

function TargetRegistry:AddModel(model, options)
    if not model then
        print("^1[Target]^7 Invalid model provided")
        return nil
    end
    
    local id = self:GenerateId()
    local entry = CreateRegistryEntry(id, {
        model = model,
        type = "model"
    }, options)
    
    self.models[id] = entry
    return id
end

function TargetRegistry:AddGlobalOption(optionType, options)
    return self:AddGlobalType(optionType, options)
end

function TargetRegistry:AddGlobalObject(options)
    return self:AddGlobalType("object", options)
end

function TargetRegistry:AddGlobalPed(options)
    return self:AddGlobalType("ped", options)
end

function TargetRegistry:AddGlobalPlayer(options)
    return self:AddGlobalType("player", options)
end

function TargetRegistry:AddGlobalVehicle(options)
    return self:AddGlobalType("vehicle", options)
end

function TargetRegistry:RemoveEntity(id)
    if self.entities[id] then
        local entry = self.entities[id]
        if entry.name then
            self.entitiesByName[entry.name] = nil
        end
        self.entities[id] = nil
        return true
    end
    return false
end

function TargetRegistry:RemoveLocalEntity(id)
    if self.localEntities[id] then
        local entry = self.localEntities[id]
        if entry.name then
            self.entitiesByName[entry.name] = nil
        end
        self.localEntities[id] = nil
        return true
    end
    return false
end

function TargetRegistry:RemoveGlobalType(id)
    if self.globalTypes[id] then
        local entry = self.globalTypes[id]
        if entry.name then
            self.entitiesByName[entry.name] = nil
        end
        self.globalTypes[id] = nil
        return true
    end
    return false
end

function TargetRegistry:RemoveModel(id)
    if self.models[id] then
        local entry = self.models[id]
        if entry.name then
            self.entitiesByName[entry.name] = nil
        end
        self.models[id] = nil
        return true
    end
    return false
end

function TargetRegistry:RemoveByName(name)
    if self.entitiesByName[name] then
        local entry = self.entitiesByName[name]
        if entry.type == "entity" then
            self.entities[entry.id] = nil
        elseif entry.type == "localEntity" then
            self.localEntities[entry.id] = nil
        elseif entry.type == "global" then
            self.globalTypes[entry.id] = nil
        elseif entry.type == "model" then
            self.models[entry.id] = nil
        end
        self.entitiesByName[name] = nil
        return true
    end
    return false
end

function TargetRegistry:RemoveGlobalOption(id)
    return self:RemoveGlobalType(id)
end

function TargetRegistry:RemoveGlobalObject(name)
    return self:RemoveByName(name)
end

function TargetRegistry:RemoveGlobalPed(name)
    return self:RemoveByName(name)
end

function TargetRegistry:RemoveGlobalPlayer(name)
    return self:RemoveByName(name)
end

function TargetRegistry:RemoveGlobalVehicle(name)
    return self:RemoveByName(name)
end

function TargetRegistry:GetEntityRegistrations(entity)
    local registrations = {}
    
    for _, entry in pairs(self.entities) do
        if entry.entity == entity and entry.enabled then
            table.insert(registrations, entry)
        end
    end
    
    for _, entry in pairs(self.localEntities) do
        if entry.entity == entity and entry.enabled then
            table.insert(registrations, entry)
        end
    end
    
    return registrations
end

function TargetRegistry:GetModelRegistrations(entity)
    if not entity or entity == 0 then return {} end
    
    local entityModel = nil
    local success, err = pcall(function()
        entityModel = GetEntityModel(entity)
    end)
    
    if not success or not entityModel then
        return {}
    end
    
    local registrations = {}
    
    for _, entry in pairs(self.models) do
        if entry.model == entityModel and entry.enabled then
            table.insert(registrations, entry)
        end
    end
    
    return registrations
end

function TargetRegistry:GetGlobalTypeRegistrations(entityType)
    local registrations = {}
    
    for _, entry in pairs(self.globalTypes) do
        if entry.entityType == entityType and entry.enabled then
            table.insert(registrations, entry)
        end
    end
    
    return registrations
end

function TargetRegistry:GetAllRegistrations(entity, entityType)
    local allRegistrations = {}
    
    local entityRegs = self:GetEntityRegistrations(entity)
    for _, reg in ipairs(entityRegs) do
        table.insert(allRegistrations, reg)
    end
    
    local modelRegs = self:GetModelRegistrations(entity)
    for _, reg in ipairs(modelRegs) do
        table.insert(allRegistrations, reg)
    end
    
    local globalRegs = self:GetGlobalTypeRegistrations(entityType)
    for _, reg in ipairs(globalRegs) do
        table.insert(allRegistrations, reg)
    end
    
    return allRegistrations
end

function TargetRegistry:GetEntityDistance(entity, worldPosition)
    if not entity or entity == 0 then return 0 end
    
    local playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then return 0 end
    
    local playerCoords = nil
    local success, err = pcall(function()
        playerCoords = GetEntityCoords(playerPed)
        if not worldPosition then
            worldPosition = GetEntityCoords(entity)
        end
    end)
    
    if not success or not playerCoords or not worldPosition then return 0 end
    
    return #(playerCoords - worldPosition)
end

function TargetRegistry:CanInteract(registration, entity, worldPosition, bone)
    if not registration.enabled then return false end
    
    local distance = self:GetEntityDistance(entity, worldPosition)
    
    if distance > registration.distance then
        return false
    end
    
    if registration.canInteract then
        local name = registration.name or nil
        local success, result = pcall(registration.canInteract, entity, distance, worldPosition, name, bone)
        if success then
            return result == true
        else
            print("^1[Target]^7 Error in canInteract callback: " .. tostring(result))
            return false
        end
    end
    
    return true
end

function TargetRegistry:ExecuteAction(registration, entity, worldPosition)
    if registration.export then
        local dotIndex = string.find(registration.export, "%.")
        if dotIndex then
            local resourceName = string.sub(registration.export, 1, dotIndex - 1)
            local exportName = string.sub(registration.export, dotIndex + 1)
            
            if exports[resourceName] and exports[resourceName][exportName] then
                local success, err = pcall(function()
                    exports[resourceName][exportName](entity, worldPosition, registration)
                end)
                if not success then
                    print("^1[Target]^7 Error in export: " .. tostring(err))
                end
            end
        end
    elseif registration.event then
        TriggerEvent(registration.event, entity, worldPosition, registration)
    elseif registration.serverEvent then
        TriggerServerEvent(registration.serverEvent, entity, worldPosition, registration)
    elseif registration.command then
        ExecuteCommand(registration.command)
    elseif registration.onSelect then
        local success, err = pcall(registration.onSelect, entity, worldPosition, registration)
        if not success then
            print("^1[Target]^7 Error in onSelect callback: " .. tostring(err))
        end
    end
end

function TargetRegistry:OnSelect(registration, entity, worldPosition, bone)
    self:ExecuteAction(registration, entity, worldPosition)
end
