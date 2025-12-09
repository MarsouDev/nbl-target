local OutlineTracker = {}
local MarkerRotation = 0.0
local CurrentEntity = nil
local LockedEntity = nil
local IsActive = false

Visual = {}

function Visual:SetActive(active)
    IsActive = active
end

function Visual:IsEntityValid(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
end

function Visual:GetEntityType(entity)
    if not self:IsEntityValid(entity) then return "unknown" end
    
    if IsEntityAVehicle(entity) then
        return "vehicle"
    elseif IsEntityAPed(entity) then
        return "ped"
    elseif IsEntityAnObject(entity) then
        return "object"
    end
    
    return "unknown"
end

function Visual:CanUseOutline(entity)
    if not Config.Outline.enabled then return false end
    
    if entity == PlayerPedId() then
        return Config.Outline.allowedTypes["self"] == true
    end
    
    local entityType = self:GetEntityType(entity)
    return Config.Outline.allowedTypes[entityType] == true
end

function Visual:GetDistanceToEntity(entity)
    if not self:IsEntityValid(entity) then return math.huge end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    
    return #(playerCoords - entityCoords)
end

function Visual:AddOutline(entity)
    if not entity or entity == 0 then return end
    OutlineTracker[entity] = true
end

function Visual:RemoveOutline(entity)
    if not entity or entity == 0 then return end
    OutlineTracker[entity] = nil
    SetEntityDrawOutline(entity, false)
end

function Visual:DrawOutline(entity, color)
    if not Config.Outline.enabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseOutline(entity) then return end
    
    local c = color or Config.Outline.color
    SetEntityDrawOutlineColor(c.r, c.g, c.b, c.a)
    SetEntityDrawOutline(entity, true)
    self:AddOutline(entity)
end

function Visual:ClearOutline(entity)
    if not entity or entity == 0 then return end
    SetEntityDrawOutline(entity, false)
    OutlineTracker[entity] = nil
end

function Visual:ClearAllTracked()
    for entity, _ in pairs(OutlineTracker) do
        if entity and entity ~= 0 then
            SetEntityDrawOutline(entity, false)
        end
    end
    OutlineTracker = {}
    
    if CurrentEntity and CurrentEntity ~= 0 then
        SetEntityDrawOutline(CurrentEntity, false)
    end
    
    if LockedEntity and LockedEntity ~= 0 then
        SetEntityDrawOutline(LockedEntity, false)
    end
    
    CurrentEntity = nil
    LockedEntity = nil
end

function Visual:DrawMarker(entity, color)
    if not Config.Marker.enabled then return end
    if not self:IsEntityValid(entity) then return end
    
    local entityCoords = GetEntityCoords(entity)
    local c = color or Config.Marker.color
    local scale = Config.Marker.scale
    
    local markerZ = entityCoords.z + Config.Marker.height
    
    if Config.Marker.bob then
        markerZ = markerZ + (math.sin(GetGameTimer() / 200) * 0.05)
    end
    
    if Config.Marker.rotate then
        MarkerRotation = MarkerRotation + 1.0
        if MarkerRotation >= 360.0 then
            MarkerRotation = 0.0
        end
    end
    
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
                        SetEntityDrawOutline(entity, false)
                    end
                end
                OutlineTracker = {}
                
                if CurrentEntity and CurrentEntity ~= 0 then
                    SetEntityDrawOutline(CurrentEntity, false)
                    CurrentEntity = nil
                end
                
                if LockedEntity and LockedEntity ~= 0 then
                    SetEntityDrawOutline(LockedEntity, false)
                    LockedEntity = nil
                end
                
                lastCleanup = now
            end
        end
    end
end)
