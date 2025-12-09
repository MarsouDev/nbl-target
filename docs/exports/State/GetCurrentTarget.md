# GetCurrentTarget

Get information about the currently hovered or selected entity.

---

## Description

Returns a table containing information about the entity that is currently being hovered (when targeting is active) or selected (when menu is open). Returns `nil` if no entity is being targeted.

---

## Syntax

```lua
local target = exports['nbl-target']:getCurrentTarget()
```

---

## Parameters

None

---

## Return

| Type | Description |
|------|-------------|
| `table` or `nil` | Table with entity information, or `nil` if no target |

### Return Table Structure

| Field | Type | Description |
|-------|------|-------------|
| `entity` | `number` | The entity handle |
| `entityType` | `string` | The entity type (`"vehicle"`, `"ped"`, `"player"`, `"object"`, `"self"`, etc.) |
| `worldPos` | `vector3` | The world position of the entity |

---

## Usage Examples

### Get Current Target Information

```lua
local target = exports['nbl-target']:getCurrentTarget()

if target then
    print("Entity: " .. target.entity)
    print("Type: " .. target.entityType)
    print("Position: " .. tostring(target.worldPos))
else
    print("No target")
end
```

### Check Target Type

```lua
local target = exports['nbl-target']:getCurrentTarget()

if target then
    if target.entityType == "vehicle" then
        print("Targeting a vehicle")
    elseif target.entityType == "ped" then
        print("Targeting a ped")
    elseif target.entityType == "player" then
        print("Targeting a player")
    end
end
```

### Get Target Entity

```lua
local target = exports['nbl-target']:getCurrentTarget()

if target then
    local entity = target.entity
    local coords = target.worldPos
    
    -- Do something with the entity
    DrawMarker(1, coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
end
```

### Monitor Target Changes

```lua
local lastTarget = nil

CreateThread(function()
    while true do
        Wait(100)
        
        local target = exports['nbl-target']:getCurrentTarget()
        
        if target and target.entity ~= lastTarget then
            print("New target: " .. target.entityType)
            lastTarget = target.entity
        end
    end
end)
```

---

## Important Notes

- Returns `nil` if no entity is being targeted
- Returns hovered entity when targeting is active but menu is closed
- Returns selected entity when menu is open
- The `worldPos` is the position where the raycast hit the entity
- Useful for getting entity information without needing to store it yourself

