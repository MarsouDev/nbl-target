# NBL Context Menu

Un système de ciblage et de menu contextuel avancé pour FiveM, compatible avec OX-Target et offrant des fonctionnalités supplémentaires.

## 📋 Informations

- **Langage** : Lua 5.4
- **Version FiveM** : Cerulean
- **Performance** : 0ms quand inactif (thread en veille), optimisé pour une utilisation minimale des ressources

## ✨ Fonctionnalités

- 🎯 **Système de ciblage avancé** : Détection précise des entités (véhicules, peds, objets, sol, ciel)
- 🖱️ **Feedback visuel** : Outline et marker au survol des entités
- 🎨 **Curseur dynamique** : Changement de curseur selon l'état de l'entité
- 📦 **Système de registre** : Enregistrement d'entités spécifiques ou de types globaux
- 🔧 **Actions multiples** : Support pour exports, events, serverEvents, commands
- ⚡ **Optimisé** : Thread en veille quand inactif (0ms de CPU)
- 🛡️ **Gestion d'erreurs** : Protection complète contre les crashes

## 🚀 Installation

1. Placez le dossier `nbl-contextmenu` dans votre dossier `resources`
2. Ajoutez `ensure nbl-contextmenu` dans votre `server.cfg`
3. Redémarrez votre serveur

## ⚙️ Configuration

Toute la configuration se trouve dans `config/config.lua`. Voici les principales options :

### Feedback visuel
```lua
Config.VisualFeedback = {
    enabled = true,              -- Activer/désactiver le feedback visuel
    useOutline = true,           -- Utiliser l'outline
    useMarker = true,            -- Utiliser le marker
    outlineColor = {r = 255, g = 255, b = 0, a = 255},  -- Couleur outline
    markerType = 1,              -- Type de marqueur
    markerColor = {r = 255, g = 255, b = 0, a = 200},   -- Couleur marker
    maxDistance = 50.0,          -- Distance maximale
    outlineAllowedTypes = {
        vehicle = true,          -- Outline sur véhicules
        object = true,           -- Outline sur objets
        ped = false              -- Outline sur peds (désactivé pour éviter crashes)
    }
}
```

### Curseur
```lua
Config.Cursor = {
    normal = 0,                  -- Curseur normal
    targetable = 1,              -- Curseur quand entité targetable
    notTargetable = 0            -- Curseur quand entité non targetable
}
```

### Contrôles
```lua
Config.Controls = {
    activationKey = 'LMENU',     -- Touche pour activer (Alt gauche)
    clickKey = 24                -- Contrôle pour le clic (clic gauche)
}
```

## 📖 Utilisation

### Activation

Le système s'active en maintenant la touche **Alt** (par défaut). Relâchez pour désactiver.

### Enregistrer une entité spécifique

```lua
local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
local targetId = exports['nbl-contextmenu']:addEntity(vehicle, {
    label = "Ouvrir le coffre",
    name = "open_trunk",
    icon = "fa-solid fa-box",
    distance = 3.0,
    canInteract = function(entity, distance, coords, name, bone)
        return not IsVehicleLocked(entity)
    end,
    onSelect = function(entity, coords, registration)
        print("Coffre ouvert!")
    end
})
```

### Enregistrer un type global

```lua
-- Tous les véhicules
local targetId = exports['nbl-contextmenu']:addGlobalVehicle({
    label = "Entrer dans le véhicule",
    name = "enter_vehicle",
    distance = 5.0,
    canInteract = function(entity, distance, coords, name, bone)
        return not IsVehicleLocked(entity) and distance <= 3.0
    end,
    onSelect = function(entity, coords, registration)
        TaskEnterVehicle(PlayerPedId(), entity, 10000, -1, 1.0, 1, 0)
    end
})

-- Tous les objets
exports['nbl-contextmenu']:addGlobalObject({
    label = "Inspecter",
    name = "inspect_object",
    onSelect = function(entity, coords, registration)
        print("Objet inspecté!")
    end
})

-- Tous les peds
exports['nbl-contextmenu']:addGlobalPed({
    label = "Parler",
    name = "talk_ped",
    onSelect = function(entity, coords, registration)
        print("Conversation démarrée!")
    end
})

-- Tous les joueurs
exports['nbl-contextmenu']:addGlobalPlayer({
    label = "Interagir",
    name = "interact_player",
    onSelect = function(entity, coords, registration)
        print("Interaction avec joueur!")
    end
})
```

