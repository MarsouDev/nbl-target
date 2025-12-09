CreateThread(function()
    Wait(2000)
    
    print("^2[NBL-Target Test]^7 Loading test options...")
    
    exports['nbl-target']:addGlobalVehicle({
        {
            name = 'test_vehicle_info',
            label = 'Informations du véhicule',
            icon = 'fas fa-info-circle',
            onSelect = function(entity)
                print("^3[TEST]^7 Informations du véhicule - Entity: " .. tostring(entity))
            end
        },
        {
            name = 'test_vehicle_actions',
            label = 'Actions',
            icon = 'fas fa-cog',
            items = {
                {
                    name = 'test_vehicle_lock',
                    label = 'Verrouiller/Déverrouiller',
                    icon = 'fas fa-lock'
                },
                {
                    name = 'test_vehicle_engine',
                    label = 'Moteur',
                    icon = 'fas fa-car',
                    items = {
                        {
                            name = 'test_engine_start',
                            label = 'Démarrer',
                            icon = 'fas fa-play'
                        },
                        {
                            name = 'test_engine_stop',
                            label = 'Arrêter',
                            icon = 'fas fa-stop'
                        }
                    }
                },
                {
                    name = 'test_vehicle_repair',
                    label = 'Réparer',
                    icon = 'fas fa-wrench'
                }
            }
        },
        {
            name = 'test_vehicle_inventory',
            label = 'Coffre',
            icon = 'fas fa-box',
            onSelect = function(entity)
                print("^3[TEST]^7 Ouvrir coffre - Entity: " .. tostring(entity))
            end
        },
        {
            name = 'test_vehicle_customize',
            label = 'Personnaliser',
            icon = 'fas fa-paint-brush',
            items = {
                {
                    name = 'test_customize_color',
                    label = 'Couleur',
                    icon = 'fas fa-palette'
                },
                {
                    name = 'test_customize_wheels',
                    label = 'Roues',
                    icon = 'fas fa-circle'
                },
                {
                    name = 'test_customize_livery',
                    label = 'Livrée',
                    icon = 'fas fa-image'
                }
            }
        }
    })
    
    exports['nbl-target']:addGlobalPed({
        {
            name = 'test_ped_talk',
            label = 'Parler',
            icon = 'fas fa-comments',
            onSelect = function(entity)
                print("^3[TEST]^7 Parler au PNJ - Entity: " .. tostring(entity))
            end
        },
        {
            name = 'test_ped_trade',
            label = 'Échanger',
            icon = 'fas fa-handshake',
            onSelect = function(entity)
                print("^3[TEST]^7 Échanger avec PNJ - Entity: " .. tostring(entity))
            end
        },
        {
            name = 'test_ped_rob',
            label = 'Braquer',
            icon = 'fas fa-gun',
            onSelect = function(entity)
                print("^3[TEST]^7 Braquer PNJ - Entity: " .. tostring(entity))
            end
        }
    })
    
    exports['nbl-target']:addGlobalObject({
        {
            name = 'test_object_interact',
            label = 'Interagir',
            icon = 'fas fa-hand-pointer',
            onSelect = function(entity)
                print("^3[TEST]^7 Interagir avec objet - Entity: " .. tostring(entity))
            end
        },
        {
            name = 'test_object_pickup',
            label = 'Ramasser',
            icon = 'fas fa-hand-holding',
            onSelect = function(entity)
                print("^3[TEST]^7 Ramasser objet - Entity: " .. tostring(entity))
            end
        }
    })
    
    exports['nbl-target']:addGlobalSelf({
        {
            name = 'test_self_inventory',
            label = 'Inventaire',
            icon = 'fas fa-box-open',
            onSelect = function()
                print("^3[TEST]^7 Ouvrir inventaire")
            end
        },
        {
            name = 'test_self_phone',
            label = 'Téléphone',
            icon = 'fas fa-mobile-alt',
            onSelect = function()
                print("^3[TEST]^7 Ouvrir téléphone")
            end
        },
        {
            name = 'test_self_settings',
            label = 'Paramètres',
            icon = 'fas fa-cog',
            items = {
                {
                    name = 'test_settings_graphics',
                    label = 'Graphismes',
                    icon = 'fas fa-desktop'
                },
                {
                    name = 'test_settings_audio',
                    label = 'Audio',
                    icon = 'fas fa-volume-up'
                },
                {
                    name = 'test_settings_controls',
                    label = 'Contrôles',
                    icon = 'fas fa-keyboard'
                }
            }
        }
    })
    
    print("^2[NBL-Target Test]^7 Test options loaded! Try targeting vehicles, peds, objects, or yourself.")
end)
