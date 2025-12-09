Raycast = {}

local cameraCache = {
    lastUpdate = 0,
    position = vector3(0, 0, 0),
    rotation = vector3(0, 0, 0),
    fov = 0
}

local function UpdateCameraCache()
    local now = GetGameTimer()
    if now - cameraCache.lastUpdate > 16 then
        pcall(function()
            cameraCache.position = GetGameplayCamCoord()
            cameraCache.rotation = GetGameplayCamRot(0)
            cameraCache.fov = GetGameplayCamFov()
        end)
        cameraCache.lastUpdate = now
    end
end

function Raycast:FromScreen(screenPos, maxDistance, flags, ignoreEntity)
    UpdateCameraCache()
    
    local pos = cameraCache.position
    local rot = cameraCache.rotation
    local fov = cameraCache.fov
    
    local cam = nil
    local success = pcall(function()
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, fov, 0, 2)
    end)
    
    if not success or not cam or cam == 0 then
        return false, vector3(0, 0, 0), vector3(0, 0, 0), 0, 0
    end
    
    local camRight, camForward, camUp, camPos
    success = pcall(function()
        camRight, camForward, camUp, camPos = GetCamMatrix(cam)
    end)
    
    pcall(function()
        DestroyCam(cam, true)
    end)
    
    if not success or not camForward then
        return false, vector3(0, 0, 0), vector3(0, 0, 0), 0, 0
    end
    
    local normalizedScreen = vector2(screenPos.x - 0.5, screenPos.y - 0.5) * 2.0
    local fovRadians = (fov * math.pi) / 180.0
    
    local resX, resY = 1920, 1080
    pcall(function()
        resX, resY = GetActiveScreenResolution()
    end)
    local aspectRatio = resX / resY
    
    local target = camPos + camForward 
        + (camRight * normalizedScreen.x * fovRadians * aspectRatio * 0.534375) 
        - (camUp * normalizedScreen.y * fovRadians * 0.534375)
    
    local direction = (target - camPos) * maxDistance
    local endPoint = camPos + direction
    
    local rayHandle = nil
    success = pcall(function()
        rayHandle = StartExpensiveSynchronousShapeTestLosProbe(
            camPos.x, camPos.y, camPos.z,
            endPoint.x, endPoint.y, endPoint.z,
            flags or Config.Target.raycastFlags,
            ignoreEntity or 0,
            0
        )
    end)
    
    if not success or not rayHandle then
        return false, vector3(0, 0, 0), vector3(0, 0, 0), 0, 0
    end
    
    local _, hit, worldPos, normal, material, entity
    success = pcall(function()
        _, hit, worldPos, normal, material, entity = GetShapeTestResultIncludingMaterial(rayHandle)
    end)
    
    if not success then
        return false, vector3(0, 0, 0), vector3(0, 0, 0), 0, 0
    end
    
    if hit == 1 and entity and entity ~= 0 then
        return true, worldPos, normal, entity, material
    end
    
    return false, worldPos or vector3(0, 0, 0), normal or vector3(0, 0, 0), 0, material or 0
end

function Raycast:GetCursorPosition()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end

function Raycast:ScreenToWorld(screenPos, distance)
    UpdateCameraCache()
    
    local pos = cameraCache.position
    local rot = cameraCache.rotation
    local fov = cameraCache.fov
    
    local cam = nil
    pcall(function()
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, fov, 0, 2)
    end)
    
    if not cam or cam == 0 then return pos end
    
    local _, camForward, _, camPos
    pcall(function()
        _, camForward, _, camPos = GetCamMatrix(cam)
    end)
    
    pcall(function()
        DestroyCam(cam, true)
    end)
    
    if not camForward then return pos end
    
    return camPos + (camForward * distance)
end
