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

local OutlineEnabled = Config.Outline.enabled
local OutlineAllowedTypes = Config.Outline.allowedTypes

function Visual:CanUseOutline(entity)
    if not OutlineEnabled then return false end
    if not self:IsEntityValid(entity) then return false end
    
    local playerPed = PlayerPedId()
    if entity == playerPed then
        return OutlineAllowedTypes.self == true
    end
    
    local entityType = self:GetEntityType(entity)
    return OutlineAllowedTypes[entityType] == true
end

local MarkerAllowedTypes = MarkerConfig.allowedTypes

function Visual:CanUseMarker(entity)
    if not MarkerEnabled then return false end
    if not self:IsEntityValid(entity) then return false end
    
    if not MarkerAllowedTypes then return true end
    
    local playerPed = PlayerPedId()
    if entity == playerPed then
        return MarkerAllowedTypes.self == true
    end
    
    local entityType = self:GetEntityType(entity)
    return MarkerAllowedTypes[entityType] == true
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

local OutlineColor = Config.Outline.color

function Visual:DrawOutline(entity, color)
    if not OutlineEnabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseOutline(entity) then return end
    
    local c = color or OutlineColor
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

local MarkerConfig = Config.Marker
local MarkerEnabled = MarkerConfig.enabled
local MarkerType = MarkerConfig.type
local MarkerColor = MarkerConfig.color
local MarkerScale = MarkerConfig.scale
local MarkerHeight = MarkerConfig.height
local MarkerBob = MarkerConfig.bob
local MarkerRotate = MarkerConfig.rotate

function Visual:DrawMarker(entity, color)
    if not MarkerEnabled then return end
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseMarker(entity) then return end
    
    local entityCoords = GetEntityCoords(entity)
    local c = color or MarkerColor
    
    local topOffset = GetEntityTopOffset(entity)
    local markerZ = entityCoords.z + topOffset + MarkerHeight
    
    if MarkerBob then
        markerZ = markerZ + (math.sin(GetGameTimer() * 0.005) * 0.05)
    end
    
    if MarkerRotate then
        MarkerRotation = (MarkerRotation + 1.0) % 360.0
    end
    
    DrawMarker(
        MarkerType,
        entityCoords.x, entityCoords.y, markerZ,
        0.0, 0.0, 0.0,
        0.0, 0.0, MarkerRotation,
        MarkerScale, MarkerScale, MarkerScale,
        c.r, c.g, c.b, c.a,
        MarkerBob,
        true,
        2,
        MarkerRotate,
        nil, nil,
        false
    )
end

local MaxDistance = Config.Target.maxDistance

function Visual:HighlightEntity(entity)
    if not self:IsEntityValid(entity) then return end
    
    local distance = self:GetDistanceToEntity(entity)
    if distance > MaxDistance then return end
    
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

local AllowSelfTarget = Config.Target.allowSelfTarget

function Visual:ProcessHover(cursorPos)
    if self:IsLocked() then
        self:DrawLockedEntity()
        return nil
    end
    
    local hit, worldPos, _, entity = Raycast:FromScreen(cursorPos, MaxDistance)
    
    if not hit then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    local isValidEntity = self:IsEntityValid(entity)
    
    if not isValidEntity then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - worldPos)
        
        if distance <= MaxDistance then
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
    if entity == playerPed and not AllowSelfTarget then
        if CurrentEntity then
            self:ClearOutline(CurrentEntity)
            CurrentEntity = nil
        end
        return nil
    end
    
    local distance = self:GetDistanceToEntity(entity)
    if distance > MaxDistance then
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
        Wait(500)
        
        if not IsActive then
            local hasOutlines = next(TrackedOutlines)
            
            if hasOutlines or CurrentEntity or LockedEntity then
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
        end
    end
end)
