fx_version "cerulean"
game "gta5"

author 'IF Developments' -- https://discord.gg/if-developments
description 'Boss Menu & Invoices - FREE'
version '1.1.1'

lua54 'yes'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}
client_script "client/**/*"
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/**/*",
}

ui_page 'web/build/index.html'
files {
    'web/build/index.html',
    'web/build/**/*'
}

dependencies {
    'ox_lib',
    'oxmysql'
}

escrow_ignore {
    'config.lua',
    'client/client.lua',
    'client/utils.lua',
    'server/server.lua'
}
