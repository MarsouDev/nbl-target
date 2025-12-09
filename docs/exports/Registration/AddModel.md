# AddModel

Register a context menu option for one or multiple models.

---

## Description

Adds a context menu option that will appear for all entities matching a specific model hash. This is useful for objects like ATMs, doors, or any prop that appears multiple times in the world.

**Now supports arrays!** You can pass a single model or an array of models to register the same option for multiple props at once.

---

## Syntax

```lua
local target = exports['nbl-target']:addModel(models, options)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `models` | `number` / `string` / `table` | Yes | Model hash, model name, or array of models |
| `options` | `table` | Yes | Configuration table for the option |

### Models Parameter Types

```lua
-- Single model (hash)
exports['nbl-target']:addModel(GetHashKey('prop_atm_01'), options)

-- Single model (string - auto-converted to hash)
exports['nbl-target']:addModel('prop_atm_01', options)

-- Multiple models (array)
exports['nbl-target']:addModel({'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, options)

-- Mixed array (strings and hashes)
exports['nbl-target']:addModel({'prop_atm_01', GetHashKey('prop_atm_02')}, options)
```

### Options Table

See [AddEntity](./AddEntity.md) for the complete options table structure.

---

## Return

| Type | Description |
|------|-------------|
| `handler` | A handler object with methods to control the registration |
| `nil` | If no valid models provided |

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

### Single Model

```lua
local target = exports['nbl-target']:addModel('prop_atm_01', {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM', entity)
    end
})
```

### Multiple Models (Array)

```lua
-- Register for ALL ATM models at once
local target = exports['nbl-target']:addModel({
    'prop_atm_01',
    'prop_atm_02', 
    'prop_atm_03',
    'prop_fleeca_atm'
}, {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM', entity)
    end
})
```

### Using Handler Methods

```lua
local target = exports['nbl-target']:addModel('prop_atm_01', {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    distance = 2.0
})

-- Later, dynamically change the label
target:setLabel("ATM - Withdraw Cash")

-- Chain multiple changes
target:setLabel("Bank ATM"):setIcon("fas fa-university"):setDistance(3.0)

-- Temporarily disable
target:setEnabled(false)

-- Remove when done
target:remove()
```

### Door Model with canInteract

```lua
local target = exports['nbl-target']:addModel('prop_door_01', {
    label = "Open Door",
    icon = "fas fa-door-open",
    name = "open_door",
    distance = 2.0,
    canInteract = function(entity, distance, worldPos)
        return exports['keys']:hasKey(entity) and distance <= 2.0
    end,
    onSelect = function(entity, coords)
        TriggerEvent('doors:toggle', entity)
    end
})
```

### Vending Machines

```lua
local target = exports['nbl-target']:addModel({
    'prop_vend_soda_01',
    'prop_vend_soda_02',
    'prop_vend_water_01',
    'prop_vend_coffe_01'
}, {
    label = "Buy Drink",
    icon = "fas fa-bottle-water",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('shop:buyDrink')
    end
})
```

---

## Important Notes

- The option will appear for **all** entities with matching models in the world
- Model names are automatically converted to hash keys if provided as strings
- Arrays allow registering for multiple models with a single call
- Use `handler:remove()` or `removeModel(handler)` to remove all registrations
- More efficient than registering individual entities when you have many of the same type
- Handler methods are chainable (except `:remove()` and `:getId()`)

