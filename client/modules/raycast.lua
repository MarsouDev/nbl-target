Raycast = {}

local CameraCache = {
    lastUpdate = 0,
    position = vector3(0, 0, 0),
    rotation = vector3(0, 0, 0),
    fov = 0,
    camRight = nil,
    camForward = nil,
    camUp = nil,
    camPos = nil,
    matrixValid = false
}

local ScreenResolution = { x = 1920, y = 1080, lastUpdate = 0 }
local MapObjectHashes = nil
local MapObjectCache = {}
local MapObjectCacheTime = 0
local MapObjectCachePos = vector3(0, 0, 0)

local function UpdateCameraCache()
    local now = GetGameTimer()
    if now - CameraCache.lastUpdate < 16 and CameraCache.matrixValid then return end
    
    CameraCache.position = GetGameplayCamCoord()
    CameraCache.rotation = GetGameplayCamRot(0)
    CameraCache.fov = GetGameplayCamFov()
    
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 
        CameraCache.position.x, CameraCache.position.y, CameraCache.position.z,
        CameraCache.rotation.x, CameraCache.rotation.y, CameraCache.rotation.z,
        CameraCache.fov, 0, 2)
    
    if cam and cam ~= 0 then
        local camRight, camForward, camUp, camPos = GetCamMatrix(cam)
        if camForward then
            CameraCache.camRight = camRight
            CameraCache.camForward = camForward
            CameraCache.camUp = camUp
            CameraCache.camPos = camPos
            CameraCache.matrixValid = true
        else
            CameraCache.matrixValid = false
        end
        DestroyCam(cam, true)
    else
        CameraCache.matrixValid = false
    end
    
    CameraCache.lastUpdate = now
end

local function UpdateScreenResolution()
    local now = GetGameTimer()
    if now - ScreenResolution.lastUpdate < 1000 then return end
    
    ScreenResolution.x, ScreenResolution.y = GetActiveScreenResolution()
    ScreenResolution.lastUpdate = now
end

local function CalculateRayDirection(screenPos, camPos, camRight, camForward, camUp, fov)
    local normalizedScreen = vector2((screenPos.x - 0.5) * 2.0, (screenPos.y - 0.5) * 2.0)
    local fovRadians = (fov * math.pi) / 180.0
    local aspectRatio = ScreenResolution.x / ScreenResolution.y
    local fovMultiplier = fovRadians * 0.534375
    
    return camPos + camForward 
        + (camRight * normalizedScreen.x * fovMultiplier * aspectRatio) 
        - (camUp * normalizedScreen.y * fovMultiplier)
end

local function IsEntityUsable(entity)
    return Entity:IsValid(entity)
end

local function GetMapObjectHashes()
    if MapObjectHashes then
        return MapObjectHashes
    end
    
    MapObjectHashes = {}
    
    if Config.MapObjectModels then
        for _, modelName in ipairs(Config.MapObjectModels) do
            local hash = type(modelName) == "string" and joaat(modelName) or modelName
            MapObjectHashes[#MapObjectHashes + 1] = hash
        end
    end
    
    return MapObjectHashes
end

local function FindNearbyMapObject(worldPos)
    if not worldPos then return 0 end
    
    local now = GetGameTimer()
    local cacheAge = now - MapObjectCacheTime
    local distToCache = #(worldPos - MapObjectCachePos)
    
    if cacheAge < 100 and distToCache < 1.0 and MapObjectCache.result then
        return MapObjectCache.result
    end
    
    local searchRadius = Config.MapObjectSearchRadius or 2.0
    local maxAcceptDist = Config.MapObjectMaxDistance or 1.2
    
    local registeredModels = Registry:GetRegisteredModels()
    local configModels = GetMapObjectHashes()
    
    local closestObj = 0
    local closestDist = maxAcceptDist
    
    local allModels = {}
    local seen = {}
    
    for _, modelHash in ipairs(registeredModels) do
        if not seen[modelHash] then
            seen[modelHash] = true
            allModels[#allModels + 1] = modelHash
        end
    end
    
    for _, modelHash in ipairs(configModels) do
        if not seen[modelHash] then
            seen[modelHash] = true
            allModels[#allModels + 1] = modelHash
        end
    end
    
    for _, modelHash in ipairs(allModels) do
        local obj = GetClosestObjectOfType(worldPos.x, worldPos.y, worldPos.z, searchRadius, modelHash, false, false, false)
        if obj and obj ~= 0 then
            local objCoords = GetEntityCoords(obj)
            local dist = #(worldPos - objCoords)
            if dist < closestDist then
                closestDist = dist
                closestObj = obj
            end
        end
    end
    
    MapObjectCache = {
        result = closestObj,
        pos = worldPos
    }
    MapObjectCachePos = worldPos
    MapObjectCacheTime = now
    
    return closestObj
end

local function PerformRaycast(startPos, endPos, flags, ignoreEntity)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
        startPos.x, startPos.y, startPos.z,
        endPos.x, endPos.y, endPos.z,
        flags,
        ignoreEntity or 0,
        0
    )
    
    if not rayHandle then
        return false, nil, nil, 0, 0
    end
    
    local _, hit, worldPos, normal, material, entity = GetShapeTestResultIncludingMaterial(rayHandle)
    
    if hit == 1 then
        return true, worldPos, normal, entity or 0, material or 0
    end
    
    return false, worldPos, normal, 0, material or 0
end

function Raycast:FromScreen(screenPos, maxDistance, flags, ignoreEntity)
    UpdateCameraCache()
    UpdateScreenResolution()
    
    if not CameraCache.matrixValid then
        return false, vector3(0, 0, 0), vector3(0, 0, 0), 0, 0
    end
    
    local camPos = CameraCache.camPos
    local camRight = CameraCache.camRight
    local camForward = CameraCache.camForward
    local camUp = CameraCache.camUp
    local fov = CameraCache.fov
    
    local target = CalculateRayDirection(screenPos, camPos, camRight, camForward, camUp, fov)
    local direction = (target - camPos) * maxDistance
    local endPoint = camPos + direction
    
    local rayFlags = flags or Config.Target.raycastFlags
    local hit, worldPos, normal, entity, material = PerformRaycast(camPos, endPoint, rayFlags, ignoreEntity)
    
    if hit then
        if IsEntityUsable(entity) then
            return true, worldPos, normal, entity, material
        end
        
        local nearbyObj = FindNearbyMapObject(worldPos)
        if nearbyObj ~= 0 then
            return true, worldPos, normal, nearbyObj, material
        end
        
        return true, worldPos, normal, 0, material
    end
    
    return false, worldPos or vector3(0, 0, 0), normal or vector3(0, 0, 0), 0, material or 0
end

function Raycast:GetCursorPosition()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end

function Raycast:ScreenToWorld(screenPos, distance)
    UpdateCameraCache()
    
    if not CameraCache.matrixValid then
        return CameraCache.position
    end
    
    return CameraCache.camPos + (CameraCache.camForward * distance)
end

function Raycast:ReloadMapObjectHashes()
    MapObjectHashes = nil
    MapObjectCache = {}
    MapObjectCacheTime = 0
end
