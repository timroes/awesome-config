local awful = require('awful')
local wibox = require('wibox')
local common = require('lunaconf.widgets.common')

local tasklist = {}

local function new(self, screen, filter, buttons)
	return awful.widget.tasklist(screen, filter, buttons, nil, common.icon_widget, wibox.layout.fixed.horizontal())
end

return setmetatable(tasklist, { __call = new })