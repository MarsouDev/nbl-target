# nbl-target

A modern targeting system for FiveM. Point at entities, see context menus, interact.

## Features

- **Entity Targeting**: Vehicles, peds, players, objects, self, ground, sky
- **Model Targeting**: Target specific prop models (ATMs, vending machines, custom props)
- **Bone Targeting**: Target specific vehicle parts (doors, trunk, hood, wheels, engine)
- **Custom Data**: Pass any extra keys to your callbacks via the `data` table
- **Framework Support**: Built-in ESX/QBCore job, gang, group and item conditions
- **Submenus**: Nested options with smart depth handling
- **Checkboxes**: Toggle options with stored or dynamic state
- **Visual Feedback**: Outlines and markers on targeted entities

## Installation

1. Drop `nbl-target` into your resources folder
2. Add `ensure nbl-target` to your server.cfg
3. Configure `config/config.lua` to your liking

## Quick Start

```lua
-- Target any vehicle
exports['nbl-target']:addGlobalVehicle({
    label = 'Lock/Unlock',
    icon = 'fas fa-lock',
    onSelect = function(data)
        print('Entity:', data.entity)
        print('Coords:', data.coords)
    end
})
```

## Examples

### Target Vehicles

```lua
exports['nbl-target']:addGlobalVehicle({
    label = 'Repair',
    icon = 'fas fa-wrench',
    distance = 3.0,
    
    canInteract = function(data)
        -- data.entity, data.distance, data.coords, data.bone, data.name
        return GetVehicleEngineHealth(data.entity) < 1000
    end,
    
    onSelect = function(data)
        SetVehicleFixed(data.entity)
    end
})
```

### Target Peds

```lua
exports['nbl-target']:addGlobalPed({
    label = 'Talk',
    icon = 'fas fa-comment',
    distance = 2.0,
    onSelect = function(data)
        print('Talking to:', data.entity)
    end
})
```

### Target Players

```lua
exports['nbl-target']:addGlobalPlayer({
    label = 'Give Money',
    icon = 'fas fa-money-bill',
    onSelect = function(data)
        local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
        TriggerServerEvent('givemoney', serverId, 100)
    end
})
```

### Target Objects

```lua
exports['nbl-target']:addGlobalObject({
    label = 'Pickup',
    icon = 'fas fa-box',
    distance = 2.0,
    onSelect = function(data)
        print('Picked up object:', data.entity)
    end
})
```

### Target Yourself

```lua
exports['nbl-target']:addGlobalSelf({
    label = 'Open Inventory',
    icon = 'fas fa-backpack',
    onSelect = function(data)
        TriggerEvent('inventory:open')
    end
})
```

### Target Specific Models

```lua
exports['nbl-target']:addModel({'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, {
    label = 'Access ATM',
    icon = 'fas fa-credit-card',
    distance = 1.5,
    onSelect = function(data)
        TriggerEvent('banking:openATM')
    end
})
```

### Target Specific Entity

```lua
local myPed = CreatePed(4, `a_m_y_business_01`, 100.0, 200.0, 30.0, 0.0, false, true)

exports['nbl-target']:addLocalEntity(myPed, {
    label = 'Talk to Bob',
    icon = 'fas fa-user',
    onSelect = function(data)
        print('Hello from Bob!')
    end
})
```

## Custom Data

Pass any extra keys in your options. They're available in callbacks via the `data` parameter:

```lua
exports['nbl-target']:addModel('prop_vend_snak_01', {
    label = 'Buy Snack',
    icon = 'fas fa-cookie',
    
    -- Custom keys
    itemName = 'snack',
    itemPrice = 50,
    shopId = 'vending_01',
    metadata = { category = 'food' },
    
    onSelect = function(data)
        print(data.itemName)              -- "snack"
        print(data.itemPrice)             -- 50
        print(data.shopId)                -- "vending_01"
        print(data.metadata.category)     -- "food"
        print(data.entity)                -- entity handle
        print(data.distance)              -- distance to entity
    end
})
```

## Bone Targeting

Target specific vehicle parts using bone names:

