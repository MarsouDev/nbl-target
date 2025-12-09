# Control

Exports to control the targeting system behavior.

---

## Description

This section provides a complete list of available control exports. Use these exports to enable or disable the registry system, activate or deactivate targeting mode, or close the menu programmatically.

---

## Available Exports

| Export | Description | Link |
|--------|-------------|------|
| `enable()` | Enable the registry system | [Enable](../exports/Control/Enable.md) |
| `disable()` | Disable the registry system | [Disable](../exports/Control/Disable.md) |
| `deactivate()` | Deactivate the targeting mode | [Deactivate](../exports/Control/Deactivate.md) |
| `closeMenu()` | Manually close the context menu | [CloseMenu](../exports/Control/CloseMenu.md) |

---

## Common Use Cases

- Temporarily disable targeting during cutscenes
- Disable targeting in specific areas (safe zones, interiors)
- Programmatically close the menu after actions
- Toggle targeting system on/off

---

## Usage Example

```lua
-- Disable targeting during a cutscene
RegisterNetEvent('cutscene:start', function()
    exports['nbl-target']:disable()
end)

RegisterNetEvent('cutscene:end', function()
    exports['nbl-target']:enable()
end)
```
