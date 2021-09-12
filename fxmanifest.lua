fx_version 'adamant'
games { 'gta5' };

client_scripts {
    'client/*.lua'
}

shared_scripts {
    'shared/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "server/*.lua"
}

