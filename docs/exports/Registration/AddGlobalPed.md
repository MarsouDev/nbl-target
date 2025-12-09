# AddGlobalPed

Register a context menu option for all NPCs (peds).

---

## Description

Adds a context menu option that will appear when targeting any NPC (non-player ped) in the game. This is useful for universal NPC interactions like talking, searching, or trading.

---

## Syntax

```lua
local id = exports['nbl-target']:addGlobalPed(options)
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

### Basic NPC Interaction

```lua
local id = exports['nbl-target']:addGlobalPed({
    label = "Talk",
    icon = "fas fa-comments",
    name = "talk_npc",
    distance = 2.0,
    onSelect = function(entity, coords)
        TaskTurnPedToFaceEntity(entity, PlayerPedId(), 2000)
        TaskLookAtEntity(entity, PlayerPedId(), 2000, 2048, 2)
        print("Talking to NPC")
    end
})
```

### Search NPC (Police Only)

```lua
local id = exports['nbl-target']:addGlobalPed({
    label = "Search",
    icon = "fas fa-search",
    name = "search_npc",
    distance = 1.5,
    canInteract = function(entity, distance, worldPos)
        -- Only show if player is a police officer
        return exports['police']:isPolice() and distance <= 1.5
    end,
    onSelect = function(entity, coords)
        TriggerServerEvent('police:searchPed', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

### Trade with NPC

```lua
local id = exports['nbl-target']:addGlobalPed({
    label = "Trade",
    icon = "fas fa-handshake",
    name = "trade_npc",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('trading:openMenu', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

### Using Server Event

```lua
local id = exports['nbl-target']:addGlobalPed({
    label = "Rob",
    icon = "fas fa-money-bill",
    name = "rob_npc",
    serverEvent = "crime:robPed",
    distance = 1.5
})
```

### Follow Player

```lua
local id = exports['nbl-target']:addGlobalPed({
    label = "Follow Me",
    icon = "fas fa-walking",
    name = "follow_npc",
    distance = 3.0,
    onSelect = function(entity, coords)
        TaskGoToEntity(entity, PlayerPedId(), -1, 2.0, 1.0, 1073741824, 0)
    end
})
```

---

## Important Notes

- The option will appear for **all** NPCs (non-player peds) in the game
- Does not apply to players (use `addGlobalPlayer` for that)
- Use `canInteract` to conditionally show the option based on NPC state or player permissions
- Use `removeGlobalPed(id)` to manually remove the option
- Multiple global ped options can be registered simultaneously

