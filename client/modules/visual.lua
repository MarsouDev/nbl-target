local OutlineTracker = {}
local MarkerRotation = 0.0
local CurrentEntity = nil
local LockedEntity = nil
local IsActive = false

Visual = {}

local function SafeSetOutline(entity, enabled)
    if not entity or entity == 0 then return false end
    local success = pcall(function()
        if DoesEntityExist(entity) then
            SetEntityDrawOutline(entity, enabled)
        end
    end)
    return success
end

local function SafeSetOutlineColor(r, g, b, a)
    pcall(function()
        SetEntityDrawOutlineColor(r, g, b, a)
    end)
end

local function SafeGetEntityCoords(entity)
    if not entity or entity == 0 then return nil end
    local success, coords = pcall(function()
        if DoesEntityExist(entity) then
            return GetEntityCoords(entity)
        end
        return nil
    end)
    if success and coords then
        return coords
    end
    return nil
end

local function GetEntityTopOffset(entity)
    if not entity or entity == 0 then return 1.0 end
    
    local success, topOffset = pcall(function()
        if not DoesEntityExist(entity) then return 1.0 end
        
        local model = GetEntityModel(entity)
        if not model or model == 0 then return 1.0 end
        
        local min, max = GetModelDimensions(model)
        if not min or not max then return 1.0 end
        
        return max.z > 0 and max.z or 1.0
    end)
    
    return success and topOffset or 1.0
end

function Visual:SetActive(active)
    IsActive = active
end

function Visual:IsEntityValid(entity)
    if not entity or entity == 0 then return false end
    local success, exists = pcall(DoesEntityExist, entity)
    return success and exists
end

function Visual:GetEntityType(entity)
    if not self:IsEntityValid(entity) then return "unknown" end
    
    local success, result = pcall(function()
        if IsEntityAVehicle(entity) then
            return "vehicle"
        elseif IsEntityAPed(entity) then
            return "ped"
        elseif IsEntityAnObject(entity) then
            return "object"
        end
        return "unknown"
    end)
    
    return success and result or "unknown"
end

function Visual:CanUseOutline(entity)
    if not Config.Outline.enabled then return false end
    if not self:IsEntityValid(entity) then return false end
    
    local playerPed = PlayerPedId()
    if entity == playerPed then
        return Config.Outline.allowedTypes["self"] == true
    end
    
    local entityType = self:GetEntityType(entity)
    return Config.Outline.allowedTypes[entityType] == true
end

function Visual:CanUseMarker(entity)
    if not Config.Marker.enabled then return false end
    if not self:IsEntityValid(entity) then return false end
    
    local playerPed = PlayerPedId()
    if entity == playerPed then
        return Config.Marker.allowedTypes and Config.Marker.allowedTypes["self"] == true
    end
    
    local entityType = self:GetEntityType(entity)
    if not Config.Marker.allowedTypes then return true end
    return Config.Marker.allowedTypes[entityType] == true
end

function Visual:GetDistanceToEntity(entity)
    if not self:IsEntityValid(entity) then return math.huge end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = SafeGetEntityCoords(entity)
    
    if not entityCoords then return math.huge end
    
    return #(playerCoords - entityCoords)
end

function Visual:AddOutline(entity)
    if not entity or entity == 0 then return end
    OutlineTracker[entity] = true
end

function Visual:RemoveOutline(entity)
    if not entity or entity == 0 then return end
    OutlineTracker[entity] = nil
    SafeSetOutline(entity, false)
end

function Visual:DrawOutline(entity, color)
    if not Config.Outline.enabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseOutline(entity) then return end
    
    local c = color or Config.Outline.color
    SafeSetOutlineColor(c.r, c.g, c.b, c.a)
    if SafeSetOutline(entity, true) then
        self:AddOutline(entity)
    end
end

function Visual:ClearOutline(entity)
    if not entity or entity == 0 then return end
    SafeSetOutline(entity, false)
    OutlineTracker[entity] = nil
end

function Visual:ClearAllTracked()
    for entity, _ in pairs(OutlineTracker) do
        if entity and entity ~= 0 then
            SafeSetOutline(entity, false)
        end
    end
    OutlineTracker = {}
    
    if CurrentEntity and CurrentEntity ~= 0 then
        SafeSetOutline(CurrentEntity, false)
    end
    
    if LockedEntity and LockedEntity ~= 0 then
        SafeSetOutline(LockedEntity, false)
    end
    
    CurrentEntity = nil
    LockedEntity = nil
