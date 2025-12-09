# RemoveModel

Remove a context menu option registered for a model.

---

## Description

Removes a context menu option that was previously registered using `addModel`. The option will no longer appear when targeting entities with that model.

---

## Syntax

```lua
local success = exports['nbl-target']:removeModel(id)
```

---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | `number` | Yes | The registration ID returned by `addModel` |

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the option was successfully removed, `false` if it didn't exist |

---

## Usage Examples

### Basic Removal

```lua
-- Register a model option
local id = exports['nbl-target']:addModel('prop_atm_01', {
    label = "Use ATM",
    icon = "fas fa-credit-card",
    name = "use_atm",
    distance = 2.0
})

-- Later, remove it
local success = exports['nbl-target']:removeModel(id)
if success then
    print("Model option removed")
end
```

### Remove Multiple Model Options

```lua
local modelIds = {}

-- Register options for multiple models
local models = {'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}
for _, model in ipairs(models) do
    local id = exports['nbl-target']:addModel(model, {
        label = "Use ATM",
        icon = "fas fa-credit-card",
        name = "use_atm_" .. model,
        distance = 2.0
    })
    table.insert(modelIds, id)
end

-- Remove all model options
for _, id in ipairs(modelIds) do
    exports['nbl-target']:removeModel(id)
end
```

---

## Important Notes

- Returns `false` if the ID doesn't exist or was already removed
- Use the ID returned by `addModel` to remove the option
- Removing a model option affects all entities with that model
- Removing an option that doesn't exist is safe and won't cause errors

