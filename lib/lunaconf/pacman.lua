local awful = require('awful')

local pacman = {}

--- Checks whether a package is installed via pacman.
-- The callback will be called with true if the package is installed
-- or false otherwise.
function pacman.installed(pkgname, callback)
	awful.spawn.easy_async('pacman -Q ' .. pkgname, function(out, err, exit, code)
		callback(code == 0)
	end)
end

return pacman
