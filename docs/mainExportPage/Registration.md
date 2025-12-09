# Registration

Exports to register context menu options for entities.

---

## Description

This section provides a complete list of available registration exports. Use these exports to register context menu options that will appear when players target entities. You can register options for specific entities, models, or global entity types (vehicles, peds, players, objects, self).

All registration exports return a **handler object** with methods to dynamically control the option. See [Handler Methods](#handler-methods) below for details.

---

## Available Exports

| Export | Description | Link |
|--------|-------------|------|
| `addEntity(entities, options)` | Register an option for a specific entity or array of entities | [AddEntity](../exports/Registration/AddEntity.md) |
| `addLocalEntity(entities, options)` | Register an option for a local entity or array of entities (client-side only) | [AddLocalEntity](../exports/Registration/AddLocalEntity.md) |
| `addModel(models, options)` | Register an option for one or multiple models | [AddModel](../exports/Registration/AddModel.md) |
| `addGlobalVehicle(options)` | Register an option for all vehicles | [AddGlobalVehicle](../exports/Registration/AddGlobalVehicle.md) |
| `addGlobalPed(options)` | Register an option for all NPCs (peds) | [AddGlobalPed](../exports/Registration/AddGlobalPed.md) |
| `addGlobalPlayer(options)` | Register an option for all players | [AddGlobalPlayer](../exports/Registration/AddGlobalPlayer.md) |
| `addGlobalSelf(options)` | Register an option for yourself (the player) | [AddGlobalSelf](../exports/Registration/AddGlobalSelf.md) |
| `addGlobalObject(options)` | Register an option for all objects | [AddGlobalObject](../exports/Registration/AddGlobalObject.md) |
| `addGlobalOption(entityType, options)` | Register an option for a custom entity type | [AddGlobalOption](../exports/Registration/AddGlobalOption.md) |

---

## Handler Methods

All registration exports return a handler object with the following methods:

| Method | Description | Returns |
|--------|-------------|---------|
| `:setLabel(label)` | Change the option label dynamically | `handler` (chainable) |
| `:setIcon(icon)` | Change the option icon | `handler` (chainable) |
| `:setEnabled(bool)` | Enable or disable the option | `handler` (chainable) |
| `:setDistance(dist)` | Change the interaction distance | `handler` (chainable) |
| `:setCanInteract(fn)` | Change the canInteract function | `handler` (chainable) |
| `:setOnSelect(fn)` | Change the onSelect callback | `handler` (chainable) |
| `:remove()` | Remove the registration | `boolean` |
| `:getId()` | Get the registration ID(s) | `number` or `table` |

For detailed documentation, see [Handler Methods](../exports/HandlerMethods.md).

---

## Common Use Cases

- Add vehicle interactions (enter, lock, repair)
- Add NPC interactions (talk, search, trade)
- Add object interactions (pick up, open, examine)
- Add self-interactions (check health, open inventory)
- Add model-specific interactions (ATMs, doors, props)
- Dynamically update option properties using handler methods

---

## Usage Example

```lua
-- Register an option for all vehicles
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})

-- Later, dynamically change the label
target:setLabel("Get In Vehicle")
```
