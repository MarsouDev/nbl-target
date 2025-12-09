--[[
    NBL Context Menu - Configuration
    
    All colors use RGBA format: {r, g, b, a}
    r, g, b = 0-255
    a = 0-255 (transparency)
]]

Config = {}

-- ============================================================================
-- CONTROLS
-- ============================================================================
Config.Controls = {
    -- Key to activate targeting mode (hold to use)
    -- Common keys: 'LMENU' (Left Alt), 'LCONTROL' (Left Ctrl), 'LSHIFT' (Left Shift)
    activationKey = 'LMENU',
    
    -- Mouse button to select/click (24 = Left Click, 25 = Right Click)
    selectKey = 24
}

-- ============================================================================
-- TARGETING
-- ============================================================================
Config.Target = {
    -- Maximum distance for raycast detection (in meters)
    maxDistance = 10.0,
    
    -- Raycast flags (-1 = all entity types)
    -- 1 = World, 2 = Vehicles, 4 = Peds, 8 = Objects, 16 = Water, 32 = Foliage
    raycastFlags = -1,
    
    -- Allow targeting yourself (set to true for self-interaction menus)
    allowSelfTarget = true,
    
    -- Default interaction distance for options
    defaultDistance = 3.0
}

-- ============================================================================
-- OUTLINE (Entity highlight border)
-- ============================================================================
Config.Outline = {
    -- Enable/disable outline effect
    enabled = true,
    
    -- Outline color (RGBA)
    color = {r = 255, g = 255, b = 0, a = 255},
    
    -- Entity types that can have outline
    -- Set to true to enable outline for each type
    allowedTypes = {
        vehicle = true,
        object = true,
        ped = true,
        player = true,
        self = true
    }
}

-- ============================================================================
-- MARKER (3D marker above entity)
-- ============================================================================
Config.Marker = {
    -- Enable/disable 3D marker
    enabled = true,
    
    -- Marker type (see https://docs.fivem.net/docs/game-references/markers/)
    -- 1 = Cylinder, 2 = Arrow down, 25 = Horizontal circle, 27 = Arrow
    type = 2,
    
    -- Marker color (RGBA)
    color = {r = 255, g = 255, b = 0, a = 200},
    
    -- Marker scale
    scale = 0.3,
    
    -- Height above entity (in meters)
    height = 1.0,
    
    -- Rotate marker (for visual effect)
    rotate = true,
    
    -- Bobbing animation (up and down)
    bob = true
}

-- ============================================================================
-- MENU (NUI Context Menu)
-- ============================================================================
Config.Menu = {
    -- Menu scale (1.0 = 100%)
    scale = 1.0,
    
    -- Maximum options visible without scrolling
    maxVisibleOptions = 8,
    
    -- Delay before showing submenu (in milliseconds)
    subMenuDelay = 150,
    
    -- Animation duration (in milliseconds)
    animationDuration = 150,
    
    -- Close menu when releasing activation key
    closeOnKeyRelease = true,
    
    -- Refresh interval when menu is open (in milliseconds)
    -- Updates canInteract conditions in real-time
    -- Set to 0 to disable auto-refresh
    refreshInterval = 500
}

-- ============================================================================
-- DEBUG
-- ============================================================================
Config.Debug = {
    -- Enable debug prints in console
    enabled = false
}

-- ============================================================================
-- DISABLED CONTROLS (while targeting mode is active)
-- ============================================================================
Config.DisabledControls = {
    1,    -- Look Left/Right
    2,    -- Look Up/Down
    24,   -- Attack
    25,   -- Aim
    37,   -- Select Weapon
    68,   -- Vehicle Aim
    69,   -- Vehicle Attack
    70,   -- Vehicle Attack 2
    91,   -- Vehicle Passenger Aim
    92,   -- Vehicle Passenger Attack
    106,  -- Vehicle Mouse Control Override
    114,  -- Fly Attack
    140,  -- Melee Attack Light
    141,  -- Melee Attack Heavy
    142,  -- Melee Attack Alternate
    257,  -- Attack 2
    263,  -- Melee Attack 1
    264,  -- Melee Attack 2
    330,  -- Melee Attack
    331   -- Melee Block
}
