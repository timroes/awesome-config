local awful = require('awful')
local cairo = require('lgi').cairo
local gears = require('gears')
local wibox = require('wibox')
local lunaconf = {
	dpi = require('lunaconf.dpi'),
	keys = require('lunaconf.keys'),
	strings = require('lunaconf.strings'),
	theme = require('lunaconf.theme')
}

local switcher = {}

local max_hotkey_length = 3

local theme = lunaconf.theme.get()

local query, hotkeys, surfaces, client_widgets

local function hide()
	for s in screen do
		if s.clientswitcher_widget then
			s.clientswitcher_widget.visible = false
			s.clientswitcher_widget.widget = nil
		end
	end
	-- Free all cairo surfaces of all images (will be faster than waiting for GC)
	for i = 1, #surfaces do
		surfaces[i]:finish()
	end
	surfaces =  nil
	client_widgets = nil
	-- Release the keygrabber
	keygrabber.stop()
end

local function highlight_matching_clients()
	for client, widget in pairs(client_widgets) do
		if query:len() > 0 and (not client.switcher_hotkey or not lunaconf.strings.starts_with(client.switcher_hotkey, query)) then
			if widget.opacity ~= 0.3 then
				widget.opacity = 0.3
				widget:emit_signal('widget::redraw_needed')
			end
		else
			if widget.opacity ~= 1.0 then
				widget.opacity = 1.0
				widget:emit_signal('widget::redraw_needed')
			end
		end
	end
end

local function find_client_hotkey(key)
	query = query .. key
	if type(hotkeys[query]) == 'client' then
		client.focus = hotkeys[query]
		return hide()
	elseif not hotkeys[query] then
		query = ''
	end
	highlight_matching_clients()
end

local function on_key(mod, key, event)
	if key == 'Escape' and event == 'press' then
		hide()
	elseif event == 'press' and ((key >= 'a' and key <= 'z') or (key >= '0' and key <= '9')) then
		find_client_hotkey(key)
	end
end

--- Returns the screenshot of a client in a way, that can be used in an
--- wibox.widget.imagebox
local function get_screenshot(client, max_width)
	local raw_surface = gears.surface(client.content)
	-- Determin the dimensions of the raw screenshot
	local width, height = gears.surface.get_size(raw_surface)
	-- Determine the scale factor based on the width of the surface and max width required
	local scale_factor = max_width / width
	-- Create a new cairo ImageSurface with the same dimensions
	local img_surface = cairo.ImageSurface(cairo.Format.RGB24, width * scale_factor, height * scale_factor)
	-- Draw the raw surface onto the new image surface
	local cr = cairo.Context(img_surface)
	cr:scale(scale_factor, scale_factor)
	cr:set_source_surface(raw_surface, 0, 0)
	cr:paint()
	-- Destroy the raw surface from client.content
	raw_surface:finish()
	-- Store the surface in a list so we can free them all when hiding
	table.insert(surfaces, img_surface)
	return img_surface
end

local function create_client_widget(cl, max_widget_width)
	local widget = wibox.widget {
		{
			nil, -- nil as first widget in align layout so the screenshot will be in center and expanded
			{
				{
					image = get_screenshot(cl, max_widget_width),
					widget = wibox.widget.imagebox
				},
				{
					{
						{
							{
								text = (cl.switcher_hotkey or '-'):upper(),
								font = theme.clientswitcher_hotkey_font,
								widget = wibox.widget.textbox
							},
							margins = lunaconf.dpi.x(8, cl.screen),
							widget = wibox.container.margin
						},
						bg = theme.clientswitcher_hotkey_bg,
						widget = wibox.container.background
					},
					valign = 'bottom',
					halign = 'left',
					widget = wibox.container.place
				},
				layout = wibox.layout.stack
			},
			{
				{
					{
						image = cl.icon,
						forced_height = lunaconf.dpi.y(32, cl.screen),
						forced_width = lunaconf.dpi.x(32, cl.screen),
						widget = wibox.widget.imagebox
					},
					{
						text = cl.name,
						font = theme.clientswitcher_font,
						widget = wibox.widget.textbox
					},
					spacing = lunaconf.dpi.x(8, cl.screen),
					layout = wibox.layout.fixed.horizontal
				},
				margins = lunaconf.dpi.x(8, cl.screen),
				widget = wibox.container.margin
			},
			layout = wibox.layout.align.vertical
		},
		fill_horizontal = true,
		content_fill_horizontal = true,
		widget = wibox.container.place
	}
	widget:buttons(gears.table.join(
		awful.button({ }, 1, function()
			client.focus = cl
			hide()
		end)
	))
	return widget
