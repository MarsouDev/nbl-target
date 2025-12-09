# AddGlobalPlayer

Register a context menu option for all players.

---

## Description

Adds a context menu option that will appear when targeting any player in the game. This is useful for player-to-player interactions like trading, handcuffing, or checking player information.

---

## Syntax

```lua
local id = exports['nbl-target']:addGlobalPlayer(options)
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

### Basic Player Interaction

```lua
local id = exports['nbl-target']:addGlobalPlayer({
    label = "Interact",
    icon = "fas fa-user",
    name = "interact_player",
    distance = 2.0,
    onSelect = function(entity, coords)
        local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
        print("Interacting with player: " .. playerId)
    end
})
```

### Handcuff Player (Police Only)

```lua
local id = exports['nbl-target']:addGlobalPlayer({
    label = "Handcuff",
    icon = "fas fa-handcuffs",
    name = "handcuff_player",
    distance = 2.0,
    canInteract = function(entity, distance, worldPos)
        -- Only show if player is a police officer
        return exports['police']:isPolice() and distance <= 2.0
    end,
    onSelect = function(entity, coords)
        local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
        TriggerServerEvent('police:handcuff', playerId)
    end
})
```

### Trade with Player

```lua
local id = exports['nbl-target']:addGlobalPlayer({
    label = "Trade",
    icon = "fas fa-handshake",
    name = "trade_player",
    distance = 2.0,
    onSelect = function(entity, coords)
        local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
        TriggerEvent('trading:openMenu', playerId)
    end
})
```

### Check Player ID

```lua
local id = exports['nbl-target']:addGlobalPlayer({
    label = "Check ID",
    icon = "fas fa-id-card",
    name = "check_id",
    distance = 2.0,
    onSelect = function(entity, coords)
        local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
        TriggerServerEvent('identity:checkID', playerId)
    end
})
```

### Using Server Event

```lua
local id = exports['nbl-target']:addGlobalPlayer({
    label = "Search",
    icon = "fas fa-search",
    name = "search_player",
    serverEvent = "police:searchPlayer",
    distance = 1.5
})
```

---

## Important Notes

- The option will appear for **all** players in the game
- Does not apply to NPCs (use `addGlobalPed` for that)
- Does not apply to yourself (use `addGlobalSelf` for that)
- Use `canInteract` to conditionally show the option based on player state or permissions
- Use `removeGlobalPlayer(id)` to manually remove the option
- Multiple global player options can be registered simultaneously

