# RemoveLocalEntity

Remove a context menu option registered for a local entity.

---

## Description

Removes a context menu option that was previously registered using `addLocalEntity`. The option will no longer appear when targeting that local entity.

---

## Syntax

```lua
local success = exports['nbl-target']:removeLocalEntity(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addLocalEntity` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a local entity option
local object = CreateObject(GetHashKey('prop_atm_01'), coords.x, coords.y, coords.z, false, false, false)
local id = exports['nbl-target']:addLocalEntity(object, {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0
})

-- Later, remove it
local success = exports['nbl-target']:removeLocalEntity(id)
if success then
    print("Local entity option removed")
end
```

### Remove When Entity is Deleted

```lua
local object = CreateObject(GetHashKey('prop_atm_01'), coords.x, coords.y, coords.z, false, false, false)
local optionId = exports['nbl-target']:addLocalEntity(object, {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0
})

-- Remove option when object is deleted
CreateThread(function()
    while true do
        Wait(1000)
        if not DoesEntityExist(object) then
            exports['nbl-target']:removeLocalEntity(optionId)
            break
        end
    end
end)
```

---

## Important Notes

- The option is automatically removed when the local entity is deleted
- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addLocalEntity` to remove the option
- Local entities are cleaned up automatically when invalid

