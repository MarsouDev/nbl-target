local State = {
    active = false,
    lastHover = nil,
    cursorPos = vector2(0.5, 0.5),
    lastClickTime = 0
}

local CLICK_COOLDOWN = 100

local function Activate()
    if State.active then return end
    
    State.active = true
    State.cursorPos = vector2(0.5, 0.5)
    SetCursorLocation(0.5, 0.5)
    
    Visual:SetActive(true)
    
    if Config.Debug.enabled then
        print("^2[NBL-Target]^7 Targeting mode activated")
    end
end

local function Deactivate()
    if not State.active then return end
    
    State.active = false
    Visual:SetActive(false)
    
    local entityToClean = nil
    if State.lastHover and State.lastHover.entity then
        entityToClean = State.lastHover.entity
    end
    
    NUI:Close()
    Visual:ClearAll()
    
    if entityToClean and entityToClean ~= 0 then
        SetEntityDrawOutline(entityToClean, false)
    end
    
    State.lastHover = nil
    SetMouseCursorSprite(0)
    
    if Config.Debug.enabled then
        print("^2[NBL-Target]^7 Targeting mode deactivated")
    end
end

local function DisableControls()
    for _, control in ipairs(Config.DisabledControls) do
        DisableControlAction(0, control, true)
    end
end

local function GetCursorPosition()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end

local function CanClick()
    local now = GetGameTimer()
    if now - State.lastClickTime < CLICK_COOLDOWN then
        return false
    end
    return true
end

local function RegisterClick()
    State.lastClickTime = GetGameTimer()
end

CreateThread(function()
    while true do
        if State.active then
            Wait(0)
            
            DisableControls()
            
            if NUI:IsOpen() then
                NUI:CheckDistance()
                Visual:DrawLockedEntity()
            else
                SetMouseCursorActiveThisFrame()
                State.cursorPos = GetCursorPosition()
                local hoverData = Visual:ProcessHover(State.cursorPos)
                State.lastHover = hoverData
                
                if hoverData and hoverData.entity then
                    SetMouseCursorSprite(5)
                else
                    SetMouseCursorSprite(0)
                end
            end
            
            if IsDisabledControlJustPressed(0, Config.Controls.selectKey) then
                if CanClick() then
                    RegisterClick()
                    
                    if not NUI:IsOpen() and State.lastHover and State.lastHover.hasOptions then
                        local options = Registry:GetAvailableOptions(
                            State.lastHover.entity,
                            State.lastHover.entityType,
                            State.lastHover.worldPos
                        )
                        
                        NUI:Open(
                            options,
                            State.cursorPos,
                            State.lastHover.entity,
                            State.lastHover.entityType,
                            State.lastHover.worldPos
                        )
                    end
                end
            end
            
            if IsDisabledControlJustPressed(0, 25) then
                if NUI:IsOpen() then
                    NUI:Close()
                end
            end
            
        else
            Wait(500)
        end
    end
end)

RegisterCommand('+nbl_target', function()
    Activate()
end, false)

RegisterCommand('-nbl_target', function()
    Deactivate()
end, false)

RegisterKeyMapping('+nbl_target', 'Open Target Menu', 'keyboard', Config.Controls.activationKey)

exports('isActive', function() return State.active end)
exports('isMenuOpen', function() return NUI:IsOpen() end)
exports('deactivate', function() Deactivate() end)

exports('enable', function() Registry:Enable() end)
exports('disable', function() Registry:Disable() end)
exports('isEnabled', function() return Registry:IsEnabled() end)

exports('getCurrentTarget', function()
    if NUI:IsOpen() then
        return {
            entity = NUI:GetCurrentEntity(),
            entityType = NUI:GetCurrentEntityType(),
            worldPos = NUI:GetCurrentWorldPos()
        }
    elseif State.lastHover then
        return {
            entity = State.lastHover.entity,
            entityType = State.lastHover.entityType,
            worldPos = State.lastHover.worldPos
        }
    end
    return nil
end)

exports('getSelectedEntity', function()
    if NUI:IsOpen() then
        return NUI:GetCurrentEntity()
    end
    return nil
end)

exports('closeMenu', function()
    NUI:Close()
end)

exports('addEntity', function(entity, options)
    return Registry:AddEntity(entity, options)
end)

exports('addLocalEntity', function(entity, options)
    return Registry:AddLocalEntity(entity, options)
end)

exports('addModel', function(model, options)
    return Registry:AddModel(model, options)
end)

exports('addGlobalVehicle', function(options)
    return Registry:AddGlobalVehicle(options)
end)

exports('addGlobalPed', function(options)
    return Registry:AddGlobalPed(options)
end)

exports('addGlobalPlayer', function(options)
    return Registry:AddGlobalPlayer(options)
end)

exports('addGlobalSelf', function(options)
    return Registry:AddGlobalSelf(options)
end)

exports('addGlobalObject', function(options)
    return Registry:AddGlobalObject(options)
end)

exports('addGlobalOption', function(entityType, options)
    return Registry:AddGlobalOption(entityType, options)
end)

exports('removeEntity', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeLocalEntity', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeModel', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeGlobalVehicle', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeGlobalPed', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeGlobalPlayer', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeGlobalObject', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeGlobalOption', function(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end)

exports('removeByName', function(name)
    return Registry:RemoveByName(name)
end)

exports('removeByResource', function(resourceName)
    return Registry:RemoveByResource(resourceName)
end)

exports('remove', function(idOrHandler)
    if type(idOrHandler) == "table" and idOrHandler.remove then
        return idOrHandler:remove()
    end
    return Registry:RemoveById(idOrHandler)
end)
