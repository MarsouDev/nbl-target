# NBL Context Menu

A modern, feature-rich context menu and targeting system for FiveM. Built with performance and flexibility in mind.

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [File Structure](#-file-structure)
- [Configuration](#-configuration)
- [API Reference](#-api-reference)
- [Usage Examples](#-usage-examples)
- [Advanced Features](#-advanced-features)
- [Performance](#-performance)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

- 🎯 **Advanced Targeting System**: Precise entity detection (vehicles, peds, objects, ground, sky, self)
- 🖱️ **Visual Feedback**: Outline and 3D markers on hover
- 🎨 **Dynamic Cursor**: Cursor changes based on entity state
- 📦 **Registry System**: Register specific entities or global types
- 🎨 **Modern NUI Menu**: Beautiful dark-themed context menu with animations
- 📋 **Sub-menus**: Nested options with hover support
- ⚡ **Real-time Updates**: Auto-refresh options based on `canInteract` conditions
- 🔧 **Multiple Actions**: Support for exports, events, serverEvents, commands
- 🛡️ **Error Handling**: Complete protection against crashes
- ⚡ **Optimized**: 0ms CPU when inactive, efficient resource usage
- 🔄 **Auto-cleanup**: Automatic removal of options when resources stop

## 🚀 Installation

1. Place the `nbl-contextmenu` folder in your `resources` directory
2. Add `ensure nbl-contextmenu` to your `server.cfg`
3. Restart your server

## 📁 File Structure

```
nbl-contextmenu/
├── config/
│   └── config.lua              # Main configuration file
├── client/
│   ├── modules/
│   │   ├── raycast.lua         # Raycast system for entity detection
│   │   ├── entity.lua           # Entity utilities and type detection
│   │   └── visual.lua           # Visual feedback (outline, markers)
│   ├── registry.lua            # Option registration and management
│   ├── nui.lua                  # NUI bridge (Lua ↔ JavaScript)
│   ├── main.lua                 # Main client script (activation, input)
│   └── test.lua                 # Test commands (optional, for development)
├── web/
│   ├── index.html              # NUI HTML structure
│   ├── css/
│   │   └── style.css           # Menu styling (dark theme, animations)
│   └── js/
│       └── app.js               # Menu logic (open/close, sub-menus)
├── fxmanifest.lua              # Resource manifest
└── README.md                    # This file
```

### Module Descriptions

- **raycast.lua**: Handles screen-to-world raycasting with camera caching for optimization
- **entity.lua**: Provides entity validation, type detection, and utility functions
- **visual.lua**: Manages outline and marker rendering with automatic cleanup
- **registry.lua**: Core registration system with resource tracking and cleanup
- **nui.lua**: Bridge between Lua and NUI, handles menu state and refresh
- **main.lua**: Main loop, activation/deactivation, input handling

## ⚙️ Configuration

All configuration is in `config/config.lua`. Here are the main sections:

### Controls

```lua
Config.Controls = {
    activationKey = 'LMENU',  -- Key to activate (Left Alt)
    selectKey = 24            -- Mouse button to select (24 = Left Click)
}
```

### Targeting

```lua
Config.Target = {
    maxDistance = 10.0,           -- Maximum raycast distance
    raycastFlags = -1,            -- Raycast flags (-1 = all types)
    allowSelfTarget = true,       -- Allow targeting yourself
    defaultDistance = 3.0         -- Default interaction distance
}
```

### Outline (Entity Highlight)

```lua
Config.Outline = {
    enabled = true,
    color = {r = 255, g = 255, b = 0, a = 255},  -- Yellow outline
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
    color = {r = 255, g = 255, b = 0, a = 200},
    scale = 0.3,
    height = 1.0,                -- Height above entity
    rotate = true,               -- Rotate animation
    bob = true                   -- Bobbing animation
}
```

### Menu (NUI Context Menu)

```lua
Config.Menu = {
    scale = 1.0,                 -- Menu scale
    maxVisibleOptions = 8,       -- Max options before scroll
    subMenuDelay = 150,          -- Delay before showing submenu
    animationDuration = 150,     -- Animation duration
    refreshInterval = 500        -- Auto-refresh interval (ms, 0 = disabled)
}
```

## 📖 API Reference

### Exports

#### Entity Registration

| Export | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `addEntity(entity, options)` | Register specific entity | `entity` (number), `options` (table) | `id` (number) |
| `addLocalEntity(entity, options)` | Register local entity | `entity` (number), `options` (table) | `id` (number) |
| `removeEntity(id)` | Remove entity registration | `id` (number) | `boolean` |
| `removeLocalEntity(id)` | Remove local entity | `id` (number) | `boolean` |

#### Model Registration

| Export | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `addModel(model, options)` | Register by model hash | `model` (number/string), `options` (table) | `id` (number) |
| `removeModel(id)` | Remove model registration | `id` (number) | `boolean` |

#### Global Type Registration

| Export | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `addGlobalVehicle(options)` | All vehicles | `options` (table) | `id` (number) |
| `addGlobalPed(options)` | All peds (NPCs) | `options` (table) | `id` (number) |
| `addGlobalPlayer(options)` | All players | `options` (table) | `id` (number) |
| `addGlobalObject(options)` | All objects | `options` (table) | `id` (number) |
| `addGlobalSelf(options)` | Self (player) | `options` (table) | `id` (number) |
| `addGlobalOption(entityType, options)` | Custom entity type | `entityType` (string), `options` (table) | `id` (number) |
| `removeGlobalVehicle(id)` | Remove global vehicle | `id` (number) | `boolean` |
| `removeGlobalPed(id)` | Remove global ped | `id` (number) | `boolean` |
| `removeGlobalPlayer(id)` | Remove global player | `id` (number) | `boolean` |
| `removeGlobalObject(id)` | Remove global object | `id` (number) | `boolean` |
| `removeGlobalOption(id)` | Remove global option | `id` (number) | `boolean` |

#### Utility Exports

| Export | Description | Parameters | Returns |
|--------|-------------|------------|---------|
| `removeByName(name)` | Remove by option name | `name` (string) | `boolean` |
| `removeByResource(resourceName)` | Remove all from resource | `resourceName` (string) | `count` (number) |
| `isActive()` | Check if targeting is active | - | `boolean` |
| `isMenuOpen()` | Check if menu is open | - | `boolean` |
| `getCurrentTarget()` | Get current hovered entity | - | `table` or `nil` |
| `getSelectedEntity()` | Get entity with open menu | - | `number` or `nil` |
| `closeMenu()` | Close the menu | - | - |
| `deactivate()` | Deactivate targeting mode | - | - |
| `enable()` | Enable registry | - | - |
| `disable()` | Disable registry | - | - |
| `isEnabled()` | Check if registry is enabled | - | `boolean` |
| `refreshOptions()` | Manually refresh menu options | - | `boolean` |

### Option Parameters

| Parameter | Type | Description | Required | Default |
|-----------|------|-------------|----------|---------|
| `label` | string | Display text | Yes | - |
| `name` | string | Unique identifier | No | - |
| `icon` | string | Font Awesome icon class | No | `"fas fa-hand-pointer"` |
| `distance` | number | Max interaction distance | No | `3.0` |
| `canInteract` | function | Condition to show option | No | Always true |
| `onSelect` | function | Callback on selection | No | - |
| `export` | string | Export to call (`"resource.export"`) | No | - |
| `event` | string | Client event to trigger | No | - |
| `serverEvent` | string | Server event to trigger | No | - |
| `command` | string | Command to execute | No | - |
| `items` | table | Sub-menu items | No | - |
| `shouldClose` | boolean | Close menu and deactivate target | No | `false` |
| `enabled` | boolean | Enable/disable option | No | `true` |

### Entity Types

- `vehicle` - All vehicles
- `ped` - All NPCs
- `player` - All players
- `object` - All objects
- `self` - The player themselves
- `ground` - Ground/terrain
- `sky` - Sky/empty space

## 💡 Usage Examples

### Basic Entity Registration

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local id = exports['nbl-contextmenu']:addEntity(vehicle, {
    label = "Open Trunk",
    icon = "fas fa-box",
    name = "open_trunk",
    distance = 3.0,
    onSelect = function(entity, coords, registration)
        print("Trunk opened!")
    end
})
```

### Global Type with canInteract

```lua
exports['nbl-contextmenu']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",
    distance = 5.0,
    canInteract = function(entity, distance, worldPos, name, bone)
        return not IsVehicleLocked(entity) and distance <= 3.0
    end,
    onSelect = function(entity, coords, registration)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### Sub-menu with Items

```lua
exports['nbl-contextmenu']:addEntity(ped, {
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
exports['nbl-contextmenu']:addEntity(vehicle, {
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    shouldClose = true,  -- Closes menu AND deactivates target
    onSelect = function(entity, coords)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})
```

### Using Exports/Events

```lua
-- Export
exports['nbl-contextmenu']:addGlobalVehicle({
    label = "Repair",
    name = "repair_vehicle",
    export = "mechanic.repair",
    distance = 3.0
})

-- Client Event
exports['nbl-contextmenu']:addGlobalObject({
    label = "Open",
    name = "open_object",
    event = "myresource:openObject",
    distance = 2.0
})

-- Server Event
exports['nbl-contextmenu']:addGlobalPed({
    label = "Search",
    name = "search_ped",
    serverEvent = "police:searchPed",
    distance = 1.5
})

-- Command
exports['nbl-contextmenu']:addGlobalVehicle({
    label = "Repair",
    name = "repair_cmd",
    command = "repair",
    distance = 3.0
})
```

### Self-Targeting

```lua
exports['nbl-contextmenu']:addGlobalSelf({
    label = "Check Health",
    icon = "fas fa-heart",
    name = "self_health",
    distance = 5.0,
    onSelect = function(entity, coords)
        local health = GetEntityHealth(entity)
        print("Your health: " .. health)
    end
})
```

### Model-Specific Registration

```lua
exports['nbl-contextmenu']:addModel(GetHashKey('prop_atm_01'), {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0,
    onSelect = function(entity, coords)
        TriggerEvent('banking:openATM')
    end
})
```

## 🎯 Advanced Features

### Real-time Option Updates

The menu automatically refreshes options based on `canInteract` conditions when open. Set `Config.Menu.refreshInterval` to control the refresh rate (0 to disable).

```lua
Config.Menu = {
    refreshInterval = 500  -- Refresh every 500ms
}
```

### Resource Auto-cleanup

When a resource stops, all its registered options are automatically removed. No manual cleanup needed!

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

### Manual Refresh

You can manually refresh options if needed:

```lua
exports['nbl-contextmenu']:refreshOptions()
```

## ⚡ Performance

- **0ms CPU when inactive**: Thread sleeps (Wait(500)) when Alt is not pressed
- **Efficient when active**: Optimized raycast with camera caching
- **Auto-cleanup thread**: Cleans invalid entities every 30 seconds
- **Outline cleanup**: Dedicated thread ensures outlines are removed when inactive
- **Smart refresh**: Only refreshes menu if options actually changed

## 🔧 Troubleshooting

### Outline not removing

The system includes a dedicated cleanup thread that forces outline removal. If issues persist:
1. Check `Config.Outline.enabled` is `true`
2. Verify entity type is in `Config.Outline.allowedTypes`
3. Ensure `allowSelfTarget = true` if targeting yourself

### Menu not opening

1. Check console for errors
2. Verify entity has registered options
3. Check `canInteract` returns `true`
4. Ensure distance is within `Config.Target.maxDistance`

### Options not updating

1. Check `Config.Menu.refreshInterval` is not `0`
2. Verify `canInteract` function is correct
3. Check console for errors in `canInteract`

### Self-targeting not working

1. Set `Config.Target.allowSelfTarget = true`
2. Use `addGlobalSelf()` instead of `addGlobalPlayer()`
3. Ensure `Config.Outline.allowedTypes.self = true`

## 📝 Notes

- The menu closes automatically when clicking outside or right-clicking
- Sub-menus have a 300ms delay before closing when moving mouse away
- Options with `shouldClose = true` will close the menu AND deactivate targeting
- All callbacks are protected with `pcall` to prevent crashes
- Resource cleanup is automatic - no need to manually remove options

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## 📄 License

This resource is open-source. Use it as you wish.

---

**Developed with ❤️ for the FiveM community**
