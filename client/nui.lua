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
    
    local parts = {}
    for i, opt in ipairs(options) do
        parts[#parts + 1] = opt.id .. opt.label .. tostring(opt.checked or false)
        
        if opt.items then
            for j, sub in ipairs(opt.items) do
                parts[#parts + 1] = sub.id .. sub.label .. tostring(sub.checked or false)
            end
        end
    end
    
    return table.concat(parts)
end

function NUI:Refresh()
    if not self.isOpen or not self.currentEntity then
        return false
    end
    
    if GetEntityType(self.currentEntity) == 0 then
        self:Close()
        return false
    end
    
    local options = Registry:GetAvailableOptions(self.currentEntity, self.currentEntityType, self.currentWorldPos)
    
    if #options == 0 then
        self:Close()
        return false
    end
    
    local newHash = self:HashOptions(options)
    
    if newHash ~= self.lastOptionsHash or self.refreshPaused then
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
    if not self.isOpen or not self.currentEntity then
        return true
    end
    
    if GetEntityType(self.currentEntity) == 0 then
        self:Close()
        return false
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
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
