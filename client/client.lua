TargetRegistry = TargetRegistry or {
    enabled = true,
    IsTargetingEnabled = function() return true end,
    GetAllRegistrations = function() return {} end,
    GetGlobalTypeRegistrations = function() return {} end,
    CanInteract = function() return false end,
    OnSelect = function() end
}

local Raycast = {}

function Raycast:TargetCoords(screenPosition, maxDistance, flags, ignoreEntity)
    local pos = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(0)
    local fov = GetGameplayCamFov()
    
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, fov, 0, 2)
    if not cam or cam == 0 then return false, vector3(0, 0, 0), vector3(0, 0, 0), nil, nil end
    
    local camRight, camForward, camUp, camPos = GetCamMatrix(cam)
    DestroyCam(cam, true)

    screenPosition = vector2(screenPosition.x - 0.5, screenPosition.y - 0.5) * 2.0
    local fovRadians = (fov * 3.14) / 180.0
    local resX, resY = GetActiveScreenResolution()
    local to = camPos + camForward + (camRight * screenPosition.x * fovRadians * (resX / resY) * 0.534375) - (camUp * screenPosition.y * fovRadians * 0.534375)
    local direction = (to - camPos) * maxDistance
    local endPoint = camPos + direction

    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(camPos.x, camPos.y, camPos.z, endPoint.x, endPoint.y, endPoint.z, flags or Config.Target.raycastFlags, ignoreEntity or 0, 0)
    if not rayHandle then return false, vector3(0, 0, 0), vector3(0, 0, 0), nil, nil end
    
    local retval, hit, worldPosition, normalDirection, materialHash, entity = GetShapeTestResultIncludingMaterial(rayHandle)

    if hit == 1 and entity and entity ~= 0 then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local entityCoords = GetEntityCoords(entity)
        local distance = #(playerCoords - entityCoords)
        
        if distance >= (Config.Target.minDistance or 0.1) then
            return true, worldPosition, normalDirection, entity, materialHash
        end
    end
    
    return false, vector3(0, 0, 0), vector3(0, 0, 0), nil, materialHash
end

local VisualFeedback = {
    currentEntity = nil,
    previousEntity = nil
}

function VisualFeedback:IsEntityValid(entity)
    if not entity or entity == 0 then return false end
    if not DoesEntityExist(entity) then return false end
    return true
end

function VisualFeedback:GetEntityType(entity)
    if not self:IsEntityValid(entity) then return nil end
    
    if IsEntityAVehicle(entity) then
        return "vehicle"
    elseif IsEntityAPed(entity) then
        return "ped"
    elseif IsEntityAnObject(entity) then
        return "object"
    end
    return "unknown"
end

function VisualFeedback:CanUseOutline(entity)
    if not Config.VisualFeedback.useOutline then return false end
    
    local entityType = self:GetEntityType(entity)
    if not entityType then return false end
    
    return Config.VisualFeedback.outlineAllowedTypes[entityType] == true
end

function VisualFeedback:GetEntityDistance(entity)
    if not self:IsEntityValid(entity) then return math.huge end
    
    local playerPed = PlayerPedId()
    if not playerPed or playerPed == 0 then return math.huge end
    
    local playerCoords = nil
    local entityCoords = nil
    
    local success, err = pcall(function()
        playerCoords = GetEntityCoords(playerPed)
        entityCoords = GetEntityCoords(entity)
    end)
    
    if not success or not playerCoords or not entityCoords then
        return math.huge
    end
    
    return #(playerCoords - entityCoords)
end

function VisualFeedback:DrawOutline(entity, color)
    if not self:CanUseOutline(entity) then return end
    if not self:IsEntityValid(entity) then return end
    
    local success, err = pcall(function()
        SetEntityDrawOutlineColor(color.r, color.g, color.b, color.a)
        SetEntityDrawOutline(entity, true)
    end)
    
    if not success then
        print("^1[ERROR]^7 Failed to draw outline on entity: " .. tostring(err))
    end
end

function VisualFeedback:DrawMarker(entity, color)
    if not Config.VisualFeedback.useMarker then return end
    if not self:IsEntityValid(entity) then return end
    
    local entityCoords = nil
    local success, err = pcall(function()
        entityCoords = GetEntityCoords(entity)
    end)
    
    if not success or not entityCoords then return end
    
    local markerCoords = vector3(entityCoords.x, entityCoords.y, entityCoords.z + Config.VisualFeedback.markerHeight)
    
    local drawSuccess, drawErr = pcall(function()
        DrawMarker(
            Config.VisualFeedback.markerType,
            markerCoords.x, markerCoords.y, markerCoords.z,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            Config.VisualFeedback.markerScale,
            Config.VisualFeedback.markerScale,
            Config.VisualFeedback.markerScale,
            color.r, color.g, color.b, color.a,
            false, true, 2, false, nil, nil, false
        )
    end)
    
    if not drawSuccess then
        print("^1[ERROR]^7 Failed to draw marker: " .. tostring(drawErr))
    end
