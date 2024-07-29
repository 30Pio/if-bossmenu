fx_version "cerulean"
game "gta5"

author 'IF Developments' -- https://discord.gg/if-developments
description 'Boss Menu & Invoices - FREE'
version '1.0'

lua54 'yes'

ui_page 'web/build/index.html'

client_script "client/**/*"

shared_script {
    'config.lua',
    '@ox_lib/init.lua'
}

server_script {
    "@oxmysql/lib/MySQL.lua",
    "server/**/*",
}

files {
    'web/build/index.html',
    'web/build/**/*',
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

