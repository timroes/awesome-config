local lunaconf = {
	theme = require('lunaconf.theme')
}

local bar = {}

local theme = lunaconf.theme.get()

function bar.widget_color()
	return theme.screenbar_fg or '#FFFFFF'
end

return bar