end

function VisualFeedback:ClearPreviousEntity()
    if self.previousEntity and self:IsEntityValid(self.previousEntity) then
        if self:CanUseOutline(self.previousEntity) then
            local success, err = pcall(function()
                SetEntityDrawOutline(self.previousEntity, false)
            end)
            if not success then
                print("^1[ERROR]^7 Failed to clear outline: " .. tostring(err))
            end
        end
    end
    self.previousEntity = nil
end

function VisualFeedback:HighlightEntity(entity)
    if not self:IsEntityValid(entity) then return end
    
    local distance = self:GetEntityDistance(entity)
    if distance > Config.VisualFeedback.maxDistance then return end
    
    if self.currentEntity ~= entity then
        self:ClearPreviousEntity()
        self.previousEntity = self.currentEntity
        self.currentEntity = entity
    end
    
    if self:CanUseOutline(entity) then
        self:DrawOutline(entity, Config.VisualFeedback.outlineColor)
    end
    
    if Config.VisualFeedback.useMarker then
        self:DrawMarker(entity, Config.VisualFeedback.markerColor)
    end
end

function VisualFeedback:ClearHighlight()
    if self.currentEntity and self:IsEntityValid(self.currentEntity) then
        if self:CanUseOutline(self.currentEntity) then
            local success, err = pcall(function()
                SetEntityDrawOutline(self.currentEntity, false)
            end)
            if not success then
                print("^1[ERROR]^7 Failed to clear outline: " .. tostring(err))
            end
        end
    end
    self:ClearPreviousEntity()
    self.currentEntity = nil
end

function VisualFeedback:ProcessHover(cursorPos)
    if not Config.VisualFeedback.enabled then return end
    if not TargetRegistry or not TargetRegistry:IsTargetingEnabled() then return end
    
    local hitSomething, worldPosition, normalDirection, hitEntityHandle = Raycast:TargetCoords(cursorPos, Config.VisualFeedback.maxDistance)
    
    local hasTargetableEntity = false
    
    if hitSomething and hitEntityHandle ~= 0 and self:IsEntityValid(hitEntityHandle) then
        local playerPed = PlayerPedId()
        local entityType = nil
        
        if hitEntityHandle == playerPed then
            entityType = "self"
        elseif IsEntityAVehicle(hitEntityHandle) then
            entityType = "vehicle"
        elseif IsEntityAPed(hitEntityHandle) then
            if IsPedAPlayer(hitEntityHandle) then
                entityType = "player"
            else
                entityType = "ped"
            end
        elseif IsEntityAnObject(hitEntityHandle) then
            entityType = "object"
        end
        
        if entityType == "self" and not Config.Registry.allowSelfTargeting then
            self:ClearHighlight()
            SetMouseCursorSprite(Config.Cursor.normal)
            return
        end
        
        local distance = self:GetEntityDistance(hitEntityHandle)
        if distance <= Config.VisualFeedback.maxDistance then
            if TargetRegistry then
                local registrations = TargetRegistry:GetAllRegistrations(hitEntityHandle, entityType)
                
                for _, registration in ipairs(registrations) do
                    if TargetRegistry:CanInteract(registration, hitEntityHandle, worldPosition, nil) then
                        hasTargetableEntity = true
                        break
                    end
                end
            end
            
            if hasTargetableEntity then
                SetMouseCursorSprite(Config.Cursor.targetable)
            else
                SetMouseCursorSprite(Config.Cursor.notTargetable)
            end
            
            self:HighlightEntity(hitEntityHandle)
            return
        end
    end
    
    SetMouseCursorSprite(Config.Cursor.normal)
    self:ClearHighlight()
end

local MouseSystem = {
    active = false,
    resolution = vector2(0, 0)
}

function MouseSystem:Activate()
    SetCursorLocation(0.5, 0.5)
    local resX, resY = GetActiveScreenResolution()
    self.resolution = vector2(resX, resY)
    self.active = true
end

function MouseSystem:Deactivate()
    self.active = false
    SetMouseCursorSprite(Config.Cursor.normal)
    if VisualFeedback then
        VisualFeedback:ClearHighlight()
        VisualFeedback:ClearPreviousEntity()
    end
