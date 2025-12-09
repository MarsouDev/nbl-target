# RemoveGlobalPlayer

Remove a global player context menu option.

---

## Description

Removes a context menu option that was previously registered using `addGlobalPlayer`. The option will no longer appear when targeting players.

---

## Syntax

```lua
local success = exports['nbl-target']:removeGlobalPlayer(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addGlobalPlayer` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a global player option
local id = exports['nbl-target']:addGlobalPlayer({
    label = "Interact",
    icon = "fas fa-user",
    name = "interact_player",
    distance = 2.0
})

-- Later, remove it
local success = exports['nbl-target']:removeGlobalPlayer(id)
if success then
    print("Global player option removed")
end
```

---

## Important Notes

- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addGlobalPlayer` to remove the option
- Options are automatically removed when the resource stops (if registered properly)
- Removing an option that doesn't exist is safe and won't cause errors

