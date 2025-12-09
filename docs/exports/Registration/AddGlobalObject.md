# AddGlobalObject

Register a context menu option for all objects.

---

## Description

Adds a context menu option that will appear when targeting any object in the game. This is useful for universal object interactions like picking up items, opening containers, or interacting with props.

---

## Syntax

```lua
local id = exports['nbl-target']:addGlobalObject(options)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `options` | `table` | Yes | Configuration table for the option |

### Options Table

See [AddEntity](./AddEntity.md) for the complete options table structure.

---

## Return

| Type | Description |
|------|-------------|
| `number` | The registration ID (use this to remove the option later) |

---

## Usage Examples

### Basic Object Interaction

```lua
local id = exports['nbl-target']:addGlobalObject({
    label = "Examine Object",
    icon = "fas fa-eye",
    name = "examine_object",
    distance = 3.0,
    onSelect = function(entity, coords)
        local model = GetEntityModel(entity)
        print("Object model: " .. model)
    end
})
```

### Pick Up Object

```lua
local id = exports['nbl-target']:addGlobalObject({
    label = "Pick Up",
    icon = "fas fa-hand-paper",
    name = "pickup_object",
    distance = 2.0,
    canInteract = function(entity, distance, worldPos)
        -- Only show if object is a pickup item
        return exports['items']:isPickup(entity) and distance <= 2.0
    end,
    onSelect = function(entity, coords)
        TriggerServerEvent('items:pickup', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

### Open Container

```lua
local id = exports['nbl-target']:addGlobalObject({
    label = "Open Container",
    icon = "fas fa-box-open",
    name = "open_container",
    distance = 2.0,
    canInteract = function(entity, distance, worldPos)
        -- Only show if object is a container
        return exports['containers']:isContainer(entity) and distance <= 2.0
    end,
    onSelect = function(entity, coords)
        TriggerEvent('containers:open', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

### Using Server Event

```lua
local id = exports['nbl-target']:addGlobalObject({
    label = "Interact",
    icon = "fas fa-hand-pointer",
    name = "interact_object",
    serverEvent = "objects:interact",
    distance = 3.0
})
```

### Check Object Info

```lua
local id = exports['nbl-target']:addGlobalObject({
    label = "Check Info",
    icon = "fas fa-info",
    name = "check_object_info",
    distance = 3.0,
    onSelect = function(entity, coords)
        local model = GetEntityModel(entity)
        local heading = GetEntityHeading(entity)
        
        TriggerEvent('chat:addMessage', {
            args = {
                string.format('Model: %d | Heading: %.2f', model, heading)
            }
        })
    end
})
```

---

## Important Notes

- The option will appear for **all** objects in the game
- Use `canInteract` to conditionally show the option based on object type or state
- Use `removeGlobalObject(id)` to manually remove the option
- Multiple global object options can be registered simultaneously
- Consider using `addModel` for specific object types instead of global options

