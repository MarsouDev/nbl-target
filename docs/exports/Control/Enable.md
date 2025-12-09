# Enable

Enable the registry system.

---

## Description

Enables the registry system, allowing context menu options to be registered and displayed. The registry is enabled by default, but this function can be used to re-enable it after disabling.

---

## Syntax

```lua
exports['nbl-target']:enable()
```

---

## Parameters

None

---

## Return

None

---

## Usage Examples

### Enable Registry

```lua
-- Enable the registry system
exports['nbl-target']:enable()
```

### Toggle Registry

```lua
RegisterCommand('toggletarget', function()
    if exports['nbl-target']:isEnabled() then
        exports['nbl-target']:disable()
        print("Targeting disabled")
    else
        exports['nbl-target']:enable()
        print("Targeting enabled")
    end
end)
```

### Enable After Condition

```lua
-- Disable during cutscene
exports['nbl-target']:disable()

-- Enable after cutscene ends
RegisterNetEvent('cutscene:ended', function()
    exports['nbl-target']:enable()
end)
```

---

## Important Notes

- The registry is enabled by default
- When disabled, no options will appear even if registered
- Use `isEnabled()` to check the current state
- Useful for temporarily disabling targeting during specific game states

