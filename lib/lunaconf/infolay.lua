local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	keys = require('lunaconf.keys'),
	theme = require('lunaconf.theme')
}
local table = table

local infolay = {}

local SHOW_TIMEOUT = 0.4

local theme = lunaconf.theme.get()
local widgets = {}
local show_timer = nil

-- Add a new widget to the infolayer.
-- The passed widget must be a regular widget.
-- The second parameter must be a placement function from awful.placement
-- that will be called to place the widget on the screen.
function infolay.add(widget, placement_func)

	-- TODO: how to calculate a proper size
	local wb = wibox({
		bg = theme.infolay_bg or '#000000',
		opacity = theme.infolay_opacity or 1.0,
		type = 'utility',
		ontop = true,
		width = 100,
		height = 30
	})
	wb.widget = widget
	placement_func(wb, {
		honor_workarea = true,
		margins = 20
	})

	table.insert(widgets, wb)
end

-- Actually show the infolayer.
-- This will set all added widgets to visible
local function show()
	for i, w in ipairs(widgets) do
		w.visible = true
	end
end

-- Start showing the infolayer.
-- This will start the timer to show the infolayer delayed.
function infolay.start_showing()
	show_timer:again()
end

-- Stop showing the infolayer.
-- If the infolayer is still in its delay of showing we will just cancel the timer
-- otherwise we will set all widgets invisible.
function infolay.stop_showing()
	if show_timer.started then
		show_timer:stop()
	else
		for i, w in ipairs(widgets) do
			w.visible = false
		end
	end
end

function infolay:init()

	-- Setup the timer to show the infolayer delayed
	show_timer = gears.timer({
		timeout = SHOW_TIMEOUT,
		callback = show,
		single_shot = true
	})

	-- Attach hotkeys for the info layer
	lunaconf.keys.globals(
		awful.key({}, 'Super_L', infolay.start_showing),
		awful.key({'Mod4'}, 'Super_L', nil, infolay.stop_showing)
	)
end

return infolay
