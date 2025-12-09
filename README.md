# NBL Target

A modern, feature-rich context menu and targeting system for FiveM. Built with performance, flexibility, and ease of use in mind.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Complete API Reference](#complete-api-reference)
- [Handler Methods](#handler-methods)
- [Usage Examples](#usage-examples)
- [Advanced Features](#advanced-features)
- [Performance Optimizations](#performance-optimizations)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

NBL Target is a comprehensive targeting system that allows players to interact with entities (vehicles, peds, objects, players) through a modern context menu interface. Hold the activation key (default: Left Alt) to enter targeting mode, then click on any entity to open a context menu with available interaction options.

### How It Works

1. **Activation**: Player holds the activation key (Left Alt by default)
2. **Targeting**: System performs raycast to detect entities under the cursor
3. **Visual Feedback**: Entities with available options show outline and 3D marker
4. **Selection**: Player clicks on entity to open context menu
5. **Interaction**: Player selects an option from the menu
6. **Action**: System executes the registered action (callback, export, event, etc.)

---

## ✨ Features

- 🎯 **Advanced Targeting System**: Precise entity detection with raycast (vehicles, peds, objects, ground, sky, self)
- 🖱️ **Visual Feedback**: Outline and 3D markers on hover for clear entity indication
- 🎨 **Dynamic Cursor**: Cursor changes based on entity state (has options or not)
- 📦 **Flexible Registration**: Register options for specific entities, models, or global types
- 🔄 **Array Support**: Register for multiple entities or models with a single call
- 🎨 **Modern NUI Menu**: Beautiful dark-themed context menu with smooth animations
- 📋 **Sub-menus**: Nested options with hover support and conditional display
- ⚡ **Real-time Updates**: Auto-refresh options based on `canInteract` conditions
- 🔧 **Multiple Actions**: Support for exports, events, serverEvents, commands, and callbacks
- 🛡️ **Error Handling**: Complete protection against crashes with `pcall` wrappers
- ⚡ **Optimized Performance**: 0ms CPU when inactive, efficient resource usage
- 🔄 **Auto-cleanup**: Automatic removal of options when resources stop
- 🎛️ **Handler Methods**: Dynamic control of registered options (change label, icon, enable/disable, etc.)
- 🔗 **Method Chaining**: Chain multiple handler methods for cleaner code

---

## 🚀 Installation

1. **Download the Resource**: Obtain the `nbl-target` resource files
2. **Place in Resources Folder**: Drag and drop the `nbl-target` folder into your server's `resources` directory
   ```
   server-data/resources/[your-category]/nbl-target/
   ```
3. **Add to server.cfg**: Open your `server.cfg` file and add:
   ```cfg
   ensure nbl-target
   ```
4. **Restart Server**: Restart your FiveM server to load the resource

**Note**: Ensure your server is running on `fx_version 'cerulean'` or newer.

---

## Quick Start

### Basic Example

```lua
-- Register an option for all vehicles
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    onSelect = function(entity, coords, registration)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### With Conditional Display

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock",
    name = "lock_vehicle",
    distance = 3.0,
    canInteract = function(entity, distance, worldPos, name, bone)
        -- Only show if player owns the vehicle
        return exports['vehicles']:isOwner(entity) and distance <= 3.0
    end,
    onSelect = function(entity, coords)
        exports['vehicles']:toggleLock(entity)
    end
})
```

---

## ⚙️ Configuration

All configuration is in `config/config.lua`. Here are the main sections:

### Controls

```lua
Config.Controls = {
    activationKey = 'LMENU',  -- Key to activate (Left Alt)
    selectKey = 24            -- Mouse button to select (24 = Left Click)
}
```

**Common Activation Keys:**
- `'LMENU'` - Left Alt (default)
- `'LCONTROL'` - Left Ctrl
- `'LSHIFT'` - Left Shift
- `'LALT'` - Left Alt (alternative)

**Select Keys:**
- `24` - Left Click (default)
- `25` - Right Click

### Targeting

```lua
Config.Target = {
    maxDistance = 10.0,           -- Maximum raycast distance (meters)
    raycastFlags = -1,            -- Raycast flags (-1 = all types)
    allowSelfTarget = true,       -- Allow targeting yourself
    defaultDistance = 3.0         -- Default interaction distance (meters)
}
```

**Raycast Flags:**
- `-1` - All entity types (default)
- `1` - World/terrain
- `2` - Vehicles
- `4` - Peds
- `8` - Objects
- `16` - Water
- `32` - Foliage

### Outline (Entity Highlight)

```lua
Config.Outline = {
    enabled = true,
    color = {r = 255, g = 255, b = 0, a = 255},  -- Yellow outline (RGBA)
    allowedTypes = {
        vehicle = true,
        object = true,
        ped = true,
        player = true,
        self = true
    }
}
```

### Marker (3D Marker Above Entity)

```lua
Config.Marker = {
    enabled = true,
    type = 2,                    -- Marker type (2 = Arrow down)
    color = {r = 255, g = 255, b = 0, a = 200},  -- Yellow marker (RGBA)
    scale = 0.3,                 -- Marker scale
    height = 1.0,                -- Height above entity (meters)
    rotate = true,               -- Rotate animation
    bob = true                   -- Bobbing animation
}
```

**Common Marker Types:**
- `1` - Cylinder
- `2` - Arrow down (default)
- `25` - Horizontal circle
- `27` - Arrow

### Menu (NUI Context Menu)

```lua
Config.Menu = {
    scale = 1.0,                 -- Menu scale (1.0 = 100%)
    maxVisibleOptions = 8,       -- Max options before scroll
    subMenuDelay = 150,          -- Delay before showing submenu (ms)
    animationDuration = 150,     -- Animation duration (ms)
    closeOnKeyRelease = true,    -- Close menu when releasing activation key
    refreshInterval = 500        -- Auto-refresh interval (ms, 0 = disabled)
}
```

**Refresh Interval:**
- `0` - Disable auto-refresh
- `500` - Refresh every 500ms (default)
- Higher values = less frequent updates (better performance)
- Lower values = more frequent updates (better responsiveness)

---

## Complete API Reference

### State Exports

These exports allow you to check the current state of the targeting system.

#### `isActive()`

Check if targeting mode is currently active.

**Syntax:**
```lua
local active = exports['nbl-target']:isActive()
```

**Returns:**
- `boolean` - `true` if targeting mode is active, `false` otherwise

**Example:**
```lua
if exports['nbl-target']:isActive() then
    print("Player is in targeting mode")
end
```

#### `isMenuOpen()`

Check if the context menu is currently open.

**Syntax:**
```lua
local isOpen = exports['nbl-target']:isMenuOpen()
```

**Returns:**
- `boolean` - `true` if menu is open, `false` otherwise

**Example:**
```lua
if exports['nbl-target']:isMenuOpen() then
    print("Context menu is open")
end
```

#### `isEnabled()`

Check if the registry system is enabled.

**Syntax:**
```lua
local enabled = exports['nbl-target']:isEnabled()
```

**Returns:**
- `boolean` - `true` if registry is enabled, `false` otherwise

**Example:**
```lua
if not exports['nbl-target']:isEnabled() then
    print("Registry is disabled")
end
```

#### `getCurrentTarget()`

Get information about the currently hovered or selected entity.

**Syntax:**
```lua
local target = exports['nbl-target']:getCurrentTarget()
```

**Returns:**
- `table` or `nil` - Target information table or `nil` if no target

**Return Table Structure:**
```lua
{
    entity = number,        -- Entity handle
    entityType = string,    -- Entity type: "vehicle", "ped", "player", "object", "self"
    worldPos = vector3      -- World position of the entity
}
```

**Example:**
```lua
local target = exports['nbl-target']:getCurrentTarget()
if target then
    print("Targeting: " .. target.entityType)
    print("Entity: " .. target.entity)
end
```

#### `getSelectedEntity()`

Get the entity handle of the currently selected entity (when menu is open).

**Syntax:**
```lua
local entity = exports['nbl-target']:getSelectedEntity()
```

**Returns:**
- `number` or `nil` - Entity handle or `nil` if no entity selected

**Example:**
```lua
if exports['nbl-target']:isMenuOpen() then
    local entity = exports['nbl-target']:getSelectedEntity()
    if entity then
        print("Selected entity: " .. entity)
    end
end
```

---

### Control Exports

These exports allow you to control the targeting system behavior.

#### `enable()`

Enable the registry system.

**Syntax:**
```lua
exports['nbl-target']:enable()
```

**Returns:** None

**Example:**
```lua
exports['nbl-target']:enable()
```

#### `disable()`

Disable the registry system.

**Syntax:**
```lua
exports['nbl-target']:disable()
```

**Returns:** None

**Example:**
```lua
exports['nbl-target']:disable()
```

#### `deactivate()`

Deactivate the targeting mode (equivalent to releasing the activation key).

**Syntax:**
```lua
exports['nbl-target']:deactivate()
```

**Returns:** None

**Example:**
```lua
exports['nbl-target']:deactivate()
```

#### `closeMenu()`

Manually close the context menu.

**Syntax:**
```lua
exports['nbl-target']:closeMenu()
```

**Returns:** None

**Note:** This does NOT deactivate targeting mode. Use `deactivate()` for that.

**Example:**
```lua
exports['nbl-target']:closeMenu()
```

---

### Registration Exports

All registration exports return a **handler object** with methods to dynamically control the option. See [Handler Methods](#handler-methods) section for details.

#### `addEntity(entities, options)`

Register an option for a specific entity or array of entities.

**Syntax:**
```lua
local target = exports['nbl-target']:addEntity(entities, options)
```

**Parameters:**
- `entities` (number or table) - Entity handle or array of entity handles
- `options` (table) - Configuration table (see [Option Parameters](#option-parameters))

**Returns:**
- `handler` - Handler object with methods
- `nil` - If no valid entities provided

**Example - Single Entity:**
```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local target = exports['nbl-target']:addEntity(vehicle, {
    label = "Open Trunk",
    icon = "fas fa-box",
    distance = 3.0,
    onSelect = function(entity, coords)
        print("Trunk opened!")
    end
})
```

**Example - Multiple Entities:**
```lua
local vehicles = {vehicle1, vehicle2, vehicle3}
local target = exports['nbl-target']:addEntity(vehicles, {
    label = "Inspect",
    icon = "fas fa-search",
    distance = 3.0
})
```

#### `addLocalEntity(entities, options)`

Register an option for a local entity or array of entities (client-side only, not synced).

**Syntax:**
```lua
local target = exports['nbl-target']:addLocalEntity(entities, options)
```

**Parameters:**
- `entities` (number or table) - Entity handle or array of entity handles
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods
- `nil` - If no valid entities provided

**Example:**
```lua
local object = CreateObject(GetHashKey('prop_atm_01'), x, y, z, false, false, false)
local target = exports['nbl-target']:addLocalEntity(object, {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    distance = 2.0
})
```

#### `addModel(models, options)`

Register an option for one or multiple models.

**Syntax:**
```lua
local target = exports['nbl-target']:addModel(models, options)
```

**Parameters:**
- `models` (number, string, or table) - Model hash, model name, or array of models
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods
- `nil` - If no valid models provided

**Model Parameter Types:**
```lua
-- Single model (hash)
addModel(GetHashKey('prop_atm_01'), options)

-- Single model (string - auto-converted to hash)
addModel('prop_atm_01', options)

-- Multiple models (array)
addModel({'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, options)

-- Mixed array (strings and hashes)
addModel({'prop_atm_01', GetHashKey('prop_atm_02')}, options)
```

**Example - Single Model:**
```lua
local target = exports['nbl-target']:addModel('prop_atm_01', {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM', entity)
    end
})
```

**Example - Multiple Models:**
```lua
local target = exports['nbl-target']:addModel({
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm'
}, {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM', entity)
    end
})
```

#### `addGlobalVehicle(options)`

Register an option for all vehicles.

**Syntax:**
```lua
local target = exports['nbl-target']:addGlobalVehicle(options)
```

**Parameters:**
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods

**Example:**
```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    canInteract = function(entity, distance, worldPos, name, bone)
        return not IsVehicleLocked(entity) and distance <= 3.0
    end,
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

#### `addGlobalPed(options)`

Register an option for all NPCs (peds).

**Syntax:**
```lua
local target = exports['nbl-target']:addGlobalPed(options)
```

**Parameters:**
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods

**Example:**
```lua
local target = exports['nbl-target']:addGlobalPed({
    label = "Talk",
    icon = "fas fa-comments",
    name = "talk_npc",
    distance = 2.0,
    canInteract = function(entity, distance)
        return not IsPedInAnyVehicle(entity, false) and distance <= 2.0
    end,
    onSelect = function(entity, coords)
        TriggerEvent('dialogue:start', entity)
    end
})
```

#### `addGlobalPlayer(options)`

Register an option for all players.

**Syntax:**
```lua
local target = exports['nbl-target']:addGlobalPlayer(options)
```

**Parameters:**
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods

**Example:**
```lua
local target = exports['nbl-target']:addGlobalPlayer({
    label = "Search Player",
    icon = "fas fa-search",
    name = "search_player",
    distance = 2.0,
    canInteract = function(entity, distance)
        return exports['police']:isPolice() and distance <= 1.5
    end,
    onSelect = function(entity, coords)
        TriggerServerEvent('police:searchPlayer', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

#### `addGlobalSelf(options)`

Register an option for yourself (the player).

**Syntax:**
```lua
local target = exports['nbl-target']:addGlobalSelf(options)
```

**Parameters:**
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods

**Example:**
```lua
local target = exports['nbl-target']:addGlobalSelf({
    label = "Check Health",
    icon = "fas fa-heart",
    name = "self_health",
    distance = 5.0,
    onSelect = function(entity, coords)
        local health = GetEntityHealth(entity)
        local armor = GetPedArmour(entity)
        print("Health: " .. health .. " | Armor: " .. armor)
    end
})
```

#### `addGlobalObject(options)`

Register an option for all objects.

**Syntax:**
```lua
local target = exports['nbl-target']:addGlobalObject(options)
```

**Parameters:**
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods

**Example:**
```lua
local target = exports['nbl-target']:addGlobalObject({
    label = "Pick Up",
    icon = "fas fa-hand-paper",
    name = "pickup_object",
    distance = 2.0,
    canInteract = function(entity, distance)
        local model = GetEntityModel(entity)
        return exports['inventory']:canCarryItem(model, 1) and distance <= 1.5
    end,
    onSelect = function(entity, coords)
        TriggerServerEvent('items:pickup', NetworkGetNetworkIdFromEntity(entity))
    end
})
```

#### `addGlobalOption(entityType, options)`

Register an option for a custom entity type.

**Syntax:**
```lua
local target = exports['nbl-target']:addGlobalOption(entityType, options)
```

**Parameters:**
- `entityType` (string) - Custom entity type name
- `options` (table) - Configuration table

**Returns:**
- `handler` - Handler object with methods

**Valid Entity Types:**
- `"vehicle"` - All vehicles
- `"ped"` - All NPCs
- `"player"` - All players
- `"object"` - All objects
- `"self"` - The player themselves
- Custom types (if supported by your entity detection system)

**Example:**
```lua
local target = exports['nbl-target']:addGlobalOption('vehicle', {
    label = "Custom Action",
    icon = "fas fa-star",
    distance = 3.0
})
```

---

### Removal Exports

These exports allow you to remove previously registered options.

#### `remove(handlerOrId)`

Generic remove function that works with handler objects or registration IDs.

**Syntax:**
```lua
local success = exports['nbl-target']:remove(handlerOrId)
```

**Parameters:**
- `handlerOrId` (handler or number) - Handler object or registration ID

**Returns:**
- `boolean` - `true` if removed successfully, `false` otherwise

**Example:**
```lua
local target = exports['nbl-target']:addGlobalVehicle({...})
exports['nbl-target']:remove(target)  -- Using handler
-- OR
exports['nbl-target']:remove(123)    -- Using ID
```

#### `removeEntity(handler)`

Remove an option registered for a specific entity.

**Syntax:**
```lua
local success = exports['nbl-target']:removeEntity(handler)
```

**Parameters:**
- `handler` (handler or number) - Handler object or registration ID

**Returns:**
- `boolean` - `true` if removed successfully, `false` otherwise

#### `removeLocalEntity(handler)`

Remove an option registered for a local entity.

**Syntax:**
```lua
local success = exports['nbl-target']:removeLocalEntity(handler)
```

#### `removeModel(handler)`

Remove an option registered for a model.

**Syntax:**
```lua
local success = exports['nbl-target']:removeModel(handler)
```

#### `removeGlobalVehicle(handler)`

Remove a global vehicle option.

**Syntax:**
```lua
local success = exports['nbl-target']:removeGlobalVehicle(handler)
```

#### `removeGlobalPed(handler)`

Remove a global ped option.

**Syntax:**
```lua
local success = exports['nbl-target']:removeGlobalPed(handler)
```

#### `removeGlobalPlayer(handler)`

Remove a global player option.

**Syntax:**
```lua
local success = exports['nbl-target']:removeGlobalPlayer(handler)
```

#### `removeGlobalSelf(handler)`

Remove a global self option.

**Syntax:**
```lua
local success = exports['nbl-target']:removeGlobalSelf(handler)
```

#### `removeGlobalObject(handler)`

Remove a global object option.

**Syntax:**
```lua
local success = exports['nbl-target']:removeGlobalObject(handler)
```

#### `removeGlobalOption(handler)`

Remove a global option by entity type.

**Syntax:**
```lua
local success = exports['nbl-target']:removeGlobalOption(handler)
```

#### `removeByName(name)`

Remove an option by its name identifier.

**Syntax:**
```lua
local success = exports['nbl-target']:removeByName(name)
```

**Parameters:**
- `name` (string) - The `name` identifier used when registering the option

**Returns:**
- `boolean` - `true` if removed successfully, `false` otherwise

**Example:**
```lua
exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    name = "enter_vehicle"  -- Important: set a name
})

-- Later, remove by name
exports['nbl-target']:removeByName("enter_vehicle")
```

#### `removeByResource(resourceName)`

Remove all options registered by a specific resource.

**Syntax:**
```lua
local count = exports['nbl-target']:removeByResource(resourceName)
```

**Parameters:**
- `resourceName` (string) - The resource name

**Returns:**
- `number` - Number of options removed

**Example:**
```lua
local count = exports['nbl-target']:removeByResource('myresource')
print("Removed " .. count .. " options")
```

**Note:** This is automatically called when a resource stops, so manual cleanup is usually not needed.

---

## Handler Methods

All registration exports return a **handler object** with methods to dynamically control the registered option. This allows you to update properties, enable/disable, or remove the option without needing to store the registration ID.

### Available Methods

#### `:setLabel(label)`

Change the option label dynamically.

**Parameters:**
- `label` (string) - The new label text

**Returns:** `handler` (chainable)

**Example:**
```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock"
})

-- Change label
target:setLabel("Unlock Vehicle")
```

#### `:setIcon(icon)`

Change the option icon.

**Parameters:**
- `icon` (string) - Font Awesome icon class

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setIcon("fas fa-lock-open")
```

#### `:setEnabled(enabled)`

Enable or disable the option.

**Parameters:**
- `enabled` (boolean) - `true` to enable, `false` to disable

**Returns:** `handler` (chainable)

**Example:**
```lua
-- Temporarily disable
target:setEnabled(false)

-- Re-enable
target:setEnabled(true)
```

#### `:setDistance(distance)`

Change the interaction distance.

**Parameters:**
- `distance` (number) - Maximum interaction distance in meters

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setDistance(5.0)
```

#### `:setCanInteract(fn)`

Change the canInteract function.

**Parameters:**
- `fn` (function) - New canInteract function

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setCanInteract(function(entity, distance, worldPos, name, bone)
    return distance <= 2.0 and not IsVehicleLocked(entity)
end)
```

#### `:setOnSelect(fn)`

Change the onSelect callback.

**Parameters:**
- `fn` (function) - New onSelect callback

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setOnSelect(function(entity, coords, registration)
    print("New callback!")
end)
```

#### `:remove()`

Remove the registration(s).

**Returns:** `boolean` - `true` if removed successfully

**Example:**
```lua
target:remove()
```

#### `:getId()`

Get the registration ID(s).

**Returns:**
- `number` - Single ID if one registration
- `table` - Array of IDs if multiple registrations (e.g., from array input)

**Example:**
```lua
local id = target:getId()
print("Registration ID: " .. id)
```

### Method Chaining

All methods except `:remove()` and `:getId()` return the handler object, allowing you to chain multiple calls:

```lua
target:setLabel("New Label")
    :setIcon("fas fa-star")
    :setDistance(5.0)
    :setEnabled(true)
```

---

## Option Parameters

When registering an option, you provide a configuration table with the following parameters:

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| `label` | `string` | Yes | Display text shown in the menu | - |
| `name` | `string` | No | Unique identifier for the option (used with `removeByName`) | - |
| `icon` | `string` | No | Font Awesome icon class | `"fas fa-hand-pointer"` |
| `distance` | `number` | No | Maximum interaction distance in meters | `3.0` |
| `canInteract` | `function` | No | Function that returns `true`/`false` to show/hide the option | Always `true` |
| `onSelect` | `function` | No | Callback function when option is selected | - |
| `export` | `string` | No | Export to call (format: `"resource.export"`) | - |
| `event` | `string` | No | Client event name to trigger | - |
| `serverEvent` | `string` | No | Server event name to trigger | - |
| `command` | `string` | No | Command to execute | - |
| `items` | `table` | No | Sub-menu items table | - |
| `shouldClose` | `boolean` | No | Close menu and deactivate targeting | `false` |
| `enabled` | `boolean` | No | Enable/disable the option | `true` |

### Action Priority

If multiple action types are specified, they are executed in this order:
1. `export` - Calls an export from another resource
2. `event` - Triggers a client event
3. `serverEvent` - Triggers a server event
4. `command` - Executes a command
5. `onSelect` - Calls the callback function

Only the first matching action type is executed.

### Callback Parameters

#### `canInteract` Callback

Called to determine if the option should be shown.

**Parameters:**
- `entity` (number) - Entity handle
- `distance` (number) - Distance from player to entity
- `worldPos` (vector3) - World position of the entity
- `name` (string) - Option name identifier
- `bone` (number or nil) - Bone index if applicable

**Returns:**
- `boolean` - `true` to show the option, `false` to hide it

**Example:**
```lua
canInteract = function(entity, distance, worldPos, name, bone)
    -- Only show if player is police and within 2 meters
    return exports['police']:isPolice() and distance <= 2.0
end
```

#### `onSelect` Callback

Called when the option is selected.

**Parameters:**
- `entity` (number) - Entity handle
- `coords` (vector3) - World position of the entity
- `registration` (table) - The registration table (contains all option data)

**Returns:** None

**Example:**
```lua
onSelect = function(entity, coords, registration)
    print("Selected entity: " .. entity)
    print("Option name: " .. registration.name)
end
```

### Sub-menu Items

The `items` parameter allows you to create nested sub-menus:

```lua
items = {
    {
        id = 1,                    -- Required: Unique ID for the sub-item
        label = "Sub Option 1",     -- Required: Display text
        icon = "fas fa-star",       -- Optional: Icon
        name = "sub_option_1",      -- Optional: Name identifier
        canInteract = function(entity, distance)  -- Optional: Conditional display
            return distance <= 2.0
        end,
        shouldClose = false         -- Optional: Close menu on select
    },
    {
        id = 2,
        label = "Sub Option 2",
        icon = "fas fa-heart"
    }
}
```

**Sub-item Parameters:**
- `id` (number) - **Required** - Unique identifier for the sub-item
- `label` (string) - **Required** - Display text
- `icon` (string) - Optional - Font Awesome icon class
- `name` (string) - Optional - Name identifier
- `canInteract` (function) - Optional - Conditional display function
- `shouldClose` (boolean) - Optional - Close menu on select

---

## Usage Examples

### Basic Entity Registration

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

local target = exports['nbl-target']:addEntity(vehicle, {
    label = "Open Trunk",
    icon = "fas fa-box",
    name = "open_trunk",
    distance = 3.0,
    onSelect = function(entity, coords, registration)
        print("Trunk opened for vehicle: " .. entity)
    end
})
```

### Multiple Entities (Array Support)

```lua
-- Register for all nearby vehicles at once
local vehicles = GetGamePool('CVehicle')

local target = exports['nbl-target']:addEntity(vehicles, {
    label = "Inspect",
    icon = "fas fa-search",
    distance = 3.0,
    onSelect = function(entity, coords)
        print("Inspecting vehicle: " .. entity)
    end
})
```

### Multiple Models (Array Support)

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
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM', entity)
    end
})
```

### Handler Methods (Dynamic Updates)

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock",
    distance = 3.0
})

-- Later, dynamically change the label
target:setLabel("Unlock Vehicle")

-- Chain multiple changes
target:setLabel("Vehicle Locked"):setIcon("fas fa-lock-open"):setDistance(5.0)

-- Temporarily disable
target:setEnabled(false)

-- Re-enable
target:setEnabled(true)

-- Remove when done
target:remove()
```

### Dynamic Label Updates Based on State

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock"
})

-- Update based on vehicle state
CreateThread(function()
    while true do
        Wait(1000)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            if IsVehicleLocked(vehicle) then
                target:setLabel("Unlock Vehicle"):setIcon("fas fa-lock-open")
            else
                target:setLabel("Lock Vehicle"):setIcon("fas fa-lock")
            end
        end
    end
end)
```

### Conditional Enabling

```lua
local target = exports['nbl-target']:addGlobalPed({
    label = "Search",
    icon = "fas fa-search"
})

-- Only enable for police
RegisterNetEvent('job:update', function(job)
    target:setEnabled(job == 'police')
end)
```

### Global Type with canInteract

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    canInteract = function(entity, distance, worldPos, name, bone)
        -- Only show if vehicle is unlocked and within 3 meters
        return not IsVehicleLocked(entity) and distance <= 3.0
    end,
    onSelect = function(entity, coords, registration)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### Sub-menu with Items

```lua
exports['nbl-target']:addEntity(ped, {
    label = "Give Item",
    icon = "fas fa-gift",
    name = "give_item",
    items = {
        {
            id = 9001,
            label = "Give Money",
            icon = "fas fa-dollar-sign",
            canInteract = function(entity, distance)
                return distance <= 2.0
            end
        },
        {
            id = 9002,
            label = "Give Food",
            icon = "fas fa-utensils"
        },
        {
            id = 9003,
            label = "Give Weapon",
            icon = "fas fa-gun",
            canInteract = function(entity, distance)
                return distance <= 1.0
            end
        }
    },
    onSelect = function(entity, coords, registration)
        print("Giving item!")
    end
})
```

### Using shouldClose

```lua
exports['nbl-target']:addEntity(vehicle, {
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    shouldClose = true,  -- Closes menu AND deactivates targeting
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### Using Exports

```lua
exports['nbl-target']:addGlobalVehicle({
    label = "Repair",
    name = "repair_vehicle",
    export = "mechanic.repair",  -- Calls exports['mechanic']:repair(entity, coords, registration)
    distance = 3.0
})
```

### Using Client Events

```lua
exports['nbl-target']:addGlobalObject({
    label = "Open",
    name = "open_object",
    event = "myresource:openObject",  -- Triggers TriggerEvent('myresource:openObject', entity, coords, registration)
    distance = 2.0
})
```

### Using Server Events

```lua
exports['nbl-target']:addGlobalPed({
    label = "Search",
    name = "search_ped",
    serverEvent = "police:searchPed",  -- Triggers TriggerServerEvent('police:searchPed', entity, coords, registration)
    distance = 1.5
})
```

### Using Commands

```lua
exports['nbl-target']:addGlobalVehicle({
    label = "Repair",
    name = "repair_cmd",
    command = "repair",  -- Executes ExecuteCommand('repair')
    distance = 3.0
})
```

### Self-Targeting

```lua
exports['nbl-target']:addGlobalSelf({
    label = "Check Health",
    icon = "fas fa-heart",
    name = "self_health",
    distance = 5.0,
    onSelect = function(entity, coords)
        local health = GetEntityHealth(entity)
        local armor = GetPedArmour(entity)
        print("Your health: " .. health .. " | Armor: " .. armor)
    end
})
```

### Model-Specific Registration

```lua
exports['nbl-target']:addModel(GetHashKey('prop_atm_01'), {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM')
    end
})
```

### Vending Machines (Multiple Models)

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

### Complex canInteract Logic

```lua
exports['nbl-target']:addGlobalVehicle({
    label = "Repair Vehicle",
    icon = "fas fa-wrench",
    name = "repair_vehicle",
    distance = 5.0,
    canInteract = function(entity, distance, worldPos, name, bone)
        -- Only show if:
        -- 1. Player has repair kit
        -- 2. Vehicle is damaged
        -- 3. Within 3 meters
        -- 4. Player is not in vehicle
        local hasKit = exports['inventory']:hasItem('repair_kit')
        local health = GetVehicleEngineHealth(entity)
        local isInVehicle = GetVehiclePedIsIn(PlayerPedId(), false) == entity
        
        return hasKit and health < 1000.0 and distance <= 3.0 and not isInVehicle
    end,
    onSelect = function(entity, coords)
        exports['inventory']:useItem('repair_kit')
        SetVehicleEngineHealth(entity, 1000.0)
        SetVehicleBodyHealth(entity, 1000.0)
    end
})
```

### Resource Cleanup Example

```lua
-- Register options when resource starts
local vehicleOption = exports['nbl-target']:addGlobalVehicle({...})
local pedOption = exports['nbl-target']:addGlobalPed({...})

-- Cleanup when resource stops (automatic, but you can do it manually)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        vehicleOption:remove()
        pedOption:remove()
        -- OR use removeByResource
        -- exports['nbl-target']:removeByResource(resourceName)
    end
end)
```

---

## Advanced Features

### Real-time Option Updates

The menu automatically refreshes options based on `canInteract` conditions when open. This allows options to appear/disappear dynamically based on game state.

**Configuration:**
```lua
Config.Menu = {
    refreshInterval = 500  -- Refresh every 500ms (0 to disable)
}
```

**How it works:**
- When the menu is open, the system checks `canInteract` functions every `refreshInterval` milliseconds
- If an option's `canInteract` changes from `false` to `true`, it appears in the menu
- If it changes from `true` to `false`, it disappears
- Only options that actually changed are updated (smart refresh)

**Example:**
```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    canInteract = function(entity, distance)
        -- This is checked every 500ms when menu is open
        return not IsVehicleLocked(entity) and distance <= 3.0
    end
})
```

### Resource Auto-cleanup

When a resource stops, all its registered options are automatically removed. This prevents orphaned options and memory leaks.

**How it works:**
- The system tracks which resource registered each option
- When `onResourceStop` is triggered, all options from that resource are removed
- No manual cleanup needed!

**Manual cleanup (if needed):**
```lua
exports['nbl-target']:removeByResource('myresource')
```

### Sub-menu canInteract

Sub-menu items support `canInteract` just like main options:

```lua
items = {
    {
        id = 1,
        label = "Option 1",
        canInteract = function(entity, distance)
            return distance <= 2.0
        end
    }
}
```

### Entity Type Detection

The system automatically detects entity types:
- `vehicle` - All vehicles
- `ped` - NPCs (non-player peds)
- `player` - Other players
- `object` - Objects/props
- `self` - The player themselves
- `ground` - Ground/terrain
- `sky` - Sky/empty space

---

## Performance Optimizations

NBL Target is built with performance in mind. Here are the key optimizations:

### 1. Zero CPU When Inactive

When the activation key is not pressed, the main thread sleeps for 500ms, resulting in **0ms CPU usage**.

```lua
-- Main loop
if State.active then
    Wait(0)  -- Active processing
else
    Wait(500)  -- Sleep when inactive
end
```

### 2. Optimized Raycast

- Camera position is cached to avoid repeated native calls
- Raycast is only performed when targeting mode is active
- Maximum distance is configurable to limit raycast range

### 3. Smart Menu Refresh

- Options are only refreshed if they actually changed
- Comparison function checks IDs, labels, and sub-items
- Prevents unnecessary NUI updates

### 4. Automatic Entity Cleanup

- Invalid entities are automatically removed every 30 seconds
- Prevents memory leaks from deleted entities
- Runs in a separate thread to avoid blocking

### 5. Outline Cleanup

- Dedicated thread ensures outlines are removed when inactive
- Prevents visual glitches
- Automatic cleanup on entity deletion

### 6. Efficient Registry Lookup

- Options are stored in separate tables by type (entities, models, global)
- Fast lookup using entity/model matching
- No unnecessary iterations

### 7. Protected Callbacks

- All callbacks are wrapped in `pcall` to prevent crashes
- Errors are logged but don't break the system
- Graceful degradation on errors

### Performance Tips

1. **Use Model Registration for Multiple Instances**: Instead of registering individual entities, use `addModel()` for props that appear multiple times (ATMs, doors, etc.)

2. **Limit Refresh Interval**: If you don't need real-time updates, increase `Config.Menu.refreshInterval` to reduce CPU usage

3. **Use canInteract Efficiently**: Keep `canInteract` functions simple and fast. Avoid heavy operations inside them.

4. **Disable When Not Needed**: Use `disable()` to turn off the registry system when not needed (cutscenes, menus, etc.)

5. **Remove Unused Options**: Clean up options that are no longer needed using `handler:remove()` or `removeByResource()`

---

## Best Practices

### 1. Always Set a Name

Setting a `name` identifier makes it easier to remove options later:

```lua
exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    name = "enter_vehicle"  -- Important!
})
```

### 2. Use Appropriate Distances

Set realistic interaction distances based on the action:

```lua
-- Close interaction (search, pick up)
distance = 1.5

-- Medium interaction (enter vehicle, open door)
distance = 3.0

-- Long interaction (use ATM, talk to NPC)
distance = 5.0
```

### 3. Validate in canInteract

Use `canInteract` to validate conditions before showing options:

```lua
canInteract = function(entity, distance)
    -- Validate multiple conditions
    return distance <= 2.0 
        and exports['inventory']:hasItem('key')
        and not IsPedInAnyVehicle(PlayerPedId(), false)
end
```

### 4. Store Handler References

Store handler references to enable dynamic updates:

```lua
local vehicleOption = exports['nbl-target']:addGlobalVehicle({...})

-- Later, update dynamically
vehicleOption:setLabel("New Label")
```

### 5. Use Array Support for Multiple Items

Instead of registering multiple times, use array support:

```lua
-- Good: Single registration for multiple models
addModel({'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, options)

-- Bad: Multiple registrations
addModel('prop_atm_01', options)
addModel('prop_atm_02', options)
addModel('prop_atm_03', options)
```

### 6. Handle Errors Gracefully

Always validate entities and handle errors:

```lua
onSelect = function(entity, coords)
    if not DoesEntityExist(entity) then
        return
    end
    
    -- Safe to use entity
    local model = GetEntityModel(entity)
    print("Model: " .. model)
end
```

### 7. Use shouldClose Appropriately

Use `shouldClose = true` for actions that should exit targeting mode:

```lua
-- Good: Entering vehicle should close menu
shouldClose = true

-- Bad: Checking health shouldn't close menu
shouldClose = false  -- or omit
```

### 8. Optimize canInteract Functions

Keep `canInteract` functions fast and simple:

```lua
-- Good: Fast and simple
canInteract = function(entity, distance)
    return distance <= 2.0 and not IsVehicleLocked(entity)
end

-- Bad: Heavy operations
canInteract = function(entity, distance)
    local players = GetActivePlayers()  -- Expensive!
    -- ... complex logic
end
```

---

## Troubleshooting

### Outline not removing

**Symptoms:** Entity outline remains visible after releasing activation key.

**Solutions:**
1. Check `Config.Outline.enabled` is `true`
2. Verify entity type is in `Config.Outline.allowedTypes`
3. Ensure `Config.Target.allowSelfTarget = true` if targeting yourself
4. The system includes automatic cleanup, but if issues persist, restart the resource

### Menu not opening

**Symptoms:** Clicking on entity doesn't open the menu.

**Solutions:**
1. Check console for errors
2. Verify entity has registered options using `getCurrentTarget()`
3. Check `canInteract` returns `true` (add debug prints)
4. Ensure distance is within `Config.Target.maxDistance`
5. Verify entity type matches registration type
6. Check if registry is enabled: `exports['nbl-target']:isEnabled()`

### Options not updating

**Symptoms:** Options don't appear/disappear when conditions change.

**Solutions:**
1. Check `Config.Menu.refreshInterval` is not `0`
2. Verify `canInteract` function is correct (test with simple return `true`)
3. Check console for errors in `canInteract`
4. Ensure menu is open (refresh only happens when menu is open)

### Self-targeting not working

**Symptoms:** Can't target yourself.

**Solutions:**
1. Set `Config.Target.allowSelfTarget = true`
2. Use `addGlobalSelf()` instead of `addGlobalPlayer()`
3. Ensure `Config.Outline.allowedTypes.self = true`
4. Check that you're actually targeting yourself (use `getCurrentTarget()`)

### Handler methods not working

**Symptoms:** Handler methods don't update the option.

**Solutions:**
1. Verify you're using the handler object (not the ID)
2. Check that the registration still exists
3. Ensure menu refresh is enabled (`refreshInterval > 0`)
4. Changes take effect on next menu refresh

### Performance Issues

**Symptoms:** High CPU usage or lag.

**Solutions:**
1. Increase `Config.Menu.refreshInterval` (e.g., 1000ms instead of 500ms)
2. Simplify `canInteract` functions
3. Use model registration instead of individual entity registration
4. Disable registry when not needed: `exports['nbl-target']:disable()`
5. Remove unused options: `handler:remove()`

### Options not removing

**Symptoms:** Options remain after entity is deleted.

**Solutions:**
1. Automatic cleanup runs every 30 seconds
2. Manually remove using `handler:remove()`
3. Use `removeByResource()` to remove all from a resource
4. Check that the handler reference is correct

---

## Entity Types Reference

### Supported Entity Types

- **`vehicle`** - All vehicles (cars, trucks, bikes, etc.)
- **`ped`** - All NPCs (non-player peds)
- **`player`** - All players (other players, not yourself)
- **`object`** - All objects/props
- **`self`** - The player themselves
- **`ground`** - Ground/terrain (rarely used)
- **`sky`** - Sky/empty space (rarely used)

### Entity Type Detection

The system automatically detects entity types using:
- `IsPedAVehicle()` - For vehicles
- `IsPedAPlayer()` - For players
- `IsPedAnObject()` - For objects
- Entity model hash comparison

---

## Callback Reference

### canInteract Callback

**Signature:**
```lua
function(entity, distance, worldPos, name, bone)
    return boolean
end
```

**Parameters:**
- `entity` (number) - Entity handle
- `distance` (number) - Distance from player to entity in meters
- `worldPos` (vector3) - World position of the entity
- `name` (string) - Option name identifier
- `bone` (number or nil) - Bone index if applicable (usually nil)

**Returns:**
- `boolean` - `true` to show option, `false` to hide it

**Called:** Every `refreshInterval` milliseconds when menu is open, and when hovering over entity

### onSelect Callback

**Signature:**
```lua
function(entity, coords, registration)
    -- Your code here
end
```

**Parameters:**
- `entity` (number) - Entity handle
- `coords` (vector3) - World position of the entity
- `registration` (table) - Complete registration table (contains all option data)

**Returns:** None

**Called:** When the option is selected from the menu

---

## Export Reference

### Export Format

When using the `export` parameter, use the format: `"resource.export"`

**Example:**
```lua
export = "mechanic.repair"
```

This calls: `exports['mechanic']:repair(entity, coords, registration)`

**Parameters passed to export:**
1. `entity` (number) - Entity handle
2. `coords` (vector3) - World position
3. `registration` (table) - Registration table

---

## Notes

- The menu closes automatically when clicking outside or right-clicking
- Sub-menus have a delay before closing when moving mouse away (configurable)
- Options with `shouldClose = true` will close the menu AND deactivate targeting
- All callbacks are protected with `pcall` to prevent crashes
- Resource cleanup is automatic - no need to manually remove options
- Handler methods work on all registrations created by the handler (useful with arrays)
- Changes from handler methods take effect immediately and are reflected on next menu refresh
- Method chaining is supported for all setter methods
- Handler methods are protected and won't crash if the registration doesn't exist

---

## File Structure

```
nbl-target/
├── config/
│   └── config.lua              # Main configuration file
├── client/
│   ├── modules/
│   │   ├── raycast.lua         # Raycast system for entity detection
│   │   ├── entity.lua           # Entity utilities and type detection
│   │   └── visual.lua           # Visual feedback (outline, markers)
│   ├── registry.lua            # Option registration and management
│   ├── nui.lua                  # NUI bridge (Lua ↔ JavaScript)
│   └── main.lua                 # Main client script (activation, input)
├── web/
│   ├── index.html              # NUI HTML structure
│   ├── css/
│   │   └── style.css           # Menu styling (dark theme, animations)
│   └── js/
│       └── app.js               # Menu logic (open/close, sub-menus)
├── fxmanifest.lua              # Resource manifest
└── README.md                    # This file
```

---

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

---

## License

This resource is open-source. Use it as you wish.

---

**Developed with ❤️ for the FiveM community**
