# RemoveByResource

Remove all context menu options registered by a specific resource.

---

## Description

Removes all context menu options that were registered by a specific resource. This is useful for cleanup when a resource stops or when you want to remove all options from a particular resource at once.

---

## Syntax

```lua
local count = exports['nbl-target']:removeByResource(resourceName)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `resourceName` | `string` | Yes | The name of the resource whose options should be removed |

---

## Return

| Type | Description |
|------|-------------|
| `number` | The number of options that were removed (0 if none were found) |

---

## Usage Examples

### Remove All Options from a Resource

```lua
-- Remove all options registered by 'myresource'
local count = exports['nbl-target']:removeByResource('myresource')
print("Removed " .. count .. " options from myresource")
```

### Cleanup on Resource Stop

```lua
-- This is automatically handled, but you can do it manually if needed
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == 'myresource' then
        local count = exports['nbl-target']:removeByResource('myresource')
        print("Cleaned up " .. count .. " options")
    end
end)
```

### Remove Options from Current Resource

```lua
-- Remove all options from the current resource
local resourceName = GetCurrentResourceName()
local count = exports['nbl-target']:removeByResource(resourceName)
print("Removed " .. count .. " options")
```

### Cleanup Multiple Resources

```lua
local resourcesToClean = {'resource1', 'resource2', 'resource3'}

for _, resourceName in ipairs(resourcesToClean) do
    local count = exports['nbl-target']:removeByResource(resourceName)
    if count > 0 then
        print("Removed " .. count .. " options from " .. resourceName)
    end
end
```

---

## Important Notes

- Options are **automatically removed** when a resource stops (handled by the system)
- Returns `0` if no options were found for that resource
- This removes **all** options registered by the resource (entities, models, globals, etc.)
- Useful for manual cleanup or when you want to reset a resource's options
- The resource name must match exactly (case-sensitive)

