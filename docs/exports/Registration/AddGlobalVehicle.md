# AddGlobalVehicle

Register a context menu option for all vehicles.

---

## Description

Adds a context menu option that will appear when targeting any vehicle in the game. This is useful for universal vehicle interactions like entering, locking, or checking vehicle information.

---

## Syntax

```lua
local id = exports['nbl-target']:addGlobalVehicle(options)
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

### Basic Vehicle Interaction

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### With canInteract Condition

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Lock / Unlock",
    icon = "fas fa-lock",
    name = "lock_vehicle",
    distance = 5.0,
    canInteract = function(entity, distance, worldPos)
        -- Only show if player owns the vehicle or has keys
        return exports['keys']:hasKeys(entity) and distance <= 5.0
    end,
    onSelect = function(entity, coords)
        local locked = GetVehicleDoorLockStatus(entity)
        if locked == 2 then
            SetVehicleDoorsLocked(entity, 1)
            TriggerEvent('chat:addMessage', { args = {'Vehicle unlocked!'} })
        else
            SetVehicleDoorsLocked(entity, 2)
            TriggerEvent('chat:addMessage', { args = {'Vehicle locked!'} })
        end
    end
})
```

### Check Vehicle Health

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Check Vehicle",
    icon = "fas fa-car",
    name = "check_vehicle",
    distance = 5.0,
    onSelect = function(entity, coords)
        local health = GetVehicleEngineHealth(entity)
        local bodyHealth = GetVehicleBodyHealth(entity)
        
        TriggerEvent('chat:addMessage', {
            args = {
                string.format('Engine: %d%% | Body: %d%%', 
                    math.floor(health / 10), 
                    math.floor(bodyHealth / 10)
                )
            }
        })
    end
})
```

### Using Export

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Repair Vehicle",
    icon = "fas fa-wrench",
    name = "repair_vehicle",
    export = "mechanic.repair",
    distance = 3.0
})
```

### Using Server Event

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Store Vehicle",
    icon = "fas fa-warehouse",
    name = "store_vehicle",
    serverEvent = "garage:storeVehicle",
    distance = 5.0
})
```

### With shouldClose

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 3.0,
    shouldClose = true,  -- Closes menu and deactivates targeting
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

---

## Important Notes

- The option will appear for **all** vehicles in the game
- Use `canInteract` to conditionally show the option based on vehicle state or player permissions
- Use `removeGlobalVehicle(id)` to manually remove the option
- Multiple global vehicle options can be registered simultaneously

