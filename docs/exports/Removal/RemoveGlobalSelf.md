# RemoveGlobalSelf

Remove a global self context menu option.

---

## Description

Removes a context menu option that was previously registered using `addGlobalSelf`. The option will no longer appear when targeting yourself.

---

## Syntax

```lua
local success = exports['nbl-target']:removeGlobalSelf(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addGlobalSelf` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a global self option
local id = exports['nbl-target']:addGlobalSelf({
    label = "Check Health",
    icon = "fas fa-heart",
    name = "check_health",
    distance = 5.0
})

-- Later, remove it
local success = exports['nbl-target']:removeGlobalSelf(id)
if success then
    print("Global self option removed")
end
```

---

## Important Notes

- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addGlobalSelf` to remove the option
- Options are automatically removed when the resource stops (if registered properly)
- Removing an option that doesn't exist is safe and won't cause errors

