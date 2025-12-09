# Disable

Disable the registry system.

---

## Description

Disables the registry system, preventing context menu options from being displayed. Options can still be registered, but they won't appear until the registry is re-enabled.

---

## Syntax

```lua
exports['nbl-target']:disable()
```

---

## Parameters

None

---

## Return

None

---

## Usage Examples

### Disable Registry

```lua
-- Disable the registry system
exports['nbl-target']:disable()
```

### Disable During Cutscene

```lua
RegisterNetEvent('cutscene:start', function()
    -- Disable targeting during cutscene
    exports['nbl-target']:disable()
end)

RegisterNetEvent('cutscene:end', function()
    -- Re-enable after cutscene
    exports['nbl-target']:enable()
end)
```

### Disable in Specific Areas

```lua
CreateThread(function()
    while true do
        Wait(1000)
        
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        -- Disable in safe zones
        if IsInSafeZone(coords) then
            if exports['nbl-target']:isEnabled() then
                exports['nbl-target']:disable()
            end
        else
            if not exports['nbl-target']:isEnabled() then
                exports['nbl-target']:enable()
            end
        end
    end
end)
```

---

## Important Notes

- When disabled, no options will appear even if registered
- Options are not removed, just hidden
- Use `enable()` to re-enable the registry
- Use `isEnabled()` to check the current state
- Useful for temporarily disabling targeting during specific game states

