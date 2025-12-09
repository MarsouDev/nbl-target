# Removal

Exports to remove registered context menu options.

---

## Description

This section provides a complete list of available removal exports. Use these exports to remove context menu options that were previously registered. You can remove options by their registration ID, by their name identifier, or remove all options from a specific resource.

You can also use the `handler:remove()` method from registration exports, or the generic `remove()` export.

---

## Available Exports

| Export | Description | Link |
|--------|-------------|------|
| `remove(handler)` | Generic remove function (works with handler or ID) | [Remove](../exports/Removal/Remove.md) |
| `removeEntity(handler)` | Remove an option registered for a specific entity | [RemoveEntity](../exports/Removal/RemoveEntity.md) |
| `removeLocalEntity(handler)` | Remove an option registered for a local entity | [RemoveLocalEntity](../exports/Removal/RemoveLocalEntity.md) |
| `removeModel(handler)` | Remove an option registered for a model | [RemoveModel](../exports/Removal/RemoveModel.md) |
| `removeGlobalVehicle(handler)` | Remove a global vehicle option | [RemoveGlobalVehicle](../exports/Removal/RemoveGlobalVehicle.md) |
| `removeGlobalPed(handler)` | Remove a global ped option | [RemoveGlobalPed](../exports/Removal/RemoveGlobalPed.md) |
| `removeGlobalPlayer(handler)` | Remove a global player option | [RemoveGlobalPlayer](../exports/Removal/RemoveGlobalPlayer.md) |
| `removeGlobalSelf(handler)` | Remove a global self option | [RemoveGlobalSelf](../exports/Removal/RemoveGlobalSelf.md) |
| `removeGlobalObject(handler)` | Remove a global object option | [RemoveGlobalObject](../exports/Removal/RemoveGlobalObject.md) |
| `removeGlobalOption(handler)` | Remove a global option by entity type | [RemoveGlobalOption](../exports/Removal/RemoveGlobalOption.md) |
| `removeByName(name)` | Remove an option by its name identifier | [RemoveByName](../exports/Removal/RemoveByName.md) |
| `removeByResource(resourceName)` | Remove all options from a specific resource | [RemoveByResource](../exports/Removal/RemoveByResource.md) |

---

## Common Use Cases

- Remove options when entities are deleted
- Clean up options when a resource stops
- Remove options dynamically based on game state
- Remove multiple options at once
- Remove options without storing the registration ID

---

## Usage Example

```lua
-- Register an option
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Custom Action",
    icon = "fas fa-star",
    name = "custom_action",
    distance = 3.0
})

-- Later, remove it using the handler
target:remove()

-- Or using the export
exports['nbl-target']:removeGlobalVehicle(target)
```
