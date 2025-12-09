# GetSelectedEntity

Get the entity handle of the currently selected entity (when menu is open).

---

## Description

Returns the entity handle of the entity that currently has the context menu open. Returns `nil` if the menu is not open.

---

## Syntax

```lua
local entity = exports['nbl-target']:getSelectedEntity()
```

---

## Parameters

None

---

## Return

| Type | Description |
|------|-------------|
| `number` or `nil` | The entity handle, or `nil` if menu is not open |

---

## Usage Examples

### Get Selected Entity

```lua
local entity = exports['nbl-target']:getSelectedEntity()

if entity then
    print("Menu is open for entity: " .. entity)
    local model = GetEntityModel(entity)
    print("Entity model: " .. model)
else
    print("Menu is not open")
end
```

### Check Entity Type When Menu is Open

```lua
local entity = exports['nbl-target']:getSelectedEntity()

if entity then
    if IsEntityAVehicle(entity) then
        print("Selected entity is a vehicle")
    elseif IsEntityAPed(entity) then
        print("Selected entity is a ped")
    elseif IsEntityAnObject(entity) then
        print("Selected entity is an object")
    end
end
```

### Get Entity Information

```lua
local entity = exports['nbl-target']:getSelectedEntity()

if entity then
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    
    print("Entity position: " .. tostring(coords))
    print("Entity heading: " .. heading)
end
```

---

## Important Notes

- Returns `nil` if the menu is not open
- This is a simplified version of `getCurrentTarget()` that only returns the entity handle
- Use `getCurrentTarget()` if you need more information (entity type, world position)
- Useful for quick entity access when you know the menu is open

