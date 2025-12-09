fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nbl-target'
description 'Modern context menu / targeting system for FiveM'
author 'Nebula'
version '2.0.0'

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
    'client/test.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/css/style.css',
    'web/js/app.js'
}
