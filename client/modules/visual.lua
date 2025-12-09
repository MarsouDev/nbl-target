Visual = {}

local TrackedOutlines = {}
local MarkerRotation = 0.0
local CurrentEntity = nil
local LockedEntity = nil
local IsActive = false

local DimensionsCache = {}

local function SetOutline(entity, enabled)
    if not entity or entity == 0 then return false end
    if GetEntityType(entity) == 0 then return false end
    
    SetEntityDrawOutline(entity, enabled)
    return true
end

local function GetEntityTopOffset(entity)
    if not entity or entity == 0 then return 1.0 end
    if GetEntityType(entity) == 0 then return 1.0 end
    
    local model = GetEntityModel(entity)
    if not model or model == 0 then return 1.0 end
    
    if DimensionsCache[model] then
        return DimensionsCache[model]
    end
    
    local _, max = GetModelDimensions(model)
    local topOffset = (max and max.z > 0) and max.z or 1.0
    
    DimensionsCache[model] = topOffset
    return topOffset
end

function Visual:SetActive(active)
    IsActive = active
end

function Visual:IsEntityValid(entity)
    if not entity or entity == 0 then return false end
    return GetEntityType(entity) ~= 0
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
    if not self:IsEntityValid(entity) then return false end
    
    local playerPed = PlayerPedId()
    if entity == playerPed then
        return Config.Outline.allowedTypes.self == true
    end
    
    local entityType = self:GetEntityType(entity)
    return Config.Outline.allowedTypes[entityType] == true
end

function Visual:CanUseMarker(entity)
    if not Config.Marker.enabled then return false end
    if not self:IsEntityValid(entity) then return false end
    
    local allowedTypes = Config.Marker.allowedTypes
    if not allowedTypes then return true end
    
    local playerPed = PlayerPedId()
    if entity == playerPed then
        return allowedTypes.self == true
    end
    
    local entityType = self:GetEntityType(entity)
    return allowedTypes[entityType] == true
end

function Visual:GetDistanceToEntity(entity)
    if not self:IsEntityValid(entity) then return math.huge end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local entityCoords = GetEntityCoords(entity)
    
    return #(playerCoords - entityCoords)
end

function Visual:AddOutline(entity)
    if not entity or entity == 0 then return end
    TrackedOutlines[entity] = true
end

function Visual:RemoveOutline(entity)
    if not entity or entity == 0 then return end
    TrackedOutlines[entity] = nil
    SetOutline(entity, false)
end

function Visual:DrawOutline(entity, color)
    if not Config.Outline.enabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseOutline(entity) then return end
    
    local c = color or Config.Outline.color
    SetEntityDrawOutlineColor(c.r, c.g, c.b, c.a)
    
    if SetOutline(entity, true) then
        self:AddOutline(entity)
    end
end

function Visual:ClearOutline(entity)
    if not entity or entity == 0 then return end
    SetOutline(entity, false)
    TrackedOutlines[entity] = nil
end

function Visual:ClearAllTracked()
    for entity in pairs(TrackedOutlines) do
        SetOutline(entity, false)
    end
    TrackedOutlines = {}
    
    if CurrentEntity then
        SetOutline(CurrentEntity, false)
        CurrentEntity = nil
    end
    
    if LockedEntity then
        SetOutline(LockedEntity, false)
        LockedEntity = nil
    end
end

function Visual:DrawMarker(entity, color)
    if not Config.Marker.enabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseMarker(entity) then return end
    
    local entityCoords = GetEntityCoords(entity)
    local c = color or Config.Marker.color
    local scale = Config.Marker.scale
    local markerConfig = Config.Marker
    
    local topOffset = GetEntityTopOffset(entity)
    local markerZ = entityCoords.z + topOffset + markerConfig.height
    
    if markerConfig.bob then
        markerZ = markerZ + (math.sin(GetGameTimer() * 0.005) * 0.05)
    end
    
    if markerConfig.rotate then
        MarkerRotation = (MarkerRotation + 1.0) % 360.0
    end
    
    DrawMarker(
        markerConfig.type,
        entityCoords.x, entityCoords.y, markerZ,
        0.0, 0.0, 0.0,
        0.0, 0.0, MarkerRotation,
        scale, scale, scale,
        c.r, c.g, c.b, c.a,
        markerConfig.bob,
        true,
        2,
        markerConfig.rotate,
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
    if LockedEntity then
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
    
    local hit, worldPos, _, entity = Raycast:FromScreen(cursorPos, Config.Target.maxDistance)
    
    if not hit then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    if not self:IsEntityValid(entity) then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - worldPos)
        
        if distance <= Config.Target.maxDistance then
            local entityType = Entity:GetType(0, worldPos)
            local hasOptions = Registry:HasAvailableOptions(0, entityType, worldPos)
            
            if hasOptions then
                return {
                    entity = 0,
                    entityType = entityType,
                    worldPos = worldPos,
                    distance = distance,
                    hasOptions = true
                }
            end
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
    
    local distance = self:GetDistanceToEntity(entity)
    if distance > Config.Target.maxDistance then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    local entityType = Entity:GetType(entity)
    
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
    while true do
        if IsActive then
            Wait(500)
        else
            if next(TrackedOutlines) or CurrentEntity or LockedEntity then
                for entity in pairs(TrackedOutlines) do
                    SetOutline(entity, false)
                end
                TrackedOutlines = {}
                
                if CurrentEntity then
                    SetOutline(CurrentEntity, false)
                    CurrentEntity = nil
                end
                
                if LockedEntity then
                    SetOutline(LockedEntity, false)
                    LockedEntity = nil
                end
            end
            
            Wait(500)
        end
    end
end)