```lua
-- Only shows when aiming at trunk
exports['nbl-target']:addGlobalVehicle({
    label = 'Open Trunk',
    icon = 'fas fa-box-open',
    bones = {'boot'},
    
    onSelect = function(data)
        print('Bone targeted:', data.bone)  -- "boot"
        SetVehicleDoorOpen(data.entity, 5, false, false)
    end
})

-- Only shows when aiming at doors
exports['nbl-target']:addGlobalVehicle({
    label = 'Open Door',
    icon = 'fas fa-door-open',
    bones = {'door_dside_f', 'door_pside_f', 'door_dside_r', 'door_pside_r'},
    
    onSelect = function(data)
        print('Door bone:', data.bone)
    end
})

-- Only shows when aiming at hood/engine
exports['nbl-target']:addGlobalVehicle({
    label = 'Check Engine',
    icon = 'fas fa-car-battery',
    bones = {'bonnet', 'engine'},
    
    onSelect = function(data)
        local health = GetVehicleEngineHealth(data.entity)
        print('Engine health:', health)
    end
})
```

Available bones are configured in `config.lua` under `Config.VehicleBones`.

## Submenus

Create nested options:

```lua
exports['nbl-target']:addGlobalVehicle({
    label = 'Vehicle Options',
    icon = 'fas fa-car',
    
    items = {
        {
            label = 'Doors',
            icon = 'fas fa-door-open',
            items = {
                {
                    label = 'Lock',
                    icon = 'fas fa-lock',
                    onSelect = function(data)
                        SetVehicleDoorsLocked(data.entity, 2)
                    end
                },
                {
                    label = 'Unlock',
                    icon = 'fas fa-unlock',
                    onSelect = function(data)
                        SetVehicleDoorsLocked(data.entity, 0)
                    end
                }
            }
        },
        {
            label = 'Engine On',
            icon = 'fas fa-power-off',
            onSelect = function(data)
                SetVehicleEngineOn(data.entity, true, true, false)
            end
        }
    }
})
```

## Checkboxes

Toggle options with state:

```lua
local engineRunning = false

exports['nbl-target']:addGlobalVehicle({
    label = 'Engine Running',
    icon = 'fas fa-power-off',
    checkbox = true,
    checked = function() return engineRunning end,
    
    onCheck = function(data)
        -- data.checked contains the new state
        engineRunning = data.checked
        SetVehicleEngineOn(data.entity, data.checked, true, false)
    end
})
```

## Framework Conditions

Built-in support for ESX/QBCore job, gang, group, and item checks:

```lua
-- Single job
exports['nbl-target']:addGlobalVehicle({
    label = 'Impound',
    icon = 'fas fa-truck',
    job = 'police',
    onSelect = function(data) end
})

-- Multiple jobs
exports['nbl-target']:addGlobalVehicle({
    label = 'Impound',
    icon = 'fas fa-truck',
    job = {'police', 'sheriff'},
    onSelect = function(data) end
})

-- Job with minimum grade
exports['nbl-target']:addGlobalVehicle({
    label = 'Impound',
    icon = 'fas fa-truck',
    job = { police = 2 },  -- Grade 2+
    onSelect = function(data) end
})

-- Gang (QBCore)
exports['nbl-target']:addGlobalPed({
    label = 'Gang Stuff',
    icon = 'fas fa-skull',
    gang = 'ballas',
    onSelect = function(data) end
})

-- Items required
exports['nbl-target']:addModel('prop_toolchest_05', {
    label = 'Repair',
    icon = 'fas fa-wrench',
    items = {'toolkit'},
    onSelect = function(data) end
})
```

## Events

Trigger events instead of callbacks:

```lua
-- Client event
exports['nbl-target']:addGlobalPed({
    label = 'Open Shop',
    icon = 'fas fa-store',
    event = 'myresource:openShop',
    shopId = 'general_01'
})

AddEventHandler('myresource:openShop', function(data)
    print(data.shopId)    -- "general_01"
    print(data.entity)    -- entity handle
end)

-- Server event
exports['nbl-target']:addGlobalObject({
    label = 'Pickup',
    icon = 'fas fa-hand-grab',
    serverEvent = 'myresource:server:pickup',
    itemId = 'loot_123'
})
```

## Exports

Call another resource's export:

```lua
exports['nbl-target']:addModel('prop_vend_water_01', {
    label = 'Buy Water',
    icon = 'fas fa-bottle-water',
    export = 'ox_inventory.openNearbyInventory'
})
```

## Handler Methods
All registration exports (`addEntity`, `addModel`, `addGlobalVehicle`, etc.) return a **handler** object.