end

function Visual:DrawMarker(entity, color)
    if not Config.Marker.enabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseMarker(entity) then return end
    
    local entityCoords = SafeGetEntityCoords(entity)
    if not entityCoords then return end
    
    local c = color or Config.Marker.color
    local scale = Config.Marker.scale
    
    local topOffset = GetEntityTopOffset(entity)
    local markerZ = entityCoords.z + topOffset + Config.Marker.height
    
    if Config.Marker.bob then
        markerZ = markerZ + (math.sin(GetGameTimer() / 200) * 0.05)
    end
    
    if Config.Marker.rotate then
        MarkerRotation = MarkerRotation + 1.0
        if MarkerRotation >= 360.0 then
            MarkerRotation = 0.0
        end
    end
    
    pcall(function()
        DrawMarker(
            Config.Marker.type,
            entityCoords.x, entityCoords.y, markerZ,
            0.0, 0.0, 0.0,
            0.0, 0.0, MarkerRotation,
            scale, scale, scale,
            c.r, c.g, c.b, c.a,
            Config.Marker.bob,
            true,
            2,
            Config.Marker.rotate,
            nil, nil,
            false
        )
    end)
end

function Visual:HighlightEntity(entity)
    if not self:IsEntityValid(entity) then return end
    
    local distance = self:GetDistanceToEntity(entity)
    if distance > Config.Target.maxDistance then return end
    
    if CurrentEntity and CurrentEntity ~= entity then
        self:ClearOutline(CurrentEntity)
    end
    
    CurrentEntity = entity
    self:DrawOutline(entity)
    self:DrawMarker(entity)
end

function Visual:LockEntity(entity)
    LockedEntity = entity
end

function Visual:UnlockEntity()
    if LockedEntity and LockedEntity ~= 0 then
        self:ClearOutline(LockedEntity)
    end
    LockedEntity = nil
end

function Visual:IsLocked()
    return LockedEntity ~= nil
end

function Visual:GetLockedEntity()
    return LockedEntity
end

function Visual:DrawLockedEntity()
    if not LockedEntity then return end
    if not self:IsEntityValid(LockedEntity) then
        self:UnlockEntity()
        return
    end
    
    self:DrawOutline(LockedEntity)
    self:DrawMarker(LockedEntity)
end

function Visual:ClearAll()
    self:ClearAllTracked()
    MarkerRotation = 0.0
end

function Visual:GetCurrentEntity()
    return CurrentEntity
end

function Visual:ProcessHover(cursorPos)
    if self:IsLocked() then
        self:DrawLockedEntity()
        return nil
    end
    
    local hit, worldPos, _, entity, _ = Raycast:FromScreen(cursorPos, Config.Target.maxDistance)
    
    if not hit or not self:IsEntityValid(entity) then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    local playerPed = PlayerPedId()
    if entity == playerPed and not Config.Target.allowSelfTarget then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    local entityType = Entity:GetType(entity)
    
    local distance = self:GetDistanceToEntity(entity)
    if distance > Config.Target.maxDistance then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    self:HighlightEntity(entity)
    
    local hasOptions = Registry:HasAvailableOptions(entity, entityType, worldPos)
    
    return {
        entity = entity,
        entityType = entityType,
        worldPos = worldPos,
        distance = distance,
        hasOptions = hasOptions
    }
end

CreateThread(function()
    local lastCleanup = 0
    
    while true do
        Wait(100)
        
        if not IsActive then
            local now = GetGameTimer()
            
            if now - lastCleanup > 200 then
                for entity, _ in pairs(OutlineTracker) do
                    if entity and entity ~= 0 then
                        SafeSetOutline(entity, false)
                    end
                end
                OutlineTracker = {}
                
                if CurrentEntity and CurrentEntity ~= 0 then
                    SafeSetOutline(CurrentEntity, false)
                    CurrentEntity = nil
                end
                
                if LockedEntity and LockedEntity ~= 0 then
                    SafeSetOutline(LockedEntity, false)
                    LockedEntity = nil
                end
                
                lastCleanup = now
            end
        end
    end
end)
