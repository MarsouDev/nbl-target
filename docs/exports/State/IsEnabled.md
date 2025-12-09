# IsEnabled

Check if the registry system is enabled.

---

## Description

Returns whether the registry system is currently enabled. When disabled, context menu options won't appear even if they are registered.

---

## Syntax

```lua
local enabled = exports['nbl-target']:isEnabled()
```

---

## Parameters

None

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the registry is enabled, `false` if disabled |

---

## Usage Examples

### Check Registry Status

```lua
local enabled = exports['nbl-target']:isEnabled()
if enabled then
    print("Registry is enabled")
else
    print("Registry is disabled")
end
```

### Conditional Registration

```lua
if exports['nbl-target']:isEnabled() then
    -- Only register options if registry is enabled
    exports['nbl-target']:addGlobalVehicle({
        label = "Enter Vehicle",
        icon = "fas fa-car-side",
        name = "enter_vehicle",
        distance = 5.0
    })
end
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

---

## Important Notes

- Returns `true` by default (registry is enabled on start)
- Returns `false` if the registry has been disabled with `disable()`
- Useful for checking the state before registering options or performing actions

