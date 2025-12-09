Entity = {}

function Entity:GetType(entity, worldPos)
    local playerPed = PlayerPedId()
    
    if not entity or entity == 0 then
        if worldPos then
            local success, groundZ = pcall(GetHeightmapBottomZForPosition, worldPos.x, worldPos.y)
            if success and worldPos.z - groundZ < 2.0 then
                return "ground"
            end
        end
        return "sky"
    end
    
    local success, exists = pcall(DoesEntityExist, entity)
    if not success or not exists then
        return "unknown"
    end
    
    if entity == playerPed then
        return "self"
    end
    
    local isVehicle, isPed, isObject = false, false, false
    
    pcall(function()
        isVehicle = IsEntityAVehicle(entity)
        isPed = IsEntityAPed(entity)
        isObject = IsEntityAnObject(entity)
    end)
    
    if isVehicle then
        return "vehicle"
    end
    
    if isPed then
        local isPlayer = false
        pcall(function()
            isPlayer = IsPedAPlayer(entity)
        end)
        if isPlayer then
            return "player"
        end
        return "ped"
    end
    
    if isObject then
        return "object"
    end
    
    return "unknown"
end

function Entity:IsValid(entity)
    if not entity or entity == 0 then return false end
    local success, exists = pcall(DoesEntityExist, entity)
    return success and exists
end

function Entity:GetModel(entity)
    if not self:IsValid(entity) then return 0 end
    local success, model = pcall(GetEntityModel, entity)
    return success and model or 0
end

function Entity:GetCoords(entity)
    if not self:IsValid(entity) then return vector3(0, 0, 0) end
    local success, coords = pcall(GetEntityCoords, entity)
    return success and coords or vector3(0, 0, 0)
end

function Entity:GetDistance(entity, worldPos)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    local targetCoords = worldPos
    if not targetCoords then
        if not self:IsValid(entity) then return math.huge end
        local success, coords = pcall(GetEntityCoords, entity)
        if not success or not coords then return math.huge end
        targetCoords = coords
    end
    
    return #(playerCoords - targetCoords)
end

function Entity:GetVehicleInfo(entity)
    if not self:IsValid(entity) then
        return {name = "Unknown", model = 0, class = 0}
    end
    
    local isVehicle = false
    pcall(function()
        isVehicle = IsEntityAVehicle(entity)
    end)
    
    if not isVehicle then
        return {name = "Unknown", model = 0, class = 0}
    end
    
    local info = {name = "Unknown", model = 0, class = 0, plate = ""}
    
    pcall(function()
        local model = GetEntityModel(entity)
        info.model = model
        info.name = GetDisplayNameFromVehicleModel(model) or "Unknown"
        info.class = GetVehicleClass(entity) or 0
        info.plate = GetVehicleNumberPlateText(entity) or ""
    end)
    
    return info
end

function Entity:GetPedInfo(entity)
    if not self:IsValid(entity) then
        return {isPlayer = false, isDead = false}
    end
    
    local isPed = false
    pcall(function()
        isPed = IsEntityAPed(entity)
    end)
    
    if not isPed then
        return {isPlayer = false, isDead = false}
    end
    
    local info = {isPlayer = false, isDead = false, model = 0}
    
    pcall(function()
        info.isPlayer = IsPedAPlayer(entity)
        info.isDead = IsEntityDead(entity)
        info.model = GetEntityModel(entity)
    end)
    
    return info
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
