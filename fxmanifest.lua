fx_version 'adamant'
game 'gta5'

author 'BR'
description 'A Full Featured FiveM Job Boss Action'
repository 'https://github.com/BehnamRt/FiveM_Society'


server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@essentialmode/locale.lua',
	'locales/en.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@essentialmode/locale.lua',
	'locales/en.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'essentialmode'
}