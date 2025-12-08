Config = {}

-- Configuration du feedback visuel (outline et marker)
Config.VisualFeedback = {
    -- Activer ou désactiver le feedback visuel au survol
    enabled = true,
    
    -- Utiliser l'outline (contour coloré autour de l'entité)
    useOutline = true,
    
    -- Afficher l'outline sur toutes les entités (true) ou uniquement sur les targetables (false)
    showOutlineOnAll = false,
    
    -- Utiliser le marker (marqueur 3D au-dessus de l'entité)
    useMarker = true,
    
    -- Couleur de l'outline (RGBA)
    outlineColor = {r = 255, g = 255, b = 0, a = 255},
    
    -- Type de marqueur (1 = cylindre, 2 = flèche, etc.)
    markerType = 1,
    
    -- Couleur du marqueur (RGBA)
    markerColor = {r = 255, g = 255, b = 0, a = 200},
    
    -- Taille du marqueur
    markerScale = 0.3,
    
    -- Hauteur du marqueur au-dessus de l'entité
    markerHeight = 1.5,
    
    -- Distance maximale pour afficher le feedback visuel
    maxDistance = 50.0,
    
    -- Types d'entités autorisés à avoir un outline (évite les crashes sur les peds)
    outlineAllowedTypes = {
        vehicle = true,  -- Les véhicules peuvent avoir un outline
        object = true,   -- Les objets peuvent avoir un outline
        ped = false      -- Les peds ne peuvent pas avoir d'outline (crash possible)
    }
}

-- Configuration du système de raycast
Config.Target = {
    -- Distance maximale pour le raycast (en mètres)
    maxDistance = 10000.0,
    
    -- Flags pour le raycast (-1 = tous les types d'entités)
    raycastFlags = -1
}

-- Configuration des contrôles
Config.Controls = {
    -- Touche pour activer le mode target (LMENU = Alt gauche)
    activationKey = 'LMENU',
    
    -- Contrôle pour le clic (24 = clic gauche)
    clickKey = 24
}

-- Liste des contrôles à désactiver pendant le mode target
Config.DisableControls = {
    1,    -- Look Left/Right
    2,    -- Look Up/Down
    24,   -- Attack (clic gauche)
    25,   -- Aim
    68,   -- Vehicle Mouse Control Override
    69,   -- Vehicle Mouse Control Override
    70,   -- Vehicle Mouse Control Override
    91,   -- Vehicle Mouse Control Override
    92,   -- Vehicle Mouse Control Override
    330,  -- Vehicle Mouse Control Override
    331,  -- Vehicle Mouse Control Override
    347,  -- Vehicle Mouse Control Override
    257   -- Attack 2
}

-- Configuration du système de registre
Config.Registry = {
    -- Autoriser de se viser soi-même (false = comme OX-Target)
    allowSelfTargeting = false,
    
    -- Distance par défaut pour les interactions
    defaultDistance = 5.0
}

-- Configuration du curseur
Config.Cursor = {
    -- Curseur normal (par défaut)
    normal = 0,
    
    -- Curseur quand on survole une entité targetable
    targetable = 1,
    
    -- Curseur quand on survole une entité non targetable
    notTargetable = 0
}
