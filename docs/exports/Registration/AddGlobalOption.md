# AddGlobalOption

Register a context menu option for a custom entity type.

---

## Description

Adds a context menu option for a specific entity type. This is a generic version of the other `addGlobal*` functions, allowing you to specify any entity type as a string.

---

## Syntax

```lua
local id = exports['nbl-target']:addGlobalOption(entityType, options)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entityType` | `string` | Yes | The entity type (`"vehicle"`, `"ped"`, `"player"`, `"object"`, `"self"`) |
| `options` | `table` | Yes | Configuration table for the option |

### Options Table

See [AddEntity](./AddEntity.md) for the complete options table structure.

### Entity Types

| Type | Description |
|------|-------------|
| `"vehicle"` | All vehicles |
| `"ped"` | All NPCs (non-player peds) |
| `"player"` | All players |
| `"object"` | All objects |
| `"self"` | The player themselves |

---

## Return

| Type | Description |
|------|-------------|
| `number` | The registration ID (use this to remove the option later) |

---

## Usage Examples

### Generic Vehicle Option

```lua
local id = exports['nbl-target']:addGlobalOption('vehicle', {
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### Generic Ped Option

```lua
local id = exports['nbl-target']:addGlobalOption('ped', {
    label = "Talk",
    icon = "fas fa-comments",
    name = "talk_ped",
    distance = 2.0,
    onSelect = function(entity, coords)
        print("Talking to ped")
    end
})
```

### Dynamic Entity Type

```lua
local function registerOptionForType(entityType, label, icon, callback)
    return exports['nbl-target']:addGlobalOption(entityType, {
        label = label,
        icon = icon,
        name = entityType .. "_interact",
        distance = 2.0,
        onSelect = callback
    })
end

-- Register for multiple types
registerOptionForType('vehicle', 'Enter', 'fas fa-car-side', function(entity, coords)
    TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
end)

registerOptionForType('ped', 'Talk', 'fas fa-comments', function(entity, coords)
    print("Talking to ped")
end)
```

---

## Important Notes

- This is equivalent to using the specific `addGlobal*` functions
- Use `addGlobalVehicle`, `addGlobalPed`, etc. for better code clarity
- Use `removeGlobalOption(id)` to manually remove the option
- Entity type must be a valid string matching one of the supported types

