# Exports

Complete API reference for all available exports.

---

## Description

This section provides a complete list of all available exports in Nebula Target. Exports are organized by category to help you quickly find what you need.

---

## Categories

### [State](./State/)

Exports to check the current state of the targeting system and menu. Use these to query if targeting is active, if the menu is open, or to get information about the current target.

**Exports**: `isActive`, `isMenuOpen`, `isEnabled`, `getCurrentTarget`, `getSelectedEntity`

---

### [Control](./Control/)

Exports to control the targeting system behavior. Enable or disable the registry, activate/deactivate targeting mode, or close the menu.

**Exports**: `enable`, `disable`, `deactivate`, `closeMenu`

---

### [Registration](./Registration/)

Exports to register context menu options for entities. Register options for specific entities, models, or global entity types (vehicles, peds, players, objects, self).

**Exports**: `addEntity`, `addLocalEntity`, `addModel`, `addGlobalVehicle`, `addGlobalPed`, `addGlobalPlayer`, `addGlobalSelf`, `addGlobalObject`, `addGlobalOption`

---

### [Removal](./Removal/)

Exports to remove registered context menu options. Remove options by ID, by name, or remove all options from a specific resource.

**Exports**: `removeEntity`, `removeLocalEntity`, `removeModel`, `removeGlobalVehicle`, `removeGlobalPed`, `removeGlobalPlayer`, `removeGlobalSelf`, `removeGlobalObject`, `removeGlobalOption`, `removeByName`, `removeByResource`

---

## Handler Methods

All registration exports return a handler object with methods to dynamically control options. See [Handler Methods](./HandlerMethods.md) for complete documentation.

## Quick Reference

| Category | Count | Purpose |
|----------|-------|---------|
| State | 5 | Query system state |
| Control | 4 | Control system behavior |
| Registration | 9 | Register options |
| Removal | 12 | Remove options |

---

## Getting Started

1. Check the [State exports](./State/) to understand the current system state
2. Use [Registration exports](./Registration/) to add interaction options
3. Use [Control exports](./Control/) to manage the system
4. Use [Removal exports](./Removal/) to clean up options when needed

