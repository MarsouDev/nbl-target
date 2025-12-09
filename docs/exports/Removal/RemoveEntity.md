# RemoveEntity

Remove a context menu option registered for a specific entity.

---

## Description

Removes a context menu option that was previously registered using `addEntity`. The option will no longer appear when targeting that entity.

---

## Syntax

```lua
local success = exports['nbl-target']:removeEntity(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addEntity` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register an option
local id = exports['nbl-target']:addEntity(vehicle, {
    label = "Open Trunk",
    icon = "fas fa-box",
    name = "open_trunk",
    distance = 3.0,
    onSelect = function(entity, coords)
        print("Trunk opened")
    end
})

-- Later, remove it
local success = exports['nbl-target']:removeEntity(id)
if success then
    print("Option removed successfully")
end
```

### Remove When Entity is Deleted

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local optionId = exports['nbl-target']:addEntity(vehicle, {
    label = "Custom Option",
    icon = "fas fa-star",
    name = "custom_option",
    distance = 3.0,
    onSelect = function(entity, coords)
        print("Custom action")
    end
})

-- Check if entity still exists and remove option if deleted
CreateThread(function()
    while true do
        Wait(1000)
        if not DoesEntityExist(vehicle) then
            exports['nbl-target']:removeEntity(optionId)
            break
        end
    end
end)
```

### Remove Multiple Options

```lua
local optionIds = {}

-- Register multiple options
for i = 1, 5 do
    local id = exports['nbl-target']:addEntity(vehicle, {
        label = "Option " .. i,
        icon = "fas fa-star",
        name = "option_" .. i,
        distance = 3.0
    })
    optionIds[i] = id
end

-- Remove all options
for _, id in ipairs(optionIds) do
    exports['nbl-target']:removeEntity(id)
end
```

---

## Important Notes

- The option is automatically removed when the entity is deleted
- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addEntity` to remove the option
- Removing an option that doesn't exist is safe and won't cause errors

