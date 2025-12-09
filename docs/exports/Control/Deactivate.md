# Deactivate

Deactivate the targeting mode.

---

## Description

Deactivates the targeting mode, closing the menu (if open) and disabling the targeting system. This is equivalent to releasing the activation key.

---

## Syntax

```lua
exports['nbl-target']:deactivate()
```

---

## Parameters

None

---

## Return

None

---

## Usage Examples

### Deactivate Targeting

```lua
-- Deactivate targeting mode
exports['nbl-target']:deactivate()
```

### Deactivate After Action

```lua
RegisterNetEvent('myresource:actionComplete', function()
    -- Deactivate targeting after completing an action
    exports['nbl-target']:deactivate()
end)
```

### Deactivate on Condition

```lua
CreateThread(function()
    while true do
        Wait(100)
        
        if exports['nbl-target']:isActive() then
            -- Deactivate if player enters a vehicle
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                exports['nbl-target']:deactivate()
            end
        end
    end
end)
```

### Deactivate on Distance

```lua
CreateThread(function()
    while true do
        Wait(500)
        
        if exports['nbl-target']:isActive() then
            local target = exports['nbl-target']:getCurrentTarget()
            
            if target then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - target.worldPos)
                
                if distance > Config.Target.maxDistance then
                    -- Deactivate if target is too far
                    exports['nbl-target']:deactivate()
                end
            end
        end
    end
end)
```

---

## Important Notes

- Closes the menu if it is open
- Disables targeting mode completely
- Equivalent to releasing the activation key
- Safe to call even if targeting is not active
- Useful for programmatic control of the targeting system

