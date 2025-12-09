# RemoveGlobalPed

Remove a global ped context menu option.

---

## Description

Removes a context menu option that was previously registered using `addGlobalPed`. The option will no longer appear when targeting NPCs.

---

## Syntax

```lua
local success = exports['nbl-target']:removeGlobalPed(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addGlobalPed` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a global ped option
local id = exports['nbl-target']:addGlobalPed({
    label = "Talk",
    icon = "fas fa-comments",
    name = "talk_ped",
    distance = 2.0
})

-- Later, remove it
local success = exports['nbl-target']:removeGlobalPed(id)
if success then
    print("Global ped option removed")
end
```

---

## Important Notes

- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addGlobalPed` to remove the option
- Options are automatically removed when the resource stops (if registered properly)
- Removing an option that doesn't exist is safe and won't cause errors

