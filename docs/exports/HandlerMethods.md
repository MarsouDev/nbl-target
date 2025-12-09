# Handler Methods

Methods available on handler objects returned by registration exports.

---

## Description

All registration exports (`addEntity`, `addModel`, `addGlobalVehicle`, etc.) return a **handler object** that provides methods to dynamically control the registered option. This allows you to update properties, enable/disable, or remove the option without needing to store the registration ID.

---

## Available Methods

### `:setLabel(label)`

Change the option label dynamically.

**Parameters:**
- `label` (string) - The new label text

**Returns:** `handler` (chainable)

**Example:**
```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock"
})

-- Change label
target:setLabel("Unlock Vehicle")
```

---

### `:setIcon(icon)`

Change the option icon.

**Parameters:**
- `icon` (string) - Font Awesome icon class

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setIcon("fas fa-lock-open")
```

---

### `:setEnabled(enabled)`

Enable or disable the option.

**Parameters:**
- `enabled` (boolean) - `true` to enable, `false` to disable

**Returns:** `handler` (chainable)

**Example:**
```lua
-- Temporarily disable
target:setEnabled(false)

-- Re-enable
target:setEnabled(true)
```

---

### `:setDistance(distance)`

Change the interaction distance.

**Parameters:**
- `distance` (number) - Maximum interaction distance in meters

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setDistance(5.0)
```

---

### `:setCanInteract(fn)`

Change the canInteract function.

**Parameters:**
- `fn` (function) - New canInteract function

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setCanInteract(function(entity, distance, worldPos, name, bone)
    return distance <= 2.0 and not IsVehicleLocked(entity)
end)
```

---

### `:setOnSelect(fn)`

Change the onSelect callback.

**Parameters:**
- `fn` (function) - New onSelect callback

**Returns:** `handler` (chainable)

**Example:**
```lua
target:setOnSelect(function(entity, coords, registration)
    print("New callback!")
end)
```

---

### `:remove()`

Remove the registration(s).

**Returns:** `boolean` - `true` if removed successfully

**Example:**
```lua
target:remove()
```

---

### `:getId()`

Get the registration ID(s).

**Returns:** 
- `number` - Single ID if one registration
- `table` - Array of IDs if multiple registrations (e.g., from array input)

**Example:**
```lua
local id = target:getId()
print("Registration ID: " .. id)
```

---

## Method Chaining

All methods except `:remove()` and `:getId()` return the handler object, allowing you to chain multiple calls:

```lua
target:setLabel("New Label")
    :setIcon("fas fa-star")
    :setDistance(5.0)
    :setEnabled(true)
```

---

## Usage Examples

### Dynamic Label Updates

```lua
local target = exports['nbl-target']:addGlobalVehicle({
    label = "Lock Vehicle",
    icon = "fas fa-lock"
})

-- Update based on vehicle state
CreateThread(function()
    while true do
        Wait(1000)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            if IsVehicleLocked(vehicle) then
                target:setLabel("Unlock Vehicle"):setIcon("fas fa-lock-open")
            else
                target:setLabel("Lock Vehicle"):setIcon("fas fa-lock")
            end
        end
    end
end)
```

### Conditional Enabling

```lua
local target = exports['nbl-target']:addGlobalPed({
    label = "Search",
    icon = "fas fa-search"
})

-- Only enable for police
RegisterNetEvent('job:update', function(job)
    target:setEnabled(job == 'police')
end)
```

### Multiple Updates

```lua
local target = exports['nbl-target']:addModel('prop_atm_01', {
    label = "ATM",
    distance = 2.0
})

-- Update multiple properties
target:setLabel("Bank ATM")
    :setIcon("fas fa-university")
    :setDistance(3.0)
```

---

## Important Notes

- Handler methods work on all registrations created by the handler (useful when using arrays)
- Changes take effect immediately and are reflected in the menu on next refresh
- The `:remove()` method removes all registrations associated with the handler
- Method chaining is supported for all setter methods
- Handler methods are protected and won't crash if the registration doesn't exist

