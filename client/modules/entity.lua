Entity = {}

local ENTITY_TYPES = {
    SELF = "self",
    VEHICLE = "vehicle",
    PED = "ped",
    PLAYER = "player",
    OBJECT = "object",
    GROUND = "ground",
    SKY = "sky",
    UNKNOWN = "unknown"
}

function Entity:IsValid(entity)
    if not entity or entity == 0 then
        return false
    end
    local entityType = GetEntityType(entity)
    return entityType ~= 0
end

function Entity:GetType(entity, worldPos)
    if not entity or entity == 0 then
        if worldPos then
            local groundZ = GetHeightmapBottomZForPosition(worldPos.x, worldPos.y)
            local waterZ = GetWaterHeight(worldPos.x, worldPos.y, worldPos.z)
            
            local distToGround = math.abs(worldPos.z - groundZ)
            local distToWater = (type(waterZ) == "number" and waterZ > 0) and math.abs(worldPos.z - waterZ) or math.huge
            
            if distToGround < 5.0 or distToWater < 2.0 then
                return ENTITY_TYPES.GROUND
            end
        end
        return ENTITY_TYPES.SKY
    end
    
    if not self:IsValid(entity) then
        return ENTITY_TYPES.UNKNOWN
    end
    
    if entity == PlayerPedId() then
        return ENTITY_TYPES.SELF
    end
    
    local entityType = GetEntityType(entity)
    
    if entityType == 2 then
        return ENTITY_TYPES.VEHICLE
    end
    
    if entityType == 1 then
        local isPlayer = IsPedAPlayer(entity)
        return isPlayer and ENTITY_TYPES.PLAYER or ENTITY_TYPES.PED
    end
    
    if entityType == 3 then
        return ENTITY_TYPES.OBJECT
    end
    
    return ENTITY_TYPES.UNKNOWN
end

function Entity:GetModel(entity)
    if not self:IsValid(entity) then return 0 end
    return GetEntityModel(entity)
end

function Entity:GetCoords(entity)
    if not self:IsValid(entity) then return vector3(0, 0, 0) end
    return GetEntityCoords(entity)
end

local CachedPlayerCoords = vector3(0, 0, 0)
local CachedPlayerCoordsTime = 0

local function GetCachedPlayerCoords()
    local now = GetGameTimer()
    if now - CachedPlayerCoordsTime > 0 then
        CachedPlayerCoords = GetEntityCoords(PlayerPedId())
        CachedPlayerCoordsTime = now
    end
    return CachedPlayerCoords
end

function Entity:GetDistance(entity, worldPos)
    local playerCoords = GetCachedPlayerCoords()
    
    local targetCoords = worldPos
    if not targetCoords then
        if not self:IsValid(entity) then return math.huge end
        targetCoords = GetEntityCoords(entity)
    end
    
    return #(playerCoords - targetCoords)
end

function Entity:GetVehicleInfo(entity)
    local defaultInfo = { name = "Unknown", model = 0, class = 0, plate = "" }
    
    if not self:IsValid(entity) then return defaultInfo end
    if GetEntityType(entity) ~= 2 then return defaultInfo end
    
    local model = GetEntityModel(entity)
    if not model or model == 0 then return defaultInfo end
    
    return {
        model = model,
        name = GetDisplayNameFromVehicleModel(model) or "Unknown",
        class = GetVehicleClass(entity) or 0,
        plate = GetVehicleNumberPlateText(entity) or ""
    }
end

function Entity:GetPedInfo(entity)
    local defaultInfo = { isPlayer = false, isDead = false, model = 0 }
    
    if not self:IsValid(entity) then return defaultInfo end
    if GetEntityType(entity) ~= 1 then return defaultInfo end
    
    return {
        isPlayer = IsPedAPlayer(entity) or false,
        isDead = IsEntityDead(entity) or false,
        model = GetEntityModel(entity) or 0
    }
end

function Entity:CanTarget(entity, entityType)
    if not Registry:IsEnabled() then
        return false
    end
    
    if entityType == ENTITY_TYPES.SELF and not Config.Target.allowSelfTarget then
        return false
    end
    
    return true
end
