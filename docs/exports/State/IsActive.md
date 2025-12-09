# IsActive

Check if the targeting mode is currently active.

---

## Description

Returns whether the player is currently holding the activation key (default: Left Alt) and the targeting system is active.

---

## Syntax

```lua
local active = exports['nbl-target']:isActive()
```

---

## Parameters

None

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if targeting mode is active, `false` otherwise |

---

## Usage Examples

### Check if Targeting is Active

```lua
local active = exports['nbl-target']:isActive()
if active then
    print("Targeting mode is active")
else
    print("Targeting mode is not active")
end
```

### Disable Actions When Targeting

```lua
CreateThread(function()
    while true do
        Wait(0)
        
        if exports['nbl-target']:isActive() then
            -- Disable certain actions when targeting
            DisableControlAction(0, 24, true)  -- Disable attack
            DisableControlAction(0, 25, true)  -- Disable aim
        end
    end
end)
```

### Show UI Only When Active

```lua
CreateThread(function()
    while true do
        Wait(100)
        
        local active = exports['nbl-target']:isActive()
        SendNUIMessage({
            action = "setTargetingActive",
            active = active
        })
    end
end)
```

---

## Important Notes

- Returns `true` when the activation key is held down
- Returns `false` when the key is released or targeting is deactivated
- Useful for conditionally enabling/disabling features based on targeting state

