# State

Exports to check the current state of the targeting system and menu.

---

## Description

This section provides a complete list of available state exports. Use these exports to query the current state of the targeting system, check if the menu is open, verify if the registry is enabled, or get information about the currently targeted entity.

---

## Available Exports

| Export | Description | Link |
|--------|-------------|------|
| `isActive()` | Check if targeting mode is currently active | [IsActive](../exports/State/IsActive.md) |
| `isMenuOpen()` | Check if the context menu is currently open | [IsMenuOpen](../exports/State/IsMenuOpen.md) |
| `isEnabled()` | Check if the registry system is enabled | [IsEnabled](../exports/State/IsEnabled.md) |
| `getCurrentTarget()` | Get information about the currently hovered or selected entity | [GetCurrentTarget](../exports/State/GetCurrentTarget.md) |
| `getSelectedEntity()` | Get the entity handle of the currently selected entity (when menu is open) | [GetSelectedEntity](../exports/State/GetSelectedEntity.md) |

---

## Common Use Cases

- Disable certain actions when targeting is active
- Show custom UI only when menu is closed
- Get entity information without storing it yourself
- Monitor target changes in real-time
- Check system state before performing actions

---

## Usage Example

```lua
-- Check if targeting is active before doing something
if exports['nbl-target']:isActive() then
    local target = exports['nbl-target']:getCurrentTarget()
    if target then
        print("Targeting: " .. target.entityType)
    end
end
```
