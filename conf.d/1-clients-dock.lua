local lunaconf = require('lunaconf')
local awful = require('awful')
local inspect = require('inspect')

local DOCK_PADDING = 20

function awful.client.object.set_is_docked(c, value)
	c._is_docked = value
	c:emit_signal('property::is_docked')
end

function awful.client.object.get_is_docked(c)
	return c._is_docked
end

local dock_tag = awful.tag.add('Dock', {
	screen = screen.primary,
	layout = awful.layout.suit.max,
	invisible = true, -- Mark the tag as invisible (custom flag) that will be filtered for in the tag list
})

local function dock_trigger()
	if not dock_tag.selected then
		dock_tag.selected = true
		local clients = dock_tag:clients()
		if #clients > 0 then
			client.focus = clients[1]
		end
	else
		if client.focus and client.focus.first_tag == dock_tag then
			-- If the dock is closed and the focused client was the docked client, we'll focus the previously focused client
			awful.client.focus.history.previous()
		end
		dock_tag.selected = false
	end
end

local function toggle_client()
	local c = client.focus
	if not c then
		return
	end

	if c.first_tag == dock_tag then
		c:move_to_tag(c.screen.primary_tag)
	else
		c:move_to_tag(dock_tag)
	end
end

local function resize_to_dock(c)
	local padding_x = lunaconf.dpi.x(DOCK_PADDING, dock_tag.screen)
	local padding_y = lunaconf.dpi.y(DOCK_PADDING, dock_tag.screen)
	local wa = dock_tag.screen.workarea
	local width = wa.width * 0.25
	c:geometry({
		x = wa.x + wa.width - width - padding_x,
		y = wa.y + padding_y,
		width = width,
		height = wa.height - padding_y * 2
	})
end

dock_tag:connect_signal('tagged', function(t, c)
	c.floating = true
	c.above = true
	c.unresizeable = true
	c.is_docked = true
	resize_to_dock(c)
	dock_tag.selected = true
end)

dock_tag:connect_signal('untagged', function(t, c)
	c.above = false
	c.unresizeable = false
	c.is_docked = false
	c.floating = false
	dock_tag.selected = false
end)

dock_tag:connect_signal('request::screen', function()
	dock_tag.screen = screen.primary
end)

lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, 'z', dock_trigger),
	awful.key({ lunaconf.config.MOD, 'Ctrl' }, 'z', toggle_client),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'z', toggle_client)
)

