# RemoveGlobalObject

Remove a global object context menu option.

---

## Description

Removes a context menu option that was previously registered using `addGlobalObject`. The option will no longer appear when targeting objects.

---

## Syntax

```lua
local success = exports['nbl-target']:removeGlobalObject(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addGlobalObject` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a global object option
local id = exports['nbl-target']:addGlobalObject({
    label = "Examine Object",
    icon = "fas fa-eye",
    name = "examine_object",
    distance = 3.0
})

-- Later, remove it
local success = exports['nbl-target']:removeGlobalObject(id)
if success then
    print("Global object option removed")
end
```

---

## Important Notes

- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addGlobalObject` to remove the option
- Options are automatically removed when the resource stops (if registered properly)
- Removing an option that doesn't exist is safe and won't cause errors

