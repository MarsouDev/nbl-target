# CloseMenu

Manually close the context menu.

---

## Description

Closes the context menu if it is currently open. This is useful when you want to programmatically close the menu without user interaction.

---

## Syntax

```lua
exports['nbl-target']:closeMenu()
```

---

## Parameters

None

---

## Return

None

---

## Usage Examples

### Close Menu Manually

```lua
-- Close the menu programmatically
exports['nbl-target']:closeMenu()
```

### Close Menu After Action

```lua
RegisterNetEvent('myresource:actionComplete', function()
    -- Close the menu after completing an action
    exports['nbl-target']:closeMenu()
end)
```

### Close Menu on Condition

```lua
CreateThread(function()
    while true do
        Wait(100)
        
        if exports['nbl-target']:isMenuOpen() then
            local entity = exports['nbl-target']:getSelectedEntity()
            
            if entity and not DoesEntityExist(entity) then
                -- Close menu if entity no longer exists
                exports['nbl-target']:closeMenu()
            end
        end
    end
end)
```

### Close Menu on Distance

```lua
CreateThread(function()
    while true do
        Wait(500)
        
        if exports['nbl-target']:isMenuOpen() then
            local target = exports['nbl-target']:getCurrentTarget()
            
            if target then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - target.worldPos)
                
                if distance > 10.0 then
                    -- Close menu if player is too far
                    exports['nbl-target']:closeMenu()
                end
            end
        end
    end
end)
```

---

## Important Notes

- Only closes the menu if it is currently open
- Does not deactivate targeting mode (use `deactivate()` for that)
- Safe to call even if the menu is already closed
- Useful for programmatic menu control