end

function MouseSystem:IsActive()
    return self.active
end

function MouseSystem:DisableControls()
    for _, control in ipairs(Config.DisableControls) do
        DisableControlAction(0, control, true)
    end
end

function MouseSystem:GetCursorPosition()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end


local EntityDetector = {}

function EntityDetector:GetEntityType(entity, worldPosition)
    local playerPed = PlayerPedId()
    
    if not entity or entity == 0 then
        if worldPosition then
            local playerCoords = GetEntityCoords(playerPed)
            local groundZ = GetHeightmapBottomZForPosition(worldPosition.x, worldPosition.y)
            local distanceFromGround = worldPosition.z - groundZ
            
            if distanceFromGround < 2.0 then
                return "ground"
            else
                return "sky"
            end
        end
        return "sky"
    end
    
    if not VisualFeedback:IsEntityValid(entity) then
        return "unknown"
    end
    
    if playerPed == entity then
        return "self"
    elseif IsEntityAVehicle(entity) then
        return "vehicle"
    elseif IsEntityAPed(entity) then
        if IsPedAPlayer(entity) then
            return "player"
        else
            return "ped"
        end
    elseif IsEntityAnObject(entity) then
        return "object"
    end
    
    return "unknown"
end

function EntityDetector:CanTargetEntity(entity, entityType)
    if not Config.Registry.allowSelfTargeting and entityType == "self" then
        return false
    end
    
    if not TargetRegistry or not TargetRegistry:IsTargetingEnabled() then
        return false
    end
    
    return true
end

function EntityDetector:GetEntityTypeString(entityType)
    local types = {
        self = "Moi",
        vehicle = "Véhicule",
        player = "Joueur",
        ped = "Ped",
        object = "Objet",
        ground = "Sol",
        sky = "Ciel",
        unknown = "Inconnu"
    }
    return types[entityType] or "Inconnu"
end

function EntityDetector:GetVehicleInfo(entity)
    local model = nil
    local vehicleName = "Unknown"
    local vehicleClass = 0
    
    local success, result = pcall(function()
        model = GetEntityModel(entity)
        if model then
            vehicleName = GetDisplayNameFromVehicleModel(model) or "Unknown"
            vehicleClass = GetVehicleClass(entity) or 0
        end
    end)
    
    if not success or not model then
        return {
            name = "Unknown",
            model = 0,
            class = 0
        }
    end
    
    return {
        name = vehicleName,
        model = model,
        class = vehicleClass
    }
end

function EntityDetector:GetPedInfo(entity)
    local isPlayer = IsPedAPlayer(entity)
    return {
        isPlayer = isPlayer,
        type = isPlayer and "Joueur" or "PNJ"
    }
end

function EntityDetector:PrintEntityInfo(entity, worldPosition, normalDirection, materialHash, entityType)
    if not VisualFeedback:IsEntityValid(entity) then return end
    
    local entityTypeString = self:GetEntityTypeString(entityType)
    local entityModel = 0
    local entityCoords = vector3(0, 0, 0)
    
    local success, err = pcall(function()
        entityModel = GetEntityModel(entity) or 0
        entityCoords = GetEntityCoords(entity) or vector3(0, 0, 0)
    end)
    
    if not success then
        print("^1[ERROR]^7 Failed to get entity info: " .. tostring(err))
        return
    end

    if entityType == "vehicle" then
        local vehicleInfo = self:GetVehicleInfo(entity)
        print(string.format("^2[CLIC]^7 Type: %s | Model: %s (%s) | Hash: %s | Position: %s | Classe: %s",
            entityTypeString, vehicleInfo.name, vehicleInfo.model, entity, entityCoords, vehicleInfo.class))
    elseif entityType == "ped" or entityType == "player" then
        local pedInfo = self:GetPedInfo(entity)
        print(string.format("^2[CLIC]^7 Type: %s (%s) | Model: %s | Hash: %s | Position: %s",
            entityTypeString, pedInfo.type, entityModel, entity, entityCoords))
    else
        print(string.format("^2[CLIC]^7 Type: %s | Model: %s | Hash: %s | Position: %s",
            entityTypeString, entityModel, entity, entityCoords))
    end

    print(string.format("^3[RAYCAST]^7 Position monde: %s | Normal: %s | Material Hash: %s",
        worldPosition, normalDirection, materialHash or "N/A"))
end

