# AddGlobalSelf

Register a context menu option for yourself (the player).

---

## Description

Adds a context menu option that will appear when targeting yourself. This is useful for self-interactions like checking health, opening inventory, or using items on yourself.

---

## Syntax

```lua
local id = exports['nbl-target']:addGlobalSelf(options)
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

### Check Health

```lua
local id = exports['nbl-target']:addGlobalSelf({
    label = "Check Health",
    icon = "fas fa-heart",
    name = "check_health",
    distance = 5.0,
    onSelect = function(entity, coords)
        local health = GetEntityHealth(entity)
        local armor = GetPedArmour(entity)
        
        TriggerEvent('chat:addMessage', {
            args = {
                string.format('Health: %d | Armor: %d', health, armor)
            }
        })
    end
})
```

### Open Inventory

```lua
local id = exports['nbl-target']:addGlobalSelf({
    label = "Open Inventory",
    icon = "fas fa-box",
    name = "open_inventory",
    distance = 5.0,
    onSelect = function(entity, coords)
        TriggerEvent('inventory:open')
    end
})
```

### Play Animation

```lua
local id = exports['nbl-target']:addGlobalSelf({
    label = "Play Animation",
    icon = "fas fa-person-walking",
    name = "play_animation",
    distance = 5.0,
    shouldClose = true,
    onSelect = function(entity, coords)
        TaskStartScenarioInPlace(entity, "WORLD_HUMAN_CHEERING", 0, true)
    end
})
```

### Use Item on Self

```lua
local id = exports['nbl-target']:addGlobalSelf({
    label = "Use Medkit",
    icon = "fas fa-medkit",
    name = "use_medkit",
    distance = 5.0,
    canInteract = function(entity, distance)
        -- Only show if player has a medkit
        return exports['inventory']:hasItem('medkit')
    end,
    onSelect = function(entity, coords)
        TriggerServerEvent('items:useMedkit')
    end
})
```

### Check Status

```lua
local id = exports['nbl-target']:addGlobalSelf({
    label = "Check Status",
    icon = "fas fa-info-circle",
    name = "check_status",
    distance = 5.0,
    onSelect = function(entity, coords)
        TriggerEvent('status:showMenu')
    end
})
```

---

## Important Notes

- The option will appear **only** when targeting yourself
- Requires `Config.Target.allowSelfTarget = true` to work
- Use `canInteract` to conditionally show the option based on player state or inventory
- Use `removeGlobalSelf(id)` to manually remove the option
- Multiple self options can be registered simultaneously
- Useful for creating self-interaction menus

