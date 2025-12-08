# Propositions d'améliorations pour NBL Context Menu

## 🔧 Problèmes identifiés et solutions

### 1. Outline qui reste après avoir lâché Alt
**Problème** : Quand on lâche Alt, l'outline reste sur les entités.

**Solution implémentée** :
- ✅ Amélioration de `MouseSystem:Deactivate()` pour nettoyer complètement
- ✅ Appel de `ClearPreviousEntity()` en plus de `ClearHighlight()`

**Amélioration possible** :
- Ajouter un système de nettoyage forcé de toutes les entités avec outline actif
- Vérifier périodiquement si le mode est actif et nettoyer si nécessaire

### 2. Détection de plusieurs entités en même temps
**Problème** : Parfois on vise deux entités en même temps (ex: deux poubelles).

**Solutions proposées** :

#### Option A : Priorité par distance (Recommandé)
- Choisir l'entité la plus proche du joueur
- Plus simple et efficace

#### Option B : Priorité par type d'entité
- Ordre de priorité : Vehicle > Player > Ped > Object
- Plus complexe mais plus précis

#### Option C : Priorité par centre de l'écran
- Choisir l'entité la plus proche du centre du curseur
- Bon compromis

#### Option D : Système de raycast multiple
- Faire plusieurs raycasts et choisir le meilleur
- Plus lourd en performance

**Recommandation** : Option A (distance) + Option C (centre écran) combinées

### 3. Curseur qui ne change pas
**Problème** : Le curseur ne change pas quand on passe sur une entité sans registration.

**Solutions proposées** :

#### Option A : Curseur uniquement sur targetables (Recommandé)
- Curseur change uniquement si l'entité a des registrations valides
- Plus cohérent avec le système

#### Option B : Curseur sur toutes les entités
- Curseur change sur toutes les entités (targetable ou non)
- Plus visuel mais peut être confus

#### Option C : Curseur conditionnel
- Curseur différent selon le type d'entité
- Plus informatif

**Recommandation** : Option A (déjà implémenté, mais améliorer la détection)

### 4. Outline sur toutes les entités ou uniquement targetables ?
**Problème** : Faut-il afficher l'outline sur toutes les entités ou uniquement celles targetables ?

**Solutions proposées** :

#### Option A : Outline uniquement sur targetables (Recommandé)
- Plus propre visuellement
- Indique clairement ce qui est interactif
- **Config ajoutée** : `showOutlineOnAll = false`

#### Option B : Outline sur toutes les entités
- Plus visuel
- Permet de voir toutes les entités
- **Config ajoutée** : `showOutlineOnAll = true`

#### Option C : Outline avec couleur différente
- Outline vert pour targetables, jaune pour non-targetables
- Meilleur des deux mondes

**Recommandation** : Option A par défaut, avec possibilité de changer via config

## 💡 Améliorations supplémentaires proposées

### 1. Système de priorité d'entités
```lua
Config.TargetPriority = {
    vehicle = 4,
    player = 3,
    ped = 2,
    object = 1
}
```
- Choisir l'entité avec la priorité la plus élevée
- En cas d'égalité, choisir la plus proche

### 2. Distance minimale pour le raycast
```lua
Config.Target = {
    minDistance = 0.5,  -- Distance minimale pour éviter les entités trop proches
    maxDistance = 10000.0
}
```
- Éviter de cibler des entités collées au joueur
- Améliorer la précision

### 3. Système de filtrage d'entités
```lua
Config.Filter = {
    ignoreDeadPeds = true,
    ignoreLockedVehicles = false,
    ignoreInvisibleEntities = true
}
```
- Filtrer certaines entités automatiquement
- Améliorer l'expérience utilisateur

### 4. Feedback visuel amélioré
- **Couleur différente selon le type** : Vert pour targetable, Jaune pour non-targetable
- **Animation du marker** : Marker qui pulse au survol
- **Label flottant** : Afficher le label au survol
- **Distance affichée** : Afficher la distance en temps réel

### 5. Système de cache
- Mettre en cache les résultats du raycast pendant quelques frames
- Réduire les appels répétés
- Améliorer les performances

### 6. Détection de collision améliorée
- Utiliser plusieurs raycasts pour détecter la meilleure entité
- Prendre en compte la taille de l'entité
- Améliorer la précision

### 7. Système de zones de détection
- Zones de détection plus grandes pour certaines entités
- Zones plus petites pour d'autres
- Personnalisable par type d'entité

### 8. Feedback sonore
- Son subtil au survol d'une entité targetable
- Son différent pour non-targetable
- Optionnel et désactivable

## 🎯 Recommandations finales

### Priorité 1 (À implémenter maintenant)
1. ✅ **Nettoyage de l'outline** - Déjà corrigé
2. ✅ **Option showOutlineOnAll** - Déjà ajoutée
3. 🔄 **Amélioration de la sélection d'entité** - À faire (priorité par distance)
4. 🔄 **Amélioration du changement de curseur** - À vérifier

### Priorité 2 (À implémenter ensuite)
1. Système de priorité d'entités
2. Distance minimale pour le raycast
3. Filtrage d'entités

### Priorité 3 (Améliorations futures)
1. Feedback visuel amélioré (couleurs, animations)
2. Système de cache
3. Détection de collision améliorée
4. Feedback sonore

## 📝 Configuration recommandée

```lua
Config.VisualFeedback = {
    enabled = true,
    useOutline = true,
    showOutlineOnAll = false,  -- false = uniquement targetables (recommandé)
    useMarker = true,
    -- ... reste de la config
}

Config.Target = {
    minDistance = 0.5,         -- Distance minimale
    maxDistance = 10000.0,
    priorityByDistance = true,  -- Prioriser par distance
    priorityByType = false      -- Prioriser par type
}
```

