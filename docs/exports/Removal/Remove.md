# Remove

Generic function to remove any registration by handler or ID.

---

## Description

Removes a context menu option registration. This is a generic function that works with handler objects (returned by registration exports) or registration IDs. It automatically detects the registration type and removes it.

---

## Syntax

```lua
local success = exports['nbl-target']:remove(handlerOrId)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `handlerOrId` | `handler` or `number` | Yes | Handler object from registration export, or registration ID |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the registration was removed successfully, `false` otherwise |

---

## Usage Examples

### Using Handler

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Custom Action",
    icon = "fas fa-star"
})

-- Remove using handler
local success = exports['nbl-target']:remove(target)
```

### Using ID

```lua
local id = exports['nbl-target']:addGlobalVehicle({
    label = "Custom Action",
    icon = "fas fa-star"
})

-- Remove using ID
local success = exports['nbl-target']:remove(id)
```

### Using Handler Method (Recommended)

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Custom Action",
    icon = "fas fa-star"
})

-- Preferred method
target:remove()
```

---

## Important Notes

- Works with handler objects or numeric IDs
- Automatically detects the registration type
- Returns `false` if the registration doesn't exist
- Prefer using `handler:remove()` for better code clarity