end

local function name_for_hotkey(client)
	local name = client.name or ''
	name = name:gsub('%W', '')
	return lunaconf.strings.lpad(name, max_hotkey_length, 'x'):lower()
end

local function calculate_hotkey(client)
	local hotkey_length = 1
	local hotkey_found = false
	local name = name_for_hotkey(client)
	repeat
		local hotkey = string.sub(name:lower(), 0, hotkey_length)
		if not hotkeys[hotkey] then
			-- There is no client with this prefix yet, so let's use it as hotkey for now
			-- If another client will try to get this prefix it will also make our hotkey longer.
			hotkeys[hotkey] = client
			client.switcher_hotkey = hotkey
			hotkey_found = true
		else
			-- The hotkey this client wants is already in use
			if type(hotkeys[hotkey]) == 'client' then
				local colliding_client = hotkeys[hotkey]
				local new_hotkey

				if hotkey_length == max_hotkey_length then
					-- If we are already at max hotkey length we need to jump to different
					-- mode where we just suffix one more letter
					new_hotkey = hotkey .. 'a'
				else
					-- We are not yet at max hotkey length, so give the colliding a one letter
					-- longer hotkey and also increase it for us
					new_hotkey = string.sub(name_for_hotkey(colliding_client), 0, hotkey_length + 1)
				end
				hotkeys[new_hotkey] = colliding_client
				colliding_client.switcher_hotkey = new_hotkey
				hotkeys[hotkey] = true
			end
			-- We need to try a one length longer hotkey in the next iteration
			hotkey_length = hotkey_length + 1
			-- We are now in last resort mode trying to append one more letter to the
			-- hotkey. If we find one that is free, fine. If not this client won't get a hotkey.
			if hotkey_length > max_hotkey_length then
				for a = 97, 122 do
					local htk = hotkey .. string.char(a)
					if not hotkeys[htk] then
						hotkeys[htk] = client
						client.switcher_hotkey = htk
						return
					end
				end
				-- Exit the hotkey finding, even if we haven't found a hotkey
				return
			end
		end
	until hotkey_found
end

local function setup_widget(screen, clients)
	local layout

	if #clients == 0 then
		layout = wibox.widget {
			wibox.widget.textbox('No clients on this screen'),
			widget = wibox.container.place
		}
	else
		local num_cols = math.ceil(math.sqrt(#clients))
		local num_rows = math.ceil(#clients / num_cols)

		layout = wibox.widget {
			homogeneous = true,
			forced_num_rows = num_rows,
			forced_num_cols = num_cols,
			spacing = lunaconf.dpi.x(20, screen),
			orientation = 'horizontal',
			expand = true,
			layout = wibox.layout.grid
		}

		local max_client_widget_width = screen.geometry.width / num_cols

		for i,c in ipairs(clients) do
			local client_widget = create_client_widget(c, max_client_widget_width)
			layout:add(client_widget)
			client_widgets[c] = client_widget
		end
	end

	local widget = wibox.widget {
		layout,
		margins = lunaconf.dpi.x(20, screen),
		widget = wibox.container.margin
	}

	screen.clientswitcher_widget.widget = widget
end

local function show_on_screen(screen, clients)
	-- If it's the first time we show on that screen initialize the widget for that screen
	if not screen.clientswitcher_widget then
		screen.clientswitcher_widget = wibox {
			screen = screen,
			ontop = true,
			bg = '#333333DD'
		}
	end

	screen.clientswitcher_widget:geometry(screen.geometry)
	setup_widget(screen, clients)
	screen.clientswitcher_widget.visible = true
end

local function show()
	-- Reset hotkeys
	hotkeys = {}
	surfaces = {}
	client_widgets = {}
	local clients = {}
	-- First collect all clients. We need to do this before drawing so the hotkeys
	-- will be stable for all clients when drawing
	for s in screen do
		clients[s] = {}
		for i,c in ipairs(s.clients) do
			if c:isvisible() then
				calculate_hotkey(c)
				table.insert(clients[s], c)
			end
		end
	end
	keygrabber.run(on_key)
	-- Show the switcher on all connected screens
	for s in screen do
		show_on_screen(s, clients[s])
	end
	query = ''
end

local function new(_, modifiers, key)
	lunaconf.keys.globals(awful.key(modifiers, key, show))
end

return setmetatable(switcher, { __call = new })
