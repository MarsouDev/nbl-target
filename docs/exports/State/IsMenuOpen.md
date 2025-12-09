# IsMenuOpen

Check if the context menu is currently open.

---

## Description

Returns whether the context menu NUI is currently open and visible to the player.

---

## Syntax

```lua
local isOpen = exports['nbl-target']:isMenuOpen()
```

---

## Parameters

None

---

## Return

| Type | Description |
|------|-------------|
| `boolean` | `true` if the menu is open, `false` otherwise |

---

## Usage Examples

### Check if Menu is Open

```lua
local isOpen = exports['nbl-target']:isMenuOpen()
if isOpen then
    print("Context menu is open")
else
    print("Context menu is closed")
end
```

### Disable Actions When Menu is Open

```lua
CreateThread(function()
    while true do
        Wait(0)
        
        if exports['nbl-target']:isMenuOpen() then
            -- Disable certain actions when menu is open
            DisableControlAction(0, 24, true)  -- Disable attack
            DisableControlAction(0, 25, true)  -- Disable aim
        end
    end
end)
```

### Show Custom UI Only When Menu is Closed

```lua
CreateThread(function()
    while true do
        Wait(100)
        
        local menuOpen = exports['nbl-target']:isMenuOpen()
        SendNUIMessage({
            action = "setMenuState",
            menuOpen = menuOpen
        })
    end
end)
```

---

## Important Notes

- Returns `true` when the menu is visible on screen
- Returns `false` when the menu is closed or not visible
- The menu opens when clicking on an entity with available options
- Useful for conditionally enabling/disabling features based on menu state

