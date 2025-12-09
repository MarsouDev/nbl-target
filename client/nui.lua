NUI = {
    isOpen = false,
    currentEntity = nil,
    currentEntityType = nil,
    currentWorldPos = nil,
    openedAt = 0,
    lastOptions = nil
}

function NUI:Open(options, screenPos, entity, entityType, worldPos)
    if #options == 0 then return end
    
    self.isOpen = true
    self.currentEntity = entity
    self.currentEntityType = entityType
    self.currentWorldPos = worldPos
    self.openedAt = GetGameTimer()
    self.lastOptions = options
    
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

function NUI:Close()
    if not self.isOpen then return end
    
    local entityToClean = self.currentEntity
    
    self.isOpen = false
    self.currentEntity = nil
    self.currentEntityType = nil
    self.currentWorldPos = nil
    self.openedAt = 0
    self.lastOptions = nil
    
    if entityToClean then
        pcall(function()
            SetEntityDrawOutline(entityToClean, false)
        end)
    end
    
    Visual:UnlockEntity()
    Visual:ClearAll()
    
    SendNUIMessage({
        action = "close"
    })
    
    SetNuiFocus(false, false)
end

function NUI:Refresh()
    if not self.isOpen then return false end
    if not self.currentEntity then return false end
    
    local options = Registry:GetAvailableOptions(
        self.currentEntity,
        self.currentEntityType,
        self.currentWorldPos
    )
    
    if #options == 0 then
        self:Close()
        return false
    end
    
    if not self:OptionsEqual(options, self.lastOptions) then
        self.lastOptions = options
        SendNUIMessage({
            action = "refresh",
            options = options
        })
    end
    
    return true
end

function NUI:OptionsEqual(a, b)
    if not a or not b then return false end
    if #a ~= #b then return false end
    
    for i, optA in ipairs(a) do
        local optB = b[i]
        if not optB then return false end
        if optA.id ~= optB.id then return false end
        if optA.label ~= optB.label then return false end
        
        local itemsA = optA.items
        local itemsB = optB.items
        
        if itemsA and itemsB then
            if #itemsA ~= #itemsB then return false end
            for j, subA in ipairs(itemsA) do
                local subB = itemsB[j]
                if not subB then return false end
                if subA.id ~= subB.id then return false end
            end
        elseif itemsA or itemsB then
            return false
        end
    end
    
    return true
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
    if data.id then
        local entity = NUI.currentEntity
        local worldPos = NUI.currentWorldPos
        local shouldClose = data.shouldClose
        
        NUI:Close()
        
        Wait(50)
        
        Registry:OnSelect(data.id, entity, worldPos)
        
        if shouldClose then
            exports['nbl-contextmenu']:deactivate()
        end
    end
    
    cb("ok")
end)

RegisterNUICallback("close", function(data, cb)
    NUI:Close()
    cb("ok")
end)

RegisterNUICallback("hover", function(data, cb)
    cb("ok")
end)
