# NBL Target - Complete Documentation

A modern, feature-rich context menu and targeting system for FiveM. Built with performance, flexibility, and ease of use in mind.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Complete API Reference](#complete-api-reference)
- [Checkboxes System](#checkboxes-system)
- [Sub-menus](#sub-menus)
- [Real-time Refresh System](#real-time-refresh-system)
- [Handler Methods](#handler-methods)
- [Usage Examples](#usage-examples)
- [Advanced Features](#advanced-features)
- [Performance Optimizations](#performance-optimizations)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

NBL Target is a comprehensive targeting system that allows players to interact with entities (vehicles, peds, objects, players, self) through a modern context menu interface. Hold the activation key (default: Left Alt) to enter targeting mode, then click on any entity to open a context menu with available interaction options.

### How It Works

1. **Activation**: Player holds the activation key (Left Alt by default)
2. **Targeting**: System performs raycast to detect entities under the cursor
3. **Visual Feedback**: Entities with available options show outline and 3D marker
4. **Cursor Change**: Cursor icon changes when hovering over targetable entities
5. **Selection**: Player clicks on entity to open context menu
6. **Interaction**: Player selects an option from the menu (or checkbox, or sub-menu)
7. **Action**: System executes the registered action (callback, export, event, etc.)
8. **Real-time Updates**: Menu refreshes automatically to show/hide options based on conditions

---

## ✨ Features

- 🎯 **Advanced Targeting System**: Precise entity detection with configurable raycast (vehicles, peds, objects, ground, sky, self)
- 🖱️ **Visual Feedback**: Outline and 3D markers on hover for clear entity indication
- 🎨 **Dynamic Cursor**: Cursor changes based on entity state (has options or not)
- 📦 **Flexible Registration**: Register options for specific entities, models, or global types
- 🔄 **Array Support**: Register for multiple entities or models with a single call
- 🎨 **Modern NUI Menu**: Beautiful dark-themed context menu with smooth animations
- 📋 **Sub-menus**: Nested options with hover support and conditional display
- ☑️ **Checkboxes**: Interactive checkboxes with real-time state updates
- ⚡ **Real-time Updates**: Auto-refresh options based on `canInteract` conditions and checkbox states
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

### With Checkbox

```lua
local debugEnabled = false

exports['nbl-target']:addGlobalSelf({
    {
        label = 'Settings',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'debug_mode',
                label = 'Debug Mode',
                icon = 'fas fa-bug',
                checkbox = true,
                checked = function()
                    return debugEnabled
                end,
                onCheck = function(newState)
                    debugEnabled = newState
                    print("Debug mode: " .. tostring(debugEnabled))
                end
            }
        }
    }
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
    maxDistance = 100.0,           -- Maximum raycast distance (meters)
    raycastFlags = 287,             -- Raycast flags (what entities can be detected)
    allowSelfTarget = true,         -- Allow targeting yourself
    defaultDistance = 3.0           -- Default interaction distance (meters)
}
```

**Raycast Flags:**
- `-1` - All entity types
- `1` - World/terrain
- `2` - Vehicles
- `4` - Peds
- `8` - Objects
- `16` - Water
- `32` - Foliage
- `287` - World + Vehicles + Peds + Objects + Water + IntersectEntities (recommended)

**Important Notes:**
- `maxDistance` controls how far away you can **hover** over entities (raycast detection)
- Individual option `distance` controls the **interaction** distance (when you can actually click)
- You can hover from far away (100m) but only interact when close (3m default)

### Outline (Entity Highlight)

```lua
Config.Outline = {
    enabled = true,
    color = {r = 88, g = 101, b = 242, a = 255},  -- Nebula Blue (RGBA)
    allowedTypes = {
        vehicle = true,
        object = true,
        ped = false,      -- WARNING: Crashes on peds!
        player = false,   -- WARNING: Crashes on players!
        self = false      -- WARNING: Crashes on self!
    }
}
```

**⚠️ CRITICAL WARNING**: `SetEntityDrawOutline` **CRASHES** on peds, players, and self! Always keep these set to `false` in `allowedTypes`.

### Marker (3D Marker Above Entity)

```lua
Config.Marker = {
    enabled = true,
    type = 2,                    -- Marker type (2 = Arrow down)
    color = {r = 88, g = 101, b = 242, a = 200},  -- Nebula Blue (RGBA)
    scale = 0.3,                 -- Marker scale
    height = 0.3,                -- Height offset above entity top (meters)
    rotate = true,               -- Rotate animation
    bob = true,                  -- Bobbing animation
    allowedTypes = {
        vehicle = true,
        object = true,
        ped = true,
        player = true,
        self = true
    }
}
```

**Common Marker Types:**
- `1` - Cylinder
- `2` - Arrow down (default)
- `25` - Horizontal circle
- `27` - Arrow

**Marker Height**: The marker automatically calculates entity height using `GetModelDimensions` and positions itself above the entity's top. The `height` parameter is just an additional offset.

### Menu (NUI Context Menu)

```lua
Config.Menu = {
    scale = 1.0,                 -- Menu scale (1.0 = 100%)
    maxVisibleOptions = 8,       -- Max options before scroll
    subMenuDelay = 150,          -- Delay before showing submenu (ms)
    animationDuration = 150,     -- Animation duration (ms)
    closeOnKeyRelease = true,    -- Close menu when releasing activation key
    refreshInterval = 250        -- Auto-refresh interval (ms, 0 = disabled)
}
```

**Refresh Interval:**
- `0` - Disable auto-refresh (not recommended)
- `250` - Refresh every 250ms (fast, good for checkboxes)
- `500` - Refresh every 500ms (balanced, default)
- `1000` - Refresh every 1000ms (slower, better performance)

**How Refresh Works:**
- When menu is open, system calls all `canInteract` functions every `refreshInterval` ms
- For checkboxes, system calls `checked()` function every `refreshInterval` ms
- Only sends updates to NUI if something actually changed (smart hash comparison)
- Works in main menu AND sub-menus (checkboxes update in real-time)

---

## Complete API Reference

### State Exports

#### `isActive()`

Check if targeting mode is currently active.

```lua
local active = exports['nbl-target']:isActive()
-- Returns: boolean
```

#### `isMenuOpen()`

Check if the context menu is currently open.

```lua
local isOpen = exports['nbl-target']:isMenuOpen()
-- Returns: boolean
```

#### `isEnabled()`

Check if the registry system is enabled.

```lua
local enabled = exports['nbl-target']:isEnabled()
-- Returns: boolean
```

#### `getCurrentTarget()`

Get information about the currently hovered or selected entity.

```lua
local target = exports['nbl-target']:getCurrentTarget()
-- Returns: table or nil
-- {
--     entity = number,        -- Entity handle
--     entityType = string,    -- "vehicle", "ped", "player", "object", "self"
--     worldPos = vector3      -- World position
-- }
```

#### `getSelectedEntity()`

Get the entity handle of the currently selected entity (when menu is open).

```lua
local entity = exports['nbl-target']:getSelectedEntity()
-- Returns: number or nil
```

### Control Exports

#### `enable()`

Enable the registry system.

```lua
exports['nbl-target']:enable()
```

#### `disable()`

Disable the registry system.

```lua
exports['nbl-target']:disable()
```

#### `deactivate()`

Deactivate the targeting mode (equivalent to releasing the activation key).

```lua
exports['nbl-target']:deactivate()
```

#### `closeMenu()`

Manually close the context menu (does NOT deactivate targeting mode).

```lua
exports['nbl-target']:closeMenu()
```

### Registration Exports

All registration exports return a **handler object** with methods to dynamically control the option.

#### `addEntity(entities, options)`

Register an option for a specific entity or array of entities.

```lua
local target = exports['nbl-target']:addEntity(entity, options)
-- OR
local target = exports['nbl-target']:addEntity({entity1, entity2, entity3}, options)
```

#### `addLocalEntity(entities, options)`

Register an option for a local entity (client-side only, not synced).

```lua
local target = exports['nbl-target']:addLocalEntity(entity, options)
```

#### `addModel(models, options)`

Register an option for one or multiple models.

```lua
-- Single model (string or hash)
local target = exports['nbl-target']:addModel('prop_atm_01', options)
local target = exports['nbl-target']:addModel(GetHashKey('prop_atm_01'), options)

-- Multiple models (array)
local target = exports['nbl-target']:addModel({
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03'
}, options)
```

#### `addGlobalVehicle(options)`

Register an option for all vehicles.

```lua
local target = exports['nbl-target']:addGlobalVehicle(options)
```

#### `addGlobalPed(options)`

Register an option for all NPCs (peds).

```lua
local target = exports['nbl-target']:addGlobalPed(options)
```

#### `addGlobalPlayer(options)`

Register an option for all players.

```lua
local target = exports['nbl-target']:addGlobalPlayer(options)
```

#### `addGlobalSelf(options)`

Register an option for yourself (the player).

```lua
local target = exports['nbl-target']:addGlobalSelf(options)
```

#### `addGlobalObject(options)`

Register an option for all objects.

```lua
local target = exports['nbl-target']:addGlobalObject(options)
```

#### `addGlobalOption(entityType, options)`

Register an option for a custom entity type.

```lua
local target = exports['nbl-target']:addGlobalOption('vehicle', options)
```

**Array Support for Global Types:**

You can register multiple options at once by passing an array:

```lua
exports['nbl-target']:addGlobalVehicle({
    {
        name = 'enter',
        label = 'Enter Vehicle',
        icon = 'fas fa-car-side',
        onSelect = function(entity) end
    },
    {
        name = 'lock',
        label = 'Lock/Unlock',
        icon = 'fas fa-lock',
        onSelect = function(entity) end
    },
    {
        name = 'trunk',
        label = 'Open Trunk',
        icon = 'fas fa-box',
        onSelect = function(entity) end
    }
})
```

### Removal Exports

#### `remove(handlerOrId)`

Generic remove function that works with handler objects or registration IDs.

```lua
exports['nbl-target']:remove(handler)
-- OR
exports['nbl-target']:remove(123)
```

#### `removeByName(name)`

Remove an option by its name identifier.

```lua
exports['nbl-target']:removeByName("enter_vehicle")
```

#### `removeByResource(resourceName)`

Remove all options registered by a specific resource.

```lua
local count = exports['nbl-target']:removeByResource('myresource')
```

---

## Checkboxes System

NBL Target supports interactive checkboxes that can be toggled and update in real-time.

### Basic Checkbox

```lua
local mySetting = false

exports['nbl-target']:addGlobalSelf({
    {
        label = 'Settings',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'my_setting',
                label = 'Enable Feature',
                icon = 'fas fa-toggle-on',
                checkbox = true,
                checked = function()
                    return mySetting
                end,
                onCheck = function(newState)
                    mySetting = newState
                    print("Feature enabled: " .. tostring(newState))
                end
            }
        }
    }
})
```

### Checkbox Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `checkbox` | `boolean` | Yes | Set to `true` to enable checkbox mode |
| `checked` | `function` or `boolean` | Yes | Function that returns current state, or boolean for static state |
| `onCheck` | `function` | No | Callback when checkbox is toggled |

### Checkbox Behavior

1. **Static State (Boolean)**:
   ```lua
   checkbox = true,
   checked = false,  -- Initial state
   onCheck = function(newState)
       -- Update your variable
   end
   ```

2. **Dynamic State (Function)** - **RECOMMENDED**:
   ```lua
   checkbox = true,
   checked = function()
       return myVariable  -- Called every refreshInterval ms
   end,
   onCheck = function(newState)
       myVariable = newState  -- Called when user clicks
   end
   ```

### Real-time Updates

When using a function for `checked`, the system automatically:
- Calls the function every `refreshInterval` milliseconds (default: 250ms)
- Updates the checkbox visual state if the value changed
- Works even when you're in a sub-menu
- Updates instantly when external code changes your variable

**Example with External Update:**

```lua
local debugEnabled = false

-- Register checkbox
exports['nbl-target']:addGlobalSelf({
    {
        label = 'Settings',
        items = {
            {
                name = 'debug',
                label = 'Debug Mode',
                checkbox = true,
                checked = function()
                    return debugEnabled  -- Reads from variable
                end,
                onCheck = function(newState)
                    debugEnabled = newState  -- Updates variable
                end
            }
        }
    }
})

-- External command to toggle
RegisterCommand('toggleDebug', function()
    debugEnabled = not debugEnabled
    -- Checkbox will update automatically within 250ms!
end, false)
```

### Checkbox Restrictions

- ❌ **Checkbox + Sub-menu**: An option cannot have both `checkbox = true` AND `items`. If both are set, `items` will be ignored.
- ✅ **Checkbox in Sub-menu**: Checkboxes work perfectly inside sub-menus
- ✅ **Nested Sub-menus**: Checkboxes can be in nested sub-menus

### Handler Methods for Checkboxes

```lua
local handler = exports['nbl-target']:addGlobalSelf({...})

-- Force checkbox state (only works if using boolean, not function)
handler:setChecked(true)

-- Change the onCheck callback
handler:setOnCheck(function(newState)
    -- New callback
end)
```

**Note**: `setChecked()` only works if you're using a boolean for `checked`. If you're using a function, just update your variable and the checkbox will update automatically.

---

## Sub-menus

Sub-menus allow you to create nested options that appear when hovering over a parent option.

### Basic Sub-menu

```lua
exports['nbl-target']:addGlobalVehicle({
    {
        label = 'Vehicle Menu',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'lock',
                label = 'Lock/Unlock',
                icon = 'fas fa-lock',
                onSelect = function(entity) end
            },
            {
                name = 'engine',
                label = 'Engine',
                icon = 'fas fa-car',
                items = {  -- Nested sub-menu
                    {
                        name = 'start',
                        label = 'Start',
                        icon = 'fas fa-play',
                        onSelect = function(entity) end
                    },
                    {
                        name = 'stop',
                        label = 'Stop',
                        icon = 'fas fa-stop',
                        onSelect = function(entity) end
                    }
                }
            }
        }
    }
})
```

### Sub-menu Parameters

Sub-menu items support all the same parameters as main options:
- `name`, `label`, `icon`
- `distance`, `canInteract`
- `onSelect`, `export`, `event`, `serverEvent`, `command`
- `shouldClose`, `enabled`
- `checkbox`, `checked`, `onCheck` (checkboxes work in sub-menus!)
- `items` (nested sub-menus, max 2 levels deep)

### Sub-menu Depth Limit

**Maximum depth: 2 levels of sub-menus**

```
Main Menu (Level 0)
  └─ Option with items (opens Sub-menu Level 1)
      └─ Option with items (opens Sub-menu Level 2)
          └─ Options here CANNOT have items (max depth reached)
```

This limit ensures good UX and prevents overly complex menu structures.

### Sub-menu Behavior

- **Hover to Open**: Sub-menu opens after `subMenuDelay` milliseconds (default: 150ms)
- **Auto-close**: Sub-menu closes when mouse leaves (with small delay)
- **Refresh**: Sub-menu items are refreshed in real-time (checkboxes update automatically)
- **Distance Check**: Sub-menu items respect their own `distance` parameter
- **canInteract**: Sub-menu items support `canInteract` for conditional display

### Sub-menu with Checkboxes

```lua
local setting1 = false
local setting2 = true

exports['nbl-target']:addGlobalSelf({
    {
        label = 'Settings',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'setting1',
                label = 'Setting 1',
                checkbox = true,
                checked = function() return setting1 end,
                onCheck = function(newState) setting1 = newState end
            },
            {
                name = 'setting2',
                label = 'Setting 2',
                checkbox = true,
                checked = function() return setting2 end,
                onCheck = function(newState) setting2 = newState end
            }
        }
    }
})
```

---

## Real-time Refresh System

NBL Target includes a powerful real-time refresh system that updates options and checkboxes automatically.

### How It Works

1. **When Menu is Open**: System refreshes every `refreshInterval` milliseconds (default: 250ms)
2. **Checks Conditions**: Calls all `canInteract` functions to see if options should show/hide
3. **Checks Checkboxes**: Calls all `checked()` functions to update checkbox states
4. **Smart Updates**: Only sends updates to NUI if something actually changed (hash comparison)
5. **Works Everywhere**: Refresh works in main menu AND sub-menus

### Configuration

```lua
Config.Menu = {
    refreshInterval = 250  -- Milliseconds between refreshes
}
```

**Recommended Values:**
- `250` - Fast updates, good for checkboxes (default)
- `500` - Balanced, good for most use cases
- `1000` - Slower, better performance
- `0` - Disabled (not recommended)

### What Gets Refreshed

1. **Option Visibility**: Options appear/disappear based on `canInteract` results
2. **Checkbox States**: Checkboxes update based on `checked()` function results
3. **Labels/Icons**: If you change them via handler methods, they update on next refresh

### Example: Dynamic Option Visibility

```lua
local hasKey = false

exports['nbl-target']:addGlobalVehicle({
    {
        label = 'Enter Vehicle',
        canInteract = function(entity, distance)
            -- This is called every 250ms when menu is open
            return hasKey and distance <= 3.0
        end,
        onSelect = function(entity) end
    }
})

-- Later, player gets key
RegisterNetEvent('keys:received', function()
    hasKey = true
    -- Option will appear automatically within 250ms!
end)
```

### Example: Real-time Checkbox Updates

```lua
local godmode = false

exports['nbl-target']:addGlobalSelf({
    {
        label = 'Admin',
        items = {
            {
                name = 'godmode',
                label = 'God Mode',
                checkbox = true,
                checked = function()
                    return godmode  -- Called every 250ms
                end,
                onCheck = function(newState)
                    godmode = newState
                    SetEntityInvincible(PlayerPedId(), newState)
                end
            }
        }
    }
})

-- External toggle
RegisterCommand('god', function()
    godmode = not godmode
    SetEntityInvincible(PlayerPedId(), godmode)
    -- Checkbox updates automatically within 250ms!
end, false)
```

### Performance Considerations

- **Refresh Interval**: Lower values = more responsive but higher CPU usage
- **canInteract Functions**: Keep them fast! They're called frequently
- **checked Functions**: Keep them fast! They're called frequently
- **Smart Hash**: System only updates NUI if something changed, reducing overhead

---

## Handler Methods

All registration exports return a **handler object** with methods to dynamically control the option.

### Available Methods

#### `:setLabel(label)`

Change the option label dynamically.

```lua
target:setLabel("New Label")
```

#### `:setIcon(icon)`

Change the option icon.

```lua
target:setIcon("fas fa-star")
```

#### `:setEnabled(enabled)`

Enable or disable the option.

```lua
target:setEnabled(false)  -- Disable
target:setEnabled(true)   -- Enable
```

#### `:setDistance(distance)`

Change the interaction distance.

```lua
target:setDistance(5.0)
```

#### `:setCanInteract(fn)`

Change the canInteract function.

```lua
target:setCanInteract(function(entity, distance)
    return distance <= 2.0
end)
```

#### `:setOnSelect(fn)`

Change the onSelect callback.

```lua
target:setOnSelect(function(entity, coords)
    print("New callback!")
end)
```

#### `:setOnCheck(fn)` (Checkboxes only)

Change the onCheck callback.

```lua
target:setOnCheck(function(newState)
    print("New checkbox callback!")
end)
```

#### `:setChecked(checked)` (Checkboxes only)

Force checkbox state (only works with boolean `checked`, not functions).

```lua
target:setChecked(true)
```

#### `:remove()`

Remove the registration(s).

```lua
target:remove()
```

#### `:getId()`

Get the registration ID(s).

```lua
local id = target:getId()
```

### Method Chaining

All setter methods return the handler object, allowing method chaining:

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
| `name` | `string` | No | Unique identifier for the option | - |
| `icon` | `string` | No | Font Awesome icon class | `"fas fa-hand-pointer"` |
| `distance` | `number` | No | Maximum interaction distance in meters | `3.0` |
| `canInteract` | `function` | No | Function that returns `true`/`false` to show/hide | Always `true` |
| `onSelect` | `function` | No | Callback when option is selected | - |
| `onCheck` | `function` | No | Callback when checkbox is toggled (checkboxes only) | - |
| `checkbox` | `boolean` | No | Enable checkbox mode | `false` |
| `checked` | `function` or `boolean` | No | Checkbox state (function or boolean) | - |
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

**Returns:** `boolean` - `true` to show, `false` to hide

**Called:** Every `refreshInterval` ms when menu is open, and when hovering

#### `onSelect` Callback

Called when the option is selected.

**Parameters:**
- `entity` (number) - Entity handle
- `coords` (vector3) - World position of the entity
- `registration` (table) - The registration table (contains all option data)

**Returns:** None

**Called:** When the option is clicked

#### `onCheck` Callback (Checkboxes)

Called when a checkbox is toggled.

**Parameters:**
- `newState` (boolean) - The new checkbox state (`true` or `false`)
- `entity` (number) - Entity handle (or `nil` for self)
- `worldPos` (vector3) - World position (or `nil` for self)
- `registration` (table) - The registration table

**Returns:** None

**Called:** When the checkbox is clicked

#### `checked` Function (Checkboxes)

Called to get the current checkbox state.

**Parameters:** None (or `entity, worldPos` if you want them)

**Returns:** `boolean` - `true` for checked, `false` for unchecked

**Called:** Every `refreshInterval` ms when menu is open (for real-time updates)

---

## Usage Examples

### Basic Vehicle Interaction

```lua
exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### Vehicle with Multiple Options

```lua
exports['nbl-target']:addGlobalVehicle({
    {
        name = 'enter',
        label = 'Enter Vehicle',
        icon = 'fas fa-car-side',
        onSelect = function(entity) end
    },
    {
        name = 'lock',
        label = 'Lock/Unlock',
        icon = 'fas fa-lock',
        canInteract = function(entity, distance)
            return exports['keys']:hasKeys(entity)
        end,
        onSelect = function(entity) end
    },
    {
        name = 'trunk',
        label = 'Open Trunk',
        icon = 'fas fa-box',
        onSelect = function(entity) end
    }
})
```

### Sub-menu with Checkboxes

```lua
local debugEnabled = false
local notificationsEnabled = true

exports['nbl-target']:addGlobalSelf({
    {
        label = 'Settings',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'debug',
                label = 'Debug Mode',
                icon = 'fas fa-bug',
                checkbox = true,
                checked = function()
                    return debugEnabled
                end,
                onCheck = function(newState)
                    debugEnabled = newState
                end
            },
            {
                name = 'notifications',
                label = 'Notifications',
                icon = 'fas fa-bell',
                checkbox = true,
                checked = function()
                    return notificationsEnabled
                end,
                onCheck = function(newState)
                    notificationsEnabled = newState
                end
            }
        }
    }
})
```

### Complex Sub-menu Structure

```lua
exports['nbl-target']:addGlobalVehicle({
    {
        label = 'Vehicle Menu',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'lock',
                label = 'Lock/Unlock',
                icon = 'fas fa-lock',
                onSelect = function(entity) end
            },
            {
                name = 'engine',
                label = 'Engine',
                icon = 'fas fa-car',
                items = {
                    {
                        name = 'start',
                        label = 'Start',
                        icon = 'fas fa-play',
                        onSelect = function(entity) end
                    },
                    {
                        name = 'stop',
                        label = 'Stop',
                        icon = 'fas fa-stop',
                        onSelect = function(entity) end
                    }
                }
            },
            {
                name = 'doors',
                label = 'Doors',
                icon = 'fas fa-door-open',
                items = {
                    {
                        name = 'front_left',
                        label = 'Front Left',
                        onSelect = function(entity) end
                    },
                    {
                        name = 'front_right',
                        label = 'Front Right',
                        onSelect = function(entity) end
                    }
                }
            }
        }
    }
})
```

### Model Registration (ATMs)

```lua
exports['nbl-target']:addModel({
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
        TriggerEvent('banking:openATM')
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

### Using Events

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

### Handler Methods Example

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock"
})

-- Later, update dynamically
target:setLabel("Unlock Vehicle")
    :setIcon("fas fa-lock-open")
    :setDistance(5.0)

-- Temporarily disable
target:setEnabled(false)

-- Re-enable
target:setEnabled(true)

-- Remove when done
target:remove()
```

---

## Advanced Features

### Real-time Option Updates

The menu automatically refreshes options based on `canInteract` conditions when open. This allows options to appear/disappear dynamically based on game state.

**How it works:**
- When menu is open, system checks `canInteract` functions every `refreshInterval` ms
- If an option's `canInteract` changes from `false` to `true`, it appears
- If it changes from `true` to `false`, it disappears
- Only options that actually changed are updated (smart refresh)

### Resource Auto-cleanup

When a resource stops, all its registered options are automatically removed. This prevents orphaned options and memory leaks.

**Manual cleanup (if needed):**
```lua
exports['nbl-target']:removeByResource('myresource')
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

### Cursor Feedback

The cursor automatically changes when hovering over targetable entities, even if they don't have registered options. This prevents "cheating" by knowing which objects are interactive.

---

## Performance Optimizations

NBL Target is built with performance in mind:

### 1. Zero CPU When Inactive

When the activation key is not pressed, the main thread sleeps for 500ms, resulting in **0ms CPU usage**.

### 2. Optimized Raycast

- Camera position is cached
- Raycast is only performed when targeting mode is active
- Maximum distance is configurable

### 3. Smart Menu Refresh

- Options are only refreshed if they actually changed
- Hash comparison prevents unnecessary NUI updates
- Checkbox states update efficiently (only visual update, no DOM rebuild)

### 4. Automatic Entity Cleanup

- Invalid entities are automatically removed every 30 seconds
- Prevents memory leaks

### 5. Protected Callbacks

- All callbacks are wrapped in `pcall` to prevent crashes
- Errors are logged but don't break the system

### Performance Tips

1. **Use Model Registration**: Instead of registering individual entities, use `addModel()` for props that appear multiple times
2. **Limit Refresh Interval**: Increase `refreshInterval` if you don't need real-time updates
3. **Keep canInteract Fast**: Avoid heavy operations inside `canInteract` functions
4. **Disable When Not Needed**: Use `disable()` to turn off the registry system when not needed

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

- Close interaction (search, pick up): `1.5m`
- Medium interaction (enter vehicle, open door): `3.0m`
- Long interaction (use ATM, talk to NPC): `5.0m`

### 3. Validate in canInteract

Use `canInteract` to validate conditions before showing options:

```lua
canInteract = function(entity, distance)
    return distance <= 2.0 
        and exports['inventory']:hasItem('key')
        and not IsPedInAnyVehicle(PlayerPedId(), false)
end
```

### 4. Use Functions for Checkbox State

Always use functions for `checked` to enable real-time updates:

```lua
-- Good: Function (updates automatically)
checked = function()
    return myVariable
end

-- Bad: Boolean (static, doesn't update)
checked = false
```

### 5. Store Handler References

Store handler references to enable dynamic updates:

```lua
local vehicleOption = exports['nbl-target']:addGlobalVehicle({...})

-- Later, update dynamically
vehicleOption:setLabel("New Label")
```

---

## Troubleshooting

### Checkbox not updating

**Symptoms:** Checkbox doesn't reflect current state when reopening menu.

**Solutions:**
1. Use a **function** for `checked`, not a boolean
2. Ensure `refreshInterval` is not `0`
3. Check that your variable is in the correct scope
4. Verify `onCheck` is updating your variable correctly

### Checkbox not toggling

**Symptoms:** Clicking checkbox doesn't do anything.

**Solutions:**
1. Check console for errors (F8)
2. Verify `onCheck` callback is defined
3. Ensure checkbox is not in a parent option with `items` (not allowed)

### Menu not opening

**Symptoms:** Clicking on entity doesn't open the menu.

**Solutions:**
1. Check console for errors
2. Verify entity has registered options
3. Check `canInteract` returns `true`
4. Ensure distance is within `maxDistance`
5. Verify registry is enabled: `exports['nbl-target']:isEnabled()`

### Options not updating

**Symptoms:** Options don't appear/disappear when conditions change.

**Solutions:**
1. Check `Config.Menu.refreshInterval` is not `0`
2. Verify `canInteract` function is correct
3. Check console for errors in `canInteract`
4. Ensure menu is open (refresh only happens when menu is open)

### Performance Issues

**Symptoms:** High CPU usage or lag.

**Solutions:**
1. Increase `Config.Menu.refreshInterval` (e.g., 1000ms)
2. Simplify `canInteract` and `checked` functions
3. Use model registration instead of individual entity registration
4. Disable registry when not needed: `exports['nbl-target']:disable()`

---

## Technical Details

### How Checkboxes Work Internally

1. **Registration**: When you register a checkbox, the system stores the `checked` function (or boolean) and `onCheck` callback
2. **Display**: When menu opens, system calls `checked()` to get initial state
3. **Refresh Loop**: Every `refreshInterval` ms, system calls all `checked()` functions
4. **Click Handler**: When user clicks checkbox, JS sends `{id, checked: newState}` to Lua
5. **State Update**: Lua finds the registration by ID and calls `onCheck(newState)`
6. **Visual Update**: Checkbox visual state is updated immediately in JS, then refreshed from Lua on next cycle

### How Refresh System Works

1. **Thread Loop**: Main refresh thread runs every `refreshInterval` ms when menu is open
2. **Option Collection**: System calls `GetAvailableOptions()` which:
   - Gets all registrations for the entity
   - Calls `canInteract` for each option
   - Calls `checked()` for each checkbox
   - Processes sub-items recursively
3. **Hash Comparison**: System creates a hash of all option IDs, labels, and checkbox states
4. **Smart Update**: Only sends to NUI if hash changed (prevents unnecessary updates)
5. **NUI Update**: JS receives new options and updates only what changed (checkboxes update visually without DOM rebuild)

### ID System for Sub-items

- Sub-items get stable IDs based on `parentId + name` (or index if no name)
- IDs are stored in `subItemIdMap` to ensure consistency across refreshes
- This allows checkboxes in sub-menus to maintain their state correctly

### FiveM Export Function Wrapping

When you pass functions via exports (`exports['nbl-target']:addGlobalSelf(...)`), FiveM wraps them in callable tables. The system handles both:
- Normal functions: `type(checked) == "function"`
- FiveM-wrapped functions: `type(checked) == "table"`

Both are called using `pcall()` for safety.

---

## File Structure

```
nbl-target/
├── config/
│   └── config.lua              # Main configuration file (with comments)
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
│   │   └── style.css           # Menu styling (dark theme, animations, checkboxes)
│   └── js/
│       └── app.js               # Menu logic (open/close, sub-menus, checkboxes, refresh)
├── docs/                        # Documentation files
│   ├── NebulaTarget.md         # Main documentation page
│   ├── Installation.md         # Installation guide
│   └── Exports.md              # Complete exports reference
├── fxmanifest.lua              # Resource manifest
├── LICENSE                      # License file
└── README.md                    # This file
```

---

## Complete Parameter Reference

### Main Option Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `label` | `string` | Yes | - | Display text in menu |
| `name` | `string` | No | - | Unique identifier |
| `icon` | `string` | No | `"fas fa-hand-pointer"` | FontAwesome icon class |
| `distance` | `number` | No | `3.0` | Max interaction distance (meters) |
| `canInteract` | `function` | No | Always `true` | Conditional display function |
| `onSelect` | `function` | No | - | Callback when option selected |
| `checkbox` | `boolean` | No | `false` | Enable checkbox mode |
| `checked` | `function` or `boolean` | No | - | Checkbox state (function recommended) |
| `onCheck` | `function` | No | - | Callback when checkbox toggled |
| `export` | `string` | No | - | Export to call (`"resource.export"`) |
| `event` | `string` | No | - | Client event name |
| `serverEvent` | `string` | No | - | Server event name |
| `command` | `string` | No | - | Command to execute |
| `items` | `table` | No | - | Sub-menu items array |
| `shouldClose` | `boolean` | No | `false` | Close menu after selection |
| `enabled` | `boolean` | No | `true` | Enable/disable option |

### Sub-menu Item Parameters

Sub-menu items support all the same parameters as main options, except:
- ❌ Cannot have both `checkbox = true` AND `items` (items will be ignored)
- ✅ Can have `checkbox = true` OR `items` (but not both)

---

## Common Patterns

### Pattern 1: Settings Menu with Checkboxes

```lua
local settings = {
    debug = false,
    notifications = true,
    godmode = false
}

exports['nbl-target']:addGlobalSelf({
    {
        label = 'Settings',
        icon = 'fas fa-cog',
        items = {
            {
                name = 'debug',
                label = 'Debug Mode',
                icon = 'fas fa-bug',
                checkbox = true,
                checked = function() return settings.debug end,
                onCheck = function(state) settings.debug = state end
            },
            {
                name = 'notifications',
                label = 'Notifications',
                icon = 'fas fa-bell',
                checkbox = true,
                checked = function() return settings.notifications end,
                onCheck = function(state) settings.notifications = state end
            }
        }
    }
})
```

### Pattern 2: Vehicle Actions with Sub-menus

```lua
exports['nbl-target']:addGlobalVehicle({
    {
        label = 'Vehicle',
        icon = 'fas fa-car',
        items = {
            {
                name = 'doors',
                label = 'Doors',
                icon = 'fas fa-door-open',
                items = {
                    {name = 'front_left', label = 'Front Left', onSelect = function(e) end},
                    {name = 'front_right', label = 'Front Right', onSelect = function(e) end}
                }
            },
            {
                name = 'engine',
                label = 'Engine',
                icon = 'fas fa-cog',
                items = {
                    {name = 'start', label = 'Start', onSelect = function(e) end},
                    {name = 'stop', label = 'Stop', onSelect = function(e) end}
                }
            }
        }
    }
})
```

### Pattern 3: Conditional Options

```lua
exports['nbl-target']:addGlobalVehicle({
    {
        label = 'Lock Vehicle',
        icon = 'fas fa-lock',
        canInteract = function(entity, distance)
            return exports['keys']:hasKeys(entity) and distance <= 3.0
        end,
        onSelect = function(entity)
            exports['vehicles']:toggleLock(entity)
        end
    }
})
```

---

## License

See `LICENSE` file for details.

---

**Developed with ❤️ for the FiveM community**
