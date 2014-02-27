local setmetatable = setmetatable
local awful = require('awful')
local w = require('wibox')
local scriptpath = scriptpath
local configpath = configpath
local dbus = dbus

module('widgets.displayswitcher')

local function read(file)
	local f = io.open(file)
	local ret = f:read()
	f:close()
	return ret
end

local function create(_)
	local mlayout = w.layout.margin()

	widget = w.widget.imagebox()
	widget:fit(24, 24)
	widget:set_resize(false)
	widget:set_image(configpath .. '/images/display.png')

	mlayout:set_widget(widget)
	mlayout:set_top(2)

	local menu = awful.menu({ 
	theme = {
		height = 26,
		width = 170,
		bg_normal = '#222222',
		fg_normal = '#FFFFFF',
		bg_focus = '#33B5E5'
	},
	items = { 
		{ 'Notebook only', scriptpath .. '/screenlayout.sh notebook' },
		{ 'Both Cloned', scriptpath .. '/screenlayout.sh clone' },
		{ 'Both Extended', scriptpath .. '/screenlayout.sh extend' },
		{ 'External only', scriptpath .. '/screenlayout.sh external' }
	} })

	mlayout:buttons(awful.button({ }, 1, function() 
		menu:toggle()
	end))

	dbus.request_name('system','de.timroes.displaywidget')
	dbus.add_match('system', "interface='de.timroes.displaywidget'")
	dbus.connect_signal('de.timroes.displaywidget', function(msg)
		if msg.member == "Plugged" then
			widget:set_image(configpath .. '/images/display.png')
		else
			awful.util.pread(scriptpath .. '/screenlayout.sh disconnect')
			widget:set_image(nil)
		end
	end)

	return mlayout
end

setmetatable(_M, { __call = create })
