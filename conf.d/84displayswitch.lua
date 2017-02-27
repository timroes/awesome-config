local setmetatable = setmetatable
local awful = require('awful')
local w = require('wibox')
local scriptpath = scriptpath
local dbus = dbus
local tonumber = tonumber
local tostring = tostring
local root = root

module('widgets.displayswitcher')

local ICON = awful.util.getdir('config') .. '/images/display.png'
local is_active

local function read(file)
	local f = io.open(file)
	local ret = f:read()
	f:close()
	return ret
end

local function create(_)
	local mlayout = w.container.margin()

	widget = w.widget.imagebox()
	widget:fit(24, 24)
	widget:set_resize(false)

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
		{ 'Notebook', scriptpath .. '/screenlayout.sh notebook' },
		{ 'Cloned', scriptpath .. '/screenlayout.sh clone' },
		{ 'Extended', scriptpath .. '/screenlayout.sh extend' },
		{ '└ External primary', scriptpath .. '/screenlayout.sh extend_external' },
		{ 'External', scriptpath .. '/screenlayout.sh external' }
	} })

	mlayout:buttons(awful.button({ }, 1, function()
		menu:toggle()
	end))

	dbus.request_name('system','de.timroes.displaywidget')
	dbus.add_match('system', "interface='de.timroes.displaywidget'")
	dbus.connect_signal('de.timroes.displaywidget', function(msg)
		if msg.member == "Plugged" then
			is_active = true
			widget:set_image(ICON)
		else
			is_active = false
			menu:hide()
			widget:set_image(nil)
			awful.util.pread(scriptpath .. '/screenlayout.sh disconnect')
		end
	end)

	-- Show screen menu on XF86Display
	root.keys(awful.util.table.join(root.keys(),
		awful.key({ }, "XF86Display", function()
			if is_active then
				menu:toggle()
			end
		end)
	))

	-- TODO: Fix this without awful.util.pread
	-- local monitors = tonumber(awful.util.pread('/usr/bin/xrandr | grep " connected" | wc -l'))
	-- if monitors < 2 then
	-- 	is_active = false
	-- 	widget:set_image(nil)
	-- else
	-- 	is_active = true
	-- 	widget:set_image(ICON)
	-- end

	return mlayout
end

setmetatable(_M, { __call = create })