function EntityDetector:PrintEmptyClick(worldPosition, entityType)
    local entityTypeString = self:GetEntityTypeString(entityType or "unknown")
    print(string.format("^1[CLIC]^7 Type: %s | Position monde: %s", entityTypeString, worldPosition))
end

function EntityDetector:HandleClick(cursorPos)
    if not TargetRegistry or not TargetRegistry:IsTargetingEnabled() then return end
    
    local hitSomething, worldPosition, normalDirection, hitEntityHandle, materialHash = Raycast:TargetCoords(cursorPos, Config.Target.maxDistance)
    
    local entityType = self:GetEntityType(hitEntityHandle, worldPosition)
    
    if not self:CanTargetEntity(hitEntityHandle, entityType) then
        return
    end
    
    if hitSomething and hitEntityHandle ~= 0 and VisualFeedback:IsEntityValid(hitEntityHandle) then
        local registrations = TargetRegistry:GetAllRegistrations(hitEntityHandle, entityType)
        
        if #registrations > 0 then
            for _, registration in ipairs(registrations) do
                if TargetRegistry:CanInteract(registration, hitEntityHandle, worldPosition, nil) then
                    TargetRegistry:OnSelect(registration, hitEntityHandle, worldPosition, nil)
                    return
                end
            end
        end
        
        self:PrintEntityInfo(hitEntityHandle, worldPosition, normalDirection, materialHash, entityType)
    elseif entityType == "ground" or entityType == "sky" then
        local registrations = TargetRegistry:GetGlobalTypeRegistrations(entityType)
        
        if #registrations > 0 then
            for _, registration in ipairs(registrations) do
                if TargetRegistry:CanInteract(registration, nil, worldPosition, nil) then
                    TargetRegistry:OnSelect(registration, nil, worldPosition, nil)
                    return
                end
            end
        end
        
        self:PrintEmptyClick(worldPosition, entityType)
    else
        self:PrintEmptyClick(worldPosition, entityType)
    end
end

RegisterCommand('+interaction', function()
    MouseSystem:Activate()
end)

RegisterCommand('-interaction', function()
    MouseSystem:Deactivate()
end)

RegisterKeyMapping('+interaction', 'Interaction Menu', 'keyboard', Config.Controls.activationKey)

CreateThread(function()
    while true do
        if MouseSystem:IsActive() then
            Wait(0)
            
            SetMouseCursorActiveThisFrame()
            MouseSystem:DisableControls()

            local cursorPos = MouseSystem:GetCursorPosition()

            VisualFeedback:ProcessHover(cursorPos)

            if IsDisabledControlJustPressed(0, Config.Controls.clickKey) then
                EntityDetector:HandleClick(cursorPos)
            end
        else
            Wait(500)
            SetMouseCursorSprite(Config.Cursor.normal)
        end
    end
end)

exports('disableTargeting', function()
    TargetRegistry:DisableTargeting()
end)

exports('addGlobalOption', function(optionType, options)
    return TargetRegistry:AddGlobalOption(optionType, options)
end)

exports('removeGlobalOption', function(id)
    return TargetRegistry:RemoveGlobalOption(id)
end)

exports('addGlobalObject', function(options)
    return TargetRegistry:AddGlobalObject(options)
end)

exports('removeGlobalObject', function(id)
    return TargetRegistry:RemoveGlobalObject(id)
end)

exports('addGlobalPed', function(options)
    return TargetRegistry:AddGlobalPed(options)
end)

exports('removeGlobalPed', function(id)
    return TargetRegistry:RemoveGlobalPed(id)
end)

exports('addGlobalPlayer', function(options)
    return TargetRegistry:AddGlobalPlayer(options)
end)

exports('removeGlobalPlayer', function(id)
    return TargetRegistry:RemoveGlobalPlayer(id)
end)

exports('addGlobalVehicle', function(options)
    return TargetRegistry:AddGlobalVehicle(options)
end)

exports('removeGlobalVehicle', function(id)
    return TargetRegistry:RemoveGlobalVehicle(id)
end)

exports('addModel', function(model, options)
    return TargetRegistry:AddModel(model, options)
end)

exports('removeModel', function(id)
    return TargetRegistry:RemoveModel(id)
end)

exports('addEntity', function(entity, options)
    return TargetRegistry:AddEntity(entity, options)
end)

exports('removeEntity', function(id)
    return TargetRegistry:RemoveEntity(id)
end)

exports('addLocalEntity', function(entity, options)
    return TargetRegistry:AddLocalEntity(entity, options)
end)

exports('removeLocalEntity', function(id)
    return TargetRegistry:RemoveLocalEntity(id)
end)