- **Update**: `setLabel`, `setIcon`, `setDistance`, `setEnabled`, `setCanInteract`, `setOnSelect`, `setChecked`, `set`
- **Read**: `get`, `getData`, `getId`
- **Remove**: `remove`

See the dedicated [Handler Methods documentation](docs/exports/HandlerMethods.md) for the full reference and examples.

## Remove Options

```lua
-- Remove by handler
local handler = exports['nbl-target']:addGlobalVehicle({...})
handler:remove()

-- Remove by ID
exports['nbl-target']:remove(id)

-- Remove by name
exports['nbl-target']:removeByName('my_option_name')

-- Remove all from a resource
exports['nbl-target']:removeByResource('myresource')
```

## State Exports

```lua
-- Check if targeting is active
local active = exports['nbl-target']:isActive()

-- Check if menu is open
local menuOpen = exports['nbl-target']:isMenuOpen()

-- Get current target info
local target = exports['nbl-target']:getCurrentTarget()
if target then
    print(target.entity)
    print(target.entityType)
    print(target.worldPos)
    print(target.bone)
end

-- Get selected entity
local entity = exports['nbl-target']:getSelectedEntity()

-- Close menu
exports['nbl-target']:closeMenu()

-- Enable/disable
exports['nbl-target']:disable()
exports['nbl-target']:enable()
local enabled = exports['nbl-target']:isEnabled()

-- Deactivate completely
exports['nbl-target']:deactivate()
```

## Complete Example

See `example.lua` for comprehensive examples covering all features.

## Configuration

Edit `config/config.lua` to customize:

- **Controls**: Activation key, select key
- **Targeting**: Max distance, raycast flags, self-targeting
- **Vehicle Bones**: Which bones can be targeted and their detection radius
- **Outline**: Colors, enabled entity types
- **Marker**: Type, color, scale, animations
- **Menu**: Scale, animation duration, refresh interval
- **Map Objects**: Static props that should be targetable

## API Reference

### Registration

| Export | Description |
|--------|-------------|
| `addGlobalVehicle(options)` | Target any vehicle |
| `addGlobalPed(options)` | Target any ped |
| `addGlobalPlayer(options)` | Target any player |
| `addGlobalSelf(options)` | Target yourself |
| `addGlobalObject(options)` | Target any object |
| `addGlobalSky(options)` | Target sky/world position (no entity) |
| `addGlobalGround(options)` | Target ground/world position (no entity) |
| `addGlobalOption(entityType, options)` | Target a custom global entity type (`"vehicle"`, `"ped"`, `"player"`, `"object"`, `"self"`, `"sky"`, `"ground"`, etc.) |
| `addModel(models, options)` | Target specific model(s) |
| `addBone(bones, options)` | Target specific bone(s) |
| `addEntity(entity, options)` | Target networked entity |
| `addLocalEntity(entity, options)` | Target local entity |

### Removal

| Export | Description |
|--------|-------------|
| `remove(handlerOrId)` | Generic remove by handler or ID |
| `removeEntity(id)` | Remove an entity registration |
| `removeLocalEntity(id)` | Remove a local entity registration |
| `removeModel(id)` | Remove a model registration |
| `removeBone(id)` | Remove a bone registration |
| `removeGlobalVehicle(id)` | Remove a global vehicle option |
| `removeGlobalPed(id)` | Remove a global ped option |
| `removeGlobalPlayer(id)` | Remove a global player option |
| `removeGlobalSelf(id)` | Remove a global self option |
| `removeGlobalObject(id)` | Remove a global object option |
| `removeGlobalSky(id)` | Remove a global sky option |
| `removeGlobalGround(id)` | Remove a global ground option |
| `removeGlobalOption(id)` | Remove a generic global option |
| `removeByName(name)` | Remove by option name |
| `removeByResource(resourceName)` | Remove all from a resource |

### State

| Export | Description |
|--------|-------------|
| `isActive()` | Is targeting mode active |
| `isMenuOpen()` | Is context menu open |
| `isEnabled()` | Is targeting enabled |
| `getCurrentTarget()` | Get current target info |
| `getSelectedEntity()` | Get entity of open menu |

### Control

| Export | Description |
|--------|-------------|
| `enable()` | Enable targeting |
| `disable()` | Disable targeting |
| `closeMenu()` | Close context menu |
| `deactivate()` | Deactivate targeting mode |

## License

See LICENSE file.
