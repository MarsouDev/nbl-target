# Nebula Target

Modern context menu and targeting system for FiveM.

---

## Description

**Nebula Target** is a powerful and flexible targeting system that allows players to interact with entities (vehicles, peds, objects, players) through a modern context menu interface. Hold the activation key (default: Left Alt) to enter targeting mode, then click on any entity to open a context menu with available interaction options.

---

## Key Features

- 🎯 **Advanced Targeting System**: Precise entity detection with raycast
- 🖱️ **Visual Feedback**: Outline and 3D markers on hover
- 🎨 **Modern NUI Menu**: Beautiful dark-themed context menu with animations
- 📦 **Flexible Registration**: Register options for specific entities, models, or global types
- 📋 **Sub-menus**: Nested options with hover support
- ⚡ **Real-time Updates**: Auto-refresh options based on conditions
- 🔧 **Multiple Actions**: Support for exports, events, serverEvents, commands
- 🛡️ **Error Handling**: Complete protection against crashes
- ⚡ **Optimized**: Efficient resource usage with smart performance management

---

## Quick Start

1. **Installation**: Follow the [Installation Guide](./Installation.md)
2. **Configuration**: Customize settings in `config/config.lua`
3. **Register Options**: Use the [Registration exports](./exports/Registration/) to add interaction options
4. **Control**: Use [Control exports](./exports/Control/) to manage the system state

---

## Documentation Structure

- **[Installation](./Installation.md)**: Setup and installation guide
- **[Exports](./exports/)**: Complete API reference
  - **[State](./exports/State/)**: Check system and menu state
  - **[Control](./exports/Control/)**: Control system behavior
  - **[Registration](./exports/Registration/)**: Register interaction options
  - **[Removal](./exports/Removal/)**: Remove registered options

---

## Basic Usage Example

```lua
-- Register an option for all vehicles
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

---

**Developed with ❤️ for the FiveM community**

