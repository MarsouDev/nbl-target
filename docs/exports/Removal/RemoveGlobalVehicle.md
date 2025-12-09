# RemoveGlobalVehicle

Remove a global vehicle context menu option.

---

## Description

Removes a context menu option that was previously registered using `addGlobalVehicle`. The option will no longer appear when targeting vehicles.

---

## Syntax

```lua
local success = exports['nbl-target']:removeGlobalVehicle(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addGlobalVehicle` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a global vehicle option
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0
})

-- Later, remove it
local success = exports['nbl-target']:removeGlobalVehicle(id)
if success then
    print("Global vehicle option removed")
end
```

### Remove When Resource Stops

```lua
local vehicleOptionId = exports['nbl-target']:addGlobalVehicle({
    label = "Custom Vehicle Action",
    icon = "fas fa-star",
    name = "custom_vehicle_action",
    distance = 3.0
})

-- Remove when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        exports['nbl-target']:removeGlobalVehicle(vehicleOptionId)
    end
end)
```

---

## Important Notes

- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addGlobalVehicle` to remove the option
- Options are automatically removed when the resource stops (if registered properly)
- Removing an option that doesn't exist is safe and won't cause errors

