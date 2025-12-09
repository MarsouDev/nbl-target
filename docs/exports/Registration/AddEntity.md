# AddEntity

Register a context menu option for one or multiple entities.

---

## Description

Adds a context menu option that will appear when targeting a specific entity. The option is tied to the entity's handle, so it will only show for that exact entity instance.

**Now supports arrays!** You can pass a single entity or an array of entities to register the same option for multiple entities at once.

---

## Syntax

```lua
local target = exports['nbl-target']:addEntity(entities, options)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entities` | `number` / `table` | Yes | Entity handle or array of entity handles |
| `options` | `table` | Yes | Configuration table for the option |

### Entities Parameter Types

```lua
-- Single entity
exports['nbl-target']:addEntity(vehicle, options)

-- Multiple entities (array)
exports['nbl-target']:addEntity({vehicle1, vehicle2, vehicle3}, options)
```

### Options Table

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `label` | `string` | Yes | Display text shown in the menu |
| `name` | `string` | No | Unique identifier for the option (used with `removeByName`) |
| `icon` | `string` | No | Font Awesome icon class (default: `"fas fa-hand-pointer"`) |
| `distance` | `number` | No | Maximum interaction distance in meters (default: `3.0`) |
| `canInteract` | `function` | No | Function that returns `true`/`false` to show/hide the option |
| `onSelect` | `function` | No | Callback function when option is selected |
| `export` | `string` | No | Export to call (format: `"resource.export"`) |
| `event` | `string` | No | Client event name to trigger |
| `serverEvent` | `string` | No | Server event name to trigger |
| `command` | `string` | No | Command to execute |
| `items` | `table` | No | Sub-menu items table |
| `shouldClose` | `boolean` | No | Close menu and deactivate targeting (default: `false`) |
| `enabled` | `boolean` | No | Enable/disable the option (default: `true`) |

---

## Return

| Type | Description |
|------|-------------|
| `handler` | A handler object with methods to control the registration |
| `nil` | If no valid entities provided |

### Handler Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `:setLabel(label)` | Change the option label | `handler` (chainable) |
| `:setIcon(icon)` | Change the option icon | `handler` (chainable) |
| `:setEnabled(bool)` | Enable/disable the option | `handler` (chainable) |
| `:setDistance(dist)` | Change interaction distance | `handler` (chainable) |
| `:setCanInteract(fn)` | Change the canInteract function | `handler` (chainable) |
| `:setOnSelect(fn)` | Change the onSelect callback | `handler` (chainable) |
| `:remove()` | Remove all registrations | `boolean` |
| `:getId()` | Get the ID(s) | `number` or `table` |

---

## Usage Examples

### Basic Entity Registration

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

local target = exports['nbl-target']:addEntity(vehicle, {
    label = "Open Trunk",
    icon = "fas fa-box",
    name = "open_trunk",
    distance = 3.0,
    onSelect = function(entity, coords, registration)
        print("Trunk opened for vehicle: " .. entity)
    end
})
```

### Multiple Entities (Array)

```lua
-- Register for all nearby vehicles at once
local vehicles = GetGamePool('CVehicle')

local target = exports['nbl-target']:addEntity(vehicles, {
    label = "Inspect",
    icon = "fas fa-search",
    distance = 3.0,
    onSelect = function(entity, coords)
        print("Inspecting vehicle: " .. entity)
    end
})
```

### Using Handler Methods

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

local target = exports['nbl-target']:addEntity(vehicle, {
    label = "Open Trunk",
    icon = "fas fa-box",
    distance = 3.0
})

-- Later, dynamically change the label
target:setLabel("Trunk (Unlocked)")

-- Chain multiple changes
target:setLabel("Close Trunk"):setIcon("fas fa-box-open")

-- Temporarily disable
target:setEnabled(false)

-- Re-enable
target:setEnabled(true)

-- Remove when done
target:remove()
```

### With canInteract Condition

```lua
local ped = GetPedNearbyPlayers(PlayerPedId(), 5.0)[1]

local target = exports['nbl-target']:addEntity(ped, {
    label = "Search",
    icon = "fas fa-search",
    name = "search_ped",
    distance = 2.0,
    canInteract = function(entity, distance, worldPos, name, bone)
        return exports['police']:isPolice() and distance <= 1.5
    end,
    onSelect = function(entity, coords)
        TriggerServerEvent('police:searchPed', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

### With Sub-menu

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

local target = exports['nbl-target']:addEntity(vehicle, {
    label = "Vehicle Actions",
    icon = "fas fa-car",
    name = "vehicle_actions",
    items = {
        {
            id = 1,
            label = "Lock/Unlock",
            icon = "fas fa-lock"
        },
        {
            id = 2,
            label = "Open Trunk",
            icon = "fas fa-box"
        },
        {
            id = 3,
            label = "Repair",
            icon = "fas fa-wrench"
        }
    },
    onSelect = function(entity, coords, registration)
        print("Vehicle action selected")
    end
})
```

### Using shouldClose

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

local target = exports['nbl-target']:addEntity(vehicle, {
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    shouldClose = true,
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

---

## Important Notes

- The option is automatically removed when the entity is deleted (cleanup every 30s)
- If the entity handle becomes invalid, the option will not appear
- Use `handler:remove()` or `removeEntity(handler)` to manually remove the option
- The `onSelect` callback receives: `entity` (number), `coords` (vector3), `registration` (table)
- The `canInteract` callback receives: `entity` (number), `distance` (number), `worldPos` (vector3), `name` (string), `bone` (number or nil)
- All callbacks are protected with `pcall` to prevent crashes
- Handler methods are chainable (except `:remove()` and `:getId()`)

