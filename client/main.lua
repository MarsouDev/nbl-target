local State = {
    active = false,
    lastHover = nil,
    cursorPos = vector2(0.5, 0.5),
    lastClickTime = 0
}

local CLICK_COOLDOWN = 100
local CENTER_SCREEN = vector2(0.5, 0.5)

local function Activate()
    if State.active then return end
    
    State.active = true
    State.cursorPos = CENTER_SCREEN
    SetCursorLocation(0.5, 0.5)
    Visual:SetActive(true)
    
    if Config.Debug.enabled then
        print("^2[NBL-Target]^7 Activated")
    end
end

local function Deactivate()
    if not State.active then return end
    
    State.active = false
    Visual:SetActive(false)
    
    local entityToClean = State.lastHover and State.lastHover.entity
    
    NUI:Close()
    Visual:ClearAll()
    
    if entityToClean and entityToClean ~= 0 then
        if GetEntityType(entityToClean) ~= 0 then
            SetEntityDrawOutline(entityToClean, false)
        end
    end
    
    State.lastHover = nil
    SetMouseCursorSprite(0)
    
    if Config.Debug.enabled then
        print("^2[NBL-Target]^7 Deactivated")
    end
end

local function DisableControls()
    local controls = Config.DisabledControls
    for i = 1, #controls do
        DisableControlAction(0, controls[i], true)
    end
end

local function GetCursorPosition()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end

local function CanClick()
    return GetGameTimer() - State.lastClickTime >= CLICK_COOLDOWN
end

local function RegisterClick()
    State.lastClickTime = GetGameTimer()
end

CreateThread(function()
    local selectKey = Config.Controls.selectKey
    
    while true do
        if State.active then
            Wait(0)
            DisableControls()
            
            local isMenuOpen = NUI:IsOpen()
            
            if isMenuOpen then
                NUI:CheckDistance()
                Visual:DrawLockedEntity()
            else
                SetMouseCursorActiveThisFrame()
                State.cursorPos = GetCursorPosition()
                State.lastHover = Visual:ProcessHover(State.cursorPos)
                
                local hover = State.lastHover
                SetMouseCursorSprite(hover and hover.entity and 5 or 0)
            end
            
            if IsDisabledControlJustPressed(0, selectKey) and CanClick() then
                RegisterClick()
                
                local hover = State.lastHover
                if not isMenuOpen and hover and hover.hasOptions then
                    local options = Registry:GetAvailableOptions(hover.entity, hover.entityType, hover.worldPos)
                    NUI:Open(options, State.cursorPos, hover.entity, hover.entityType, hover.worldPos)
                end
            end
            
            if IsDisabledControlJustPressed(0, 25) and isMenuOpen then
                NUI:Close()
            end
        else
            Wait(500)
        end
    end
end)

RegisterCommand('+nbl_target', Activate, false)
RegisterCommand('-nbl_target', Deactivate, false)
RegisterKeyMapping('+nbl_target', 'Open Target Menu', 'keyboard', Config.Controls.activationKey)

_G.Target_Deactivate = Deactivate

exports('isActive', function() return State.active end)
exports('isMenuOpen', function() return NUI:IsOpen() end)
exports('deactivate', Deactivate)

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
    return NUI:IsOpen() and NUI:GetCurrentEntity() or nil
end)

exports('closeMenu', function() NUI:Close() end)

exports('addEntity', function(entity, options) return Registry:AddEntity(entity, options) end)
exports('addLocalEntity', function(entity, options) return Registry:AddLocalEntity(entity, options) end)
exports('addModel', function(model, options) return Registry:AddModel(model, options) end)
exports('addGlobalVehicle', function(options) return Registry:AddGlobalVehicle(options) end)
exports('addGlobalPed', function(options) return Registry:AddGlobalPed(options) end)
exports('addGlobalPlayer', function(options) return Registry:AddGlobalPlayer(options) end)
exports('addGlobalSelf', function(options) return Registry:AddGlobalSelf(options) end)
exports('addGlobalObject', function(options) return Registry:AddGlobalObject(options) end)
exports('addGlobalSky', function(options) return Registry:AddGlobalOption('sky', options) end)
exports('addGlobalGround', function(options) return Registry:AddGlobalOption('ground', options) end)
exports('addGlobalOption', function(entityType, options) return Registry:AddGlobalOption(entityType, options) end)

local function HandleRemove(id)
    if type(id) == "table" and id.remove then
        return id:remove()
    end
    return Registry:RemoveById(id)
end

exports('removeEntity', HandleRemove)
exports('removeLocalEntity', HandleRemove)
exports('removeModel', HandleRemove)
exports('removeGlobalVehicle', HandleRemove)
exports('removeGlobalPed', HandleRemove)
exports('removeGlobalPlayer', HandleRemove)
exports('removeGlobalObject', HandleRemove)
exports('removeGlobalSky', HandleRemove)
exports('removeGlobalGround', HandleRemove)
exports('removeGlobalOption', HandleRemove)
exports('remove', HandleRemove)

exports('removeByName', function(name) return Registry:RemoveByName(name) end)
exports('removeByResource', function(resourceName) return Registry:RemoveByResource(resourceName) end)
