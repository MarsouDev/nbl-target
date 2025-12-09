# AddLocalEntity

Register a context menu option for a local entity (client-side only).

---

## Description

Similar to `addEntity`, but specifically for local entities that exist only on the client side. This is useful for entities that are not networked or synced across clients.

---

## Syntax

```lua
local id = exports['nbl-target']:addLocalEntity(entity, options)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `entity` | `number` | Yes | The local entity handle to register the option for |
| `options` | `table` | Yes | Configuration table for the option |

### Options Table

See [AddEntity](./AddEntity.md) for the complete options table structure.

---

## Return

| Type | Description |
|------|-------------|
| `number` | The registration ID (use this to remove the option later) |
| `nil` | If the entity is invalid or doesn't exist |

---

## Usage Examples

### Local Object Registration

```lua
local object = CreateObject(GetHashKey('prop_atm_01'), coords.x, coords.y, coords.z, false, false, false)

local id = exports['nbl-target']:addLocalEntity(object, {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm_local",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM', entity)
    end
})
```

### Temporary Local Entity

```lua
-- Create a temporary local ped for testing
local ped = CreatePed(4, GetHashKey('s_m_y_cop_01'), coords.x, coords.y, coords.z, 0.0, false, false)

local id = exports['nbl-target']:addLocalEntity(ped, {
    label = "Talk",
    icon = "fas fa-comments",
    name = "talk_local_ped",
    distance = 2.0,
    onSelect = function(entity, coords)
        print("Talking to local ped")
    end
})
```

---

## Important Notes

- Local entities are not synced across clients
- The option is automatically removed when the entity is deleted
- Use `removeLocalEntity(id)` to manually remove the option
- Local entities are cleaned up automatically when invalid

