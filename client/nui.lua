NUI = {
    isOpen = false,
    currentEntity = nil,
    currentEntityType = nil,
    currentWorldPos = nil
}

function NUI:Open(options, screenPos, entity, entityType, worldPos)
    if #options == 0 then return end
    
    self.isOpen = true
    self.currentEntity = entity
    self.currentEntityType = entityType
    self.currentWorldPos = worldPos
    
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
    
    self.isOpen = false
    self.currentEntity = nil
    self.currentEntityType = nil
    self.currentWorldPos = nil
    
    SendNUIMessage({
        action = "close"
    })
    
    SetNuiFocus(false, false)
end

function NUI:IsOpen()
    return self.isOpen
end

RegisterNUICallback("select", function(data, cb)
    if data.id then
        local entity = NUI.currentEntity
        local worldPos = NUI.currentWorldPos
        
        NUI:Close()
        
        Registry:OnSelect(data.id, entity, worldPos)
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
