local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	config = require('lunaconf.config'),
	dpi = require('lunaconf.dpi'),
	keys = require('lunaconf.keys'),
	screens = require('lunaconf.screens'),
	theme = require('lunaconf.theme')
}
local table = table

local infolay = {}

local HIDE_TIMEOUT = 5

local infolay_placement = awful.placement.bottom + awful.placement.maximize_horizontally

local bar = nil
local theme = lunaconf.theme.get()
local widgets = {}
local hide_timer = nil

local function place_infolay()
	bar.screen = lunaconf.screens.primary()
	infolay_placement(bar, { honor_workarea = true, margins = 20 })
end

-- Add a new widget to the infolayer.
-- The passed widget must be a regular widget.
-- The second parameter must be a placement function from awful.placement
-- that will be called to place the widget on the screen.
function infolay.add(widget, placement_func)

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
	bar.visible = true
	-- TODO: Start hide timer
	-- hide_timer:again()
end

local function hide()
	bar.visible = false
	hide_timer:stop()
end

function infolay.toggle()
	if bar.visible then
		hide()
	else
		bar.visible = true
		hide_timer:again()
	end
end

-- Stop showing the infolayer.
-- If the infolayer is still in its delay of showing we will just cancel the timer
-- otherwise we will set all widgets invisible.
function infolay.stop_showing()
	if hide_timer.started then
		hide_timer:stop()
	else
		for i, w in ipairs(widgets) do
			w.visible = false
		end
	end
end

function infolay:init()

	-- Setup the timer to show the infolayer delayed
	hide_timer = gears.timer({
		timeout = HIDE_TIMEOUT,
		callback = hide,
		single_shot = true
	})

	-- Create infolay bar
	local scr = lunaconf.screens.primary()
	bar = wibox({
		bg = theme.infolay_bg or '#000000',
		opacity = theme.infolay_opacity or 1.0,
		type = 'utility',
		ontop = true,
		height = lunaconf.dpi.y(42, scr),
		screen = scr
	})

	place_infolay()

	bar:setup {
		layout = wibox.layout.fixed.horizontal,
		wibox.widget.systray()
	}

	-- When primary change, move bar to new screen
	screen.connect_signal('primary_changed', place_infolay)

	table.insert(widgets, wb)

	-- Attach hotkeys for the info layer
	lunaconf.keys.globals(
		awful.key({ lunaconf.config.MOD }, '/', infolay.toggle)
	)
end

return infolay
