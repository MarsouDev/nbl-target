# RemoveGlobalOption

Remove a global context menu option by entity type.

---

## Description

Removes a context menu option that was previously registered using `addGlobalOption`. This is the generic version of the other `removeGlobal*` functions.

---

## Syntax

```lua
local success = exports['nbl-target']:removeGlobalOption(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addGlobalOption` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a global option
local id = exports['nbl-target']:addGlobalOption('vehicle', {
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0
})

-- Later, remove it
local success = exports['nbl-target']:removeGlobalOption(id)
if success then
    print("Global option removed")
end
```

---

## Important Notes

- This is equivalent to using the specific `removeGlobal*` functions
- Use `removeGlobalVehicle`, `removeGlobalPed`, etc. for better code clarity
- Returns `false` if the ID doesn't exist or was already removed
- Removing an option that doesn't exist is safe and won't cause errors

