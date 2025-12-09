NUI = {
    isOpen = false,
    currentEntity = nil,
    currentEntityType = nil,
    currentWorldPos = nil,
    openedAt = 0,
    lastOptionsHash = nil,
    refreshPaused = false
}

function NUI:Open(options, screenPos, entity, entityType, worldPos)
    if #options == 0 then return end
    
    self.isOpen = true
    self.currentEntity = entity
    self.currentEntityType = entityType
    self.currentWorldPos = worldPos
    self.openedAt = GetGameTimer()
    self.lastOptionsHash = self:HashOptions(options)
    self.refreshPaused = false
    
    Visual:LockEntity(entity)
    
    local resX, resY = GetActiveScreenResolution()
    local pixelX = screenPos.x * resX
    local pixelY = screenPos.y * resY
    
    SendNUIMessage({
        action = "open",
        options = options,
        position = {
            x = pixelX,
            y = pixelY
        },
        scale = Config.Menu.scale
    })
    
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)
end

function NUI:Close(clearSubItems)
    if not self.isOpen then return end
    
    local entityToClean = self.currentEntity
    
    self.isOpen = false
    self.currentEntity = nil
    self.currentEntityType = nil
    self.currentWorldPos = nil
    self.openedAt = 0
    self.lastOptionsHash = nil
    self.refreshPaused = false
    
    if entityToClean then
        pcall(function()
            SetEntityDrawOutline(entityToClean, false)
        end)
    end
    
    Visual:UnlockEntity()
    Visual:ClearAll()
    
    if clearSubItems ~= false then
        Registry:ClearActiveSubItems()
    end
    
    SendNUIMessage({
        action = "close"
    })
    
    SetNuiFocus(false, false)
end

function NUI:HashOptions(options)
    if not options then return nil end
    
    local hash = ""
    for _, opt in ipairs(options) do
        hash = hash .. tostring(opt.id) .. opt.label .. tostring(opt.checked or false)
        if opt.items then
            for _, sub in ipairs(opt.items) do
                hash = hash .. tostring(sub.id) .. sub.label .. tostring(sub.checked or false)
            end
        end
    end
    return hash
end

function NUI:Refresh()
    if not self.isOpen then return false end
    if not self.currentEntity then return false end
    
    if not DoesEntityExist(self.currentEntity) then
        self:Close()
        return false
    end
    
    local options = Registry:GetAvailableOptions(
        self.currentEntity,
        self.currentEntityType,
        self.currentWorldPos
    )
    
    if #options == 0 then
        self:Close()
        return false
    end
    
    local newHash = self:HashOptions(options)
    local hasChanges = newHash ~= self.lastOptionsHash
    
    if hasChanges or self.refreshPaused then
        if not self.refreshPaused then
            self.lastOptionsHash = newHash
        end
        SendNUIMessage({
            action = "refresh",
            options = options
        })
    end
    
    return true
end

function NUI:PauseRefresh()
    self.refreshPaused = true
end

function NUI:ResumeRefresh()
    self.refreshPaused = false
end

function NUI:IsOpen()
    return self.isOpen
end

function NUI:GetCurrentEntity()
    return self.currentEntity
end

function NUI:GetCurrentEntityType()
    return self.currentEntityType
end

function NUI:GetCurrentWorldPos()
    return self.currentWorldPos
end

function NUI:GetTimeSinceOpen()
    if not self.isOpen then return 0 end
    return GetGameTimer() - self.openedAt
end

function NUI:CheckDistance()
    if not self.isOpen then return true end
    if not self.currentEntity then return true end
    
    if not DoesEntityExist(self.currentEntity) then
        self:Close()
        return false
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(self.currentEntity)
    local distance = #(playerCoords - entityCoords)
    
    if distance > Config.Target.maxDistance + 2.0 then
        self:Close()
        return false
    end
    
    return true
end

CreateThread(function()
    while true do
        if NUI.isOpen and Config.Menu.refreshInterval > 0 then
            NUI:Refresh()
            Wait(Config.Menu.refreshInterval)
        else
            Wait(500)
        end
    end
end)

RegisterNUICallback("select", function(data, cb)
    cb("ok")
    
    if not data.id then return end
    
    local optionId = tonumber(data.id)
    if not optionId then return end
    
    local entity = NUI.currentEntity
    local worldPos = NUI.currentWorldPos
    local shouldClose = data.shouldClose
    
    NUI:Close(false)
    
    Wait(10)
    
    Registry:OnSelect(optionId, entity, worldPos)
    
    Registry:ClearActiveSubItems()
    
    if shouldClose then
        exports['nbl-target']:deactivate()
    end
end)

RegisterNUICallback("close", function(data, cb)
    NUI:Close()
    cb("ok")
end)

RegisterNUICallback("hover", function(data, cb)
    if data.hasSubmenu then
        NUI:PauseRefresh()
    else
        NUI:ResumeRefresh()
    end
    cb("ok")
end)

RegisterNUICallback("submenuOpen", function(data, cb)
    NUI:PauseRefresh()
    cb("ok")
end)

RegisterNUICallback("submenuClose", function(data, cb)
    NUI:ResumeRefresh()
    cb("ok")
end)

RegisterNUICallback("check", function(data, cb)
    cb("ok")
    
    if not data.id then return end
    
    local optionId = tonumber(data.id)
    if not optionId then return end
    
    local entity = NUI.currentEntity
    local worldPos = NUI.currentWorldPos
    local newState = data.checked == true
    
    Registry:OnCheck(optionId, entity, worldPos, newState)
end)
