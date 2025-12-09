# RemoveByName

Remove a context menu option by its name identifier.

---

## Description

Removes a context menu option using its `name` parameter instead of the registration ID. This is useful when you don't have access to the ID but know the option's name.

---

## Syntax

```lua
local success = exports['nbl-target']:removeByName(name)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name` | `string` | Yes | The unique name identifier of the option |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal by Name

```lua
-- Register an option with a name
exports['nbl-target']:addGlobalVehicle({
    label = "Enter Vehicle",
    icon = "fas fa-car-side",
    name = "enter_vehicle",  -- Unique name
    distance = 5.0
})

-- Later, remove it by name
local success = exports['nbl-target']:removeByName("enter_vehicle")
if success then
    print("Option removed by name")
end
```

### Remove Multiple Options by Name Pattern

```lua
-- Register multiple options with similar names
exports['nbl-target']:addGlobalVehicle({
    label = "Action 1",
    name = "myresource_action_1",
    distance = 3.0
})

exports['nbl-target']:addGlobalVehicle({
    label = "Action 2",
    name = "myresource_action_2",
    distance = 3.0
})

-- Remove all options from this resource
for i = 1, 2 do
    exports['nbl-target']:removeByName("myresource_action_" .. i)
end
```

### Remove Option Without ID

```lua
-- Sometimes you register an option but don't store the ID
exports['nbl-target']:addGlobalPed({
    label = "Talk",
    icon = "fas fa-comments",
    name = "talk_npc",
    distance = 2.0
})

-- Later, you can remove it by name without needing the ID
exports['nbl-target']:removeByName("talk_npc")
```

---

## Important Notes

- The option must have been registered with a `name` parameter
- Returns `false` if no option with that name exists
- Only one option can have a specific name (names are unique)
- Useful when you don't have access to the registration ID
- Removing an option that doesn't exist is safe and won't cause errors

