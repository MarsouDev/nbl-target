fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nbl-target'
description 'Modern targeting system for FiveM'
author 'Nebula'
version '2.0.0'
license 'Custom - See LICENSE file'

ui_page 'web/index.html'

shared_scripts {
    'config/config.lua'
}

client_scripts {
    'client/modules/raycast.lua',
    'client/modules/entity.lua',
    'client/modules/visual.lua',
    'client/registry.lua',
    'client/nui.lua',
    'client/main.lua',
    'client/framework/init.lua'
}

files {
    'client/framework/esx.lua',
    'client/framework/qbcore.lua',
    'web/index.html',
    'web/css/style.css',
    'web/js/app.js'
}
