Entity = {}

function Entity:GetType(entity, worldPos)
    local playerPed = PlayerPedId()
    
    if not entity or entity == 0 then
        if worldPos then
            local groundZ = GetHeightmapBottomZForPosition(worldPos.x, worldPos.y)
            if worldPos.z - groundZ < 2.0 then
                return "ground"
            end
        end
        return "sky"
    end
    
    if not DoesEntityExist(entity) then
        return "unknown"
    end
    
    if entity == playerPed then
        return "self"
    end
    
    if IsEntityAVehicle(entity) then
        return "vehicle"
    end
    
    if IsEntityAPed(entity) then
        if IsPedAPlayer(entity) then
            return "player"
        end
        return "ped"
    end
    
    if IsEntityAnObject(entity) then
        return "object"
    end
    
    return "unknown"
end

function Entity:IsValid(entity)
    return entity and entity ~= 0 and DoesEntityExist(entity)
end

function Entity:GetModel(entity)
    if not self:IsValid(entity) then return 0 end
    return GetEntityModel(entity)
end

function Entity:GetCoords(entity)
    if not self:IsValid(entity) then return vector3(0, 0, 0) end
    return GetEntityCoords(entity)
end

function Entity:GetDistance(entity, worldPos)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local targetCoords = worldPos
    if not targetCoords then
        if not self:IsValid(entity) then return math.huge end
        targetCoords = GetEntityCoords(entity)
    end
    
    return #(playerCoords - targetCoords)
end

function Entity:GetVehicleInfo(entity)
    if not self:IsValid(entity) or not IsEntityAVehicle(entity) then
        return {name = "Unknown", model = 0, class = 0}
    end
    
    local model = GetEntityModel(entity)
    return {
        name = GetDisplayNameFromVehicleModel(model) or "Unknown",
        model = model,
        class = GetVehicleClass(entity) or 0,
        plate = GetVehicleNumberPlateText(entity) or ""
    }
end

function Entity:GetPedInfo(entity)
    if not self:IsValid(entity) or not IsEntityAPed(entity) then
        return {isPlayer = false, isDead = false}
    end
    
    return {
        isPlayer = IsPedAPlayer(entity),
        isDead = IsEntityDead(entity),
        model = GetEntityModel(entity)
    }
end

function Entity:CanTarget(entity, entityType)
    if entityType == "self" and not Config.Target.allowSelfTarget then
        return false
    end
    
    if not Registry:IsEnabled() then
        return false
    end
    
    return true
end