### Enregistrer un modèle spécifique

```lua
exports['nbl-contextmenu']:addModel(GetHashKey('prop_atm_01'), {
    label = "Utiliser l'ATM",
    name = "use_atm",
    distance = 2.0,
    onSelect = function(entity, coords, registration)
        print("ATM utilisé!")
    end
})
```

### Options globales (sol/ciel)

```lua
-- Clic sur le sol
exports['nbl-contextmenu']:addGlobalOption('ground', {
    label = "Placer un objet",
    name = "place_object",
    onSelect = function(entity, coords, registration)
        CreateObject(GetHashKey('prop_chair_01a'), coords.x, coords.y, coords.z, true, true, true)
    end
})

-- Clic dans le ciel
exports['nbl-contextmenu']:addGlobalOption('sky', {
    label = "Action spéciale",
    name = "special_action",
    onSelect = function(entity, coords, registration)
        print("Action spéciale!")
    end
})
```

### Utiliser des actions (export, event, serverEvent, command)

```lua
-- Export
exports['nbl-contextmenu']:addGlobalVehicle({
    label = "Réparer",
    name = "repair_vehicle",
    export = "mechanic.repair",  -- Format: "resource.export"
    distance = 3.0
})

-- Event client
exports['nbl-contextmenu']:addGlobalObject({
    label = "Ouvrir",
    name = "open_object",
    event = "myresource:openObject",
    distance = 2.0
})

-- Event serveur
exports['nbl-contextmenu']:addGlobalPed({
    label = "Voler",
    name = "steal_ped",
    serverEvent = "myresource:stealPed",
    distance = 1.5
})

-- Commande
exports['nbl-contextmenu']:addGlobalVehicle({
    label = "Réparer",
    name = "repair_cmd",
    command = "repair",
    distance = 3.0
})
```

### Retirer une option

```lua
-- Par ID
exports['nbl-contextmenu']:removeEntity(targetId)

-- Par nom (pour les types globaux)
exports['nbl-contextmenu']:removeGlobalVehicle("enter_vehicle")
exports['nbl-contextmenu']:removeGlobalObject("inspect_object")
exports['nbl-contextmenu']:removeGlobalPed("talk_ped")
exports['nbl-contextmenu']:removeGlobalPlayer("interact_player")
```

### Désactiver le targeting

```lua
exports['nbl-contextmenu']:disableTargeting()
```

## 🔌 API Complète

### Exports disponibles

| Fonction | Description | Paramètres | Retour |
|----------|-------------|------------|--------|
| `disableTargeting()` | Désactive le targeting | - | - |
| `addEntity(entity, options)` | Ajoute une entité spécifique | entity, options | id |
| `removeEntity(id)` | Retire une entité | id | boolean |
| `addLocalEntity(entity, options)` | Ajoute une entité locale | entity, options | id |
| `removeLocalEntity(id)` | Retire une entité locale | id | boolean |
| `addGlobalType(entityType, options)` | Ajoute un type global | entityType, options | id |
| `addGlobalOption(optionType, options)` | Ajoute une option globale | optionType, options | id |
| `removeGlobalOption(id)` | Retire une option globale | id | boolean |
| `addGlobalObject(options)` | Ajoute tous les objets | options | id |
| `removeGlobalObject(name)` | Retire les objets | name | boolean |
| `addGlobalPed(options)` | Ajoute tous les peds | options | id |
| `removeGlobalPed(name)` | Retire les peds | name | boolean |
| `addGlobalPlayer(options)` | Ajoute tous les joueurs | options | id |
| `removeGlobalPlayer(name)` | Retire les joueurs | name | boolean |
| `addGlobalVehicle(options)` | Ajoute tous les véhicules | options | id |
| `removeGlobalVehicle(name)` | Retire les véhicules | name | boolean |
| `addModel(model, options)` | Ajoute un modèle spécifique | model, options | id |
| `removeModel(id)` | Retire un modèle | id | boolean |

### Options disponibles

