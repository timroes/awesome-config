local awful = require('awful')

local pacman = {}

function pacman.installed(pkgname, callback)
	awful.spawn.easy_async('pacman -Q ' .. pkgname, function(out, err, exit, code)
		callback(code == 0)
	end)
end

return pacman
