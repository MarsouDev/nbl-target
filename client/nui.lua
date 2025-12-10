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
    
    SendNUIMessage({
        action = "open",
        options = options,
        position = { x = screenPos.x * resX, y = screenPos.y * resY },
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
        if GetEntityType(entityToClean) ~= 0 then
            SetEntityDrawOutline(entityToClean, false)
        end
    end
    
    Visual:UnlockEntity()
    Visual:ClearAll()
    
    if clearSubItems ~= false then
        Registry:ClearActiveSubItems()
    end
    
    SendNUIMessage({ action = "close" })
    SetNuiFocus(false, false)
end

function NUI:HashOptions(options)
    if not options then return nil end
    
    local count = #options
    if count == 0 then return "" end
    
    local hash = count
    for i = 1, count do
        local opt = options[i]
        hash = hash + opt.id + (opt.checked and 1 or 0)
        
        local items = opt.items
        if items then
            local itemCount = #items
            hash = hash + itemCount
            for j = 1, itemCount do
                local sub = items[j]
                hash = hash + sub.id + (sub.checked and 1 or 0)
            end
        end
    end
    
    return hash
end

function NUI:UpdateWorldPos()
    if not self.currentEntity or self.currentEntity == 0 then return end
    if GetEntityType(self.currentEntity) == 0 then return end
    
    self.currentWorldPos = GetEntityCoords(self.currentEntity)
end

function NUI:Refresh()
    if not self.isOpen then return false end
    
    local entity = self.currentEntity
    if not entity then return false end
    
    if GetEntityType(entity) == 0 then
        self:Close()
        return false
    end
    
    self:UpdateWorldPos()
    
    local options = Registry:GetAvailableOptions(entity, self.currentEntityType, self.currentWorldPos)
    local optionCount = #options
    
    if optionCount == 0 then
        self:Close()
        return false
    end
    
    local newHash = self:HashOptions(options)
    local hashChanged = newHash ~= self.lastOptionsHash
    
    if hashChanged or self.refreshPaused then
        if not self.refreshPaused then
            self.lastOptionsHash = newHash
        end
        SendNUIMessage({ action = "refresh", options = options })
    end
    
    return true
end

function NUI:PauseRefresh() self.refreshPaused = true end
function NUI:ResumeRefresh() self.refreshPaused = false end

function NUI:IsOpen() return self.isOpen end
function NUI:GetCurrentEntity() return self.currentEntity end
function NUI:GetCurrentEntityType() return self.currentEntityType end
function NUI:GetCurrentWorldPos() return self.currentWorldPos end

function NUI:GetTimeSinceOpen()
    return self.isOpen and (GetGameTimer() - self.openedAt) or 0
end

function NUI:CheckDistance()
    if not self.isOpen then
        return true
    end
    
    local entity = self.currentEntity
    if not entity then
        return true
    end
    
    local entityType = GetEntityType(entity)
    if entityType == 0 then
        self:Close()
        return false
    end
    
    local playerPed = PlayerPedId()
    
    if entity == playerPed then
        return true
    end
    
    if entityType == 2 then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle ~= 0 and vehicle == entity then
            return true
        end
    end
    
    if entityType == 1 then
        if IsPedInAnyVehicle(entity, false) then
            local entityVehicle = GetVehiclePedIsIn(entity, false)
            local playerVehicle = GetVehiclePedIsIn(playerPed, false)
            if entityVehicle ~= 0 and entityVehicle == playerVehicle then
                return true
            end
        end
    end
    
    self:UpdateWorldPos()
    
    local playerCoords = GetEntityCoords(playerPed)
    local entityCoords = GetEntityCoords(entity)
    local distance = #(playerCoords - entityCoords)
    
    if distance > Config.Target.maxDistance + 10.0 then
        self:Close()
        return false
    end
    
    return true
end

CreateThread(function()
    while true do
        local refreshInterval = Config.Menu.refreshInterval
        if NUI.isOpen and refreshInterval > 0 then
            NUI:Refresh()
            Wait(refreshInterval)
        else
            Wait(500)
        end
    end
end)

RegisterNUICallback("select", function(data, cb)
    cb("ok")
    
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

RegisterNUICallback("close", function(_, cb)
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

RegisterNUICallback("submenuOpen", function(_, cb)
    NUI:PauseRefresh()
    cb("ok")
end)

RegisterNUICallback("submenuClose", function(_, cb)
    NUI:ResumeRefresh()
    cb("ok")
end)

RegisterNUICallback("check", function(data, cb)
    cb("ok")
    
    local optionId = tonumber(data.id)
    if not optionId then return end
    
    Registry:OnCheck(optionId, NUI.currentEntity, NUI.currentWorldPos, data.checked == true)
end)

