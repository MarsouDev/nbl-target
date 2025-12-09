Visual = {
    currentEntity = nil,
    markerRotation = 0.0
}

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

function Visual:DrawOutline(entity, color)
    if not self:CanUseOutline(entity) then return end
    if not self:IsEntityValid(entity) then return end
    
    local c = color or Config.Outline.color
    SetEntityDrawOutlineColor(c.r, c.g, c.b, c.a)
    SetEntityDrawOutline(entity, true)
end

function Visual:ClearOutline(entity)
    if not self:IsEntityValid(entity) then return end
    if not self:CanUseOutline(entity) then return end
    
    SetEntityDrawOutline(entity, false)
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
        self.markerRotation = self.markerRotation + 1.0
        if self.markerRotation >= 360.0 then
            self.markerRotation = 0.0
        end
    end
    
    DrawMarker(
        Config.Marker.type,
        entityCoords.x, entityCoords.y, markerZ,
        0.0, 0.0, 0.0,
        0.0, 0.0, self.markerRotation,
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
    
    if self.currentEntity ~= entity then
        self:ClearOutline(self.currentEntity)
        self.currentEntity = entity
    end
    
    self:DrawOutline(entity)
    self:DrawMarker(entity)
end

function Visual:ClearAll()
    if self.currentEntity then
        self:ClearOutline(self.currentEntity)
        self.currentEntity = nil
    end
    self.markerRotation = 0.0
end

function Visual:ProcessHover(cursorPos)
    local hit, worldPos, _, entity, _ = Raycast:FromScreen(cursorPos, Config.Target.maxDistance)
    
    if not hit or not self:IsEntityValid(entity) then
        self:ClearAll()
        return nil
    end
    
    local playerPed = PlayerPedId()
    if entity == playerPed and not Config.Target.allowSelfTarget then
        self:ClearAll()
        return nil
    end
    
    local entityType = Entity:GetType(entity)
    
    local distance = self:GetDistanceToEntity(entity)
    if distance > Config.Target.maxDistance then
        self:ClearAll()
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