| Option | Type | Description | Requis |
|--------|------|-------------|--------|
| `label` | string | Texte de l'interaction | Oui |
| `name` | string | Identifiant unique (pour retirer) | Non |
| `icon` | string | Icône Font Awesome | Non |
| `distance` | number | Distance maximale | Non (défaut: 5.0) |
| `canInteract` | function | Condition pour afficher | Non |
| `onSelect` | function | Callback au clic | Non |
| `export` | string | Export à appeler | Non |
| `event` | string | Event client | Non |
| `serverEvent` | string | Event serveur | Non |
| `command` | string | Commande à exécuter | Non |
| `enabled` | boolean | Activer/désactiver | Non (défaut: true) |

### Types d'entités

- `self` : Le joueur lui-même
- `vehicle` : Tous les véhicules
- `player` : Tous les joueurs
- `ped` : Tous les peds (NPCs)
- `object` : Tous les objets
- `ground` : Le sol
- `sky` : Le ciel (clic dans le vide)

### Callback canInteract

```lua
canInteract = function(entity, distance, coords, name, bone)
    -- entity: L'entité ciblée (nil pour ground/sky)
    -- distance: Distance du joueur à l'entité
    -- coords: Coordonnées du point de collision
    -- name: Nom de l'option (si défini)
    -- bone: Bone ID (pour les peds, nil pour l'instant)
    
    -- Retourner true pour afficher l'option, false pour la cacher
    return distance <= 3.0
end
```

### Callback onSelect

```lua
onSelect = function(entity, coords, registration)
    -- entity: L'entité ciblée (nil pour ground/sky)
    -- coords: Coordonnées du point de collision
    -- registration: L'objet d'enregistrement complet
    
    -- Votre code ici
end
```

## 🎯 Exemples complets

### Exemple 1 : Système de coffre de véhicule

```lua
-- Client
CreateThread(function()
    while true do
        Wait(1000)
        
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            exports['nbl-contextmenu']:addEntity(vehicle, {
                label = "Ouvrir le coffre",
                name = "open_trunk",
                icon = "fa-solid fa-box",
                distance = 3.0,
                canInteract = function(entity, distance, coords, name, bone)
                    return not IsVehicleLocked(entity) and distance <= 3.0
                end,
                onSelect = function(entity, coords, registration)
                    TriggerServerEvent('trunk:open', entity)
                end
            })
        end
    end
end)
```

### Exemple 2 : ATM interactif

```lua
-- Client
exports['nbl-contextmenu']:addModel(GetHashKey('prop_atm_01'), {
    label = "Utiliser l'ATM",
    name = "use_atm",
    icon = "fa-solid fa-credit-card",
    distance = 2.0,
    canInteract = function(entity, distance, coords, name, bone)
        return distance <= 2.0
    end,
    onSelect = function(entity, coords, registration)
        TriggerEvent('banking:openATM')
    end
})
```

### Exemple 3 : Interaction avec les joueurs

```lua
-- Client
exports['nbl-contextmenu']:addGlobalPlayer({
    label = "Fouiller",
    name = "search_player",
    icon = "fa-solid fa-magnifying-glass",
    distance = 2.0,
    canInteract = function(entity, distance, coords, name, bone)
        local targetPed = entity
        return not IsPedDeadOrDying(targetPed, true) and distance <= 2.0
    end,
    serverEvent = "police:searchPlayer",
    distance = 2.0
})
```

## 🔧 Optimisations

Le script est optimisé pour une performance maximale :

- **Thread en veille** : Quand Alt n'est pas pressé, le thread dort (Wait(500)) = 0ms CPU
- **Thread actif** : Quand Alt est pressé, le thread tourne à Wait(0) pour une réactivité maximale
- **Gestion d'erreurs** : Toutes les natives sont protégées avec pcall pour éviter les crashes
- **Vérifications** : Toutes les entités sont validées avant utilisation

## 🛡️ Gestion d'erreurs

Le script inclut une gestion d'erreurs complète :

- Protection de toutes les natives avec `pcall`
- Vérification de validité des entités avant utilisation
- Messages d'erreur clairs en cas de problème
- Fallback pour éviter les crashes

## 📝 Notes

- Le système est compatible avec OX-Target (même API)
- Support pour `ground` et `sky` (non disponible dans OX-Target)
- Impossible de se viser soi-même par défaut (comme OX-Target)
- Le curseur change automatiquement au survol d'une entité targetable

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## 📄 License

Ce script est sous licence libre. Utilisez-le comme vous le souhaitez.

---

**Développé avec ❤️ pour la communauté FiveM**
