local awful = require('awful')
local wibox = require('wibox')
local config = require('lunaconf.config')
local icons = require('lunaconf.icons')
local xdg = require('lunaconf.xdg')
local theme = require('lunaconf.theme')
local badge = require('lunaconf.layouts.badge')
local tostring = tostring

local log = require('lunaconf.log')
local inspect = require('inspect')
local menubar = require('menubar')

local launcher = {}

local hotkeys = {}

local height = 350
local width = 450

local default_search_placeholder = "or search ..."

local ui
local inputbox = wibox.widget.textbox()
local split_container = wibox.layout.align.vertical()
local hotkey_panel = wibox.layout.flex.vertical()
local search_results = wibox.layout.fixed.vertical()

local current_search = ""

local function hotkey_badge(text)
	local hk_label = wibox.widget.textbox(text:upper())
	-- dpi.textbox(hk_label)
	hk_label:set_align('center')
	hk_label:set_valign('center')
	hk_label.fit = function (wibox, w, h) return 40, 40 end
	local hk_badge = wibox.widget.background(hk_label)
	hk_badge:set_bg('#EEEEEEAA' or theme.get().taglist_badge_bg or theme.get().bg_normal)
	hk_badge:set_fg('#000000')
	return hk_badge
end

local function icon_for_desktop_entry(desktop)
	return icons.lookup_icon(desktop.Icon) or desktop.icon_path
end

local function application_item(desktop_entry)
	local item = wibox.layout.align.horizontal()
	local icon = wibox.widget.imagebox()
	icon:set_image(icon_for_desktop_entry(desktop_entry))
	icon.fit = function(widget, w, h) return 48, 48 end
	icon:set_resize(true)
	icon.width = 48
	icon.height = 48

	local text = wibox.layout.fixed.vertical()
	local title = wibox.widget.textbox()
	title:set_align('left')
	title:set_valign('center')
	title:set_text(desktop_entry.Name)

	local description = wibox.widget.textbox()
	description:set_text(desktop_entry.Exec or "")

	text:add(title)
	text:add(description)

	item:set_left(icon)
	item:set_middle(text)

	return item
end

local function get_matching_apps()
	local result = {}

	local search = current_search:lower()

	-- This is the actual search logic to find matching applications.
	-- Here is a lot of potential to improve this logic.
	for k,v in pairs(xdg.all()) do
		if (v.Name and v.Name:lower():find(search)) then
			table.insert(result, v)
		end
	end

	return result
end

local function update_result_list()
	local result = get_matching_apps()
	search_results:reset()

	for k,v in pairs(result) do
		-- log.info("Results! %s", inspect(result))
		search_results:add(application_item(v))
	end
end

local function update()
	if current_search and #current_search > 0 then
		inputbox:set_text(current_search)
		split_container:set_middle(search_results)
		update_result_list()
	else
		-- No search anymore so show hotkey panel again
		inputbox:set_text(default_search_placeholder)
		split_container:set_middle(hotkey_panel)
	end
end

local function close()
	ui.visible = false
	current_search = ""
	update()
	keygrabber.stop()
end

local function start_hotkey(key)
	if hotkeys[key] ~= nil then
		local desktop = hotkeys[key]
		awful.util.spawn("dex " .. desktop.file)
		close()
	end
end

local function keyhandler(mod, key, event)
	-- Only handle release events
	if event ~= "release" then
		return
	end


	if key == "Escape" then
		-- on Escape close the launcher
		close()
	elseif #current_search == 0 and hotkeys[key] ~= nil then
		-- If its a hotkey (and we haven't searched for anything) start that program
		start_hotkey(key)
	elseif key == "BackSpace" then
		-- Backspace just deletes one letter (as one would expect)
		current_search = current_search:sub(0, -2)
		update()
	elseif key == "Delete" then
		-- Delete will delete the whole input (as one would not expect)
		current_search = ""
		update()
	elseif key:wlen() == 1 then
		-- If the key is just one letter it is most likely a character key so append it
		current_search = current_search .. key
		update()
	end
end

function launcher.toggle()
	ui.visible = not ui.visible
	if ui.visible then
		keygrabber.run(keyhandler)
	end
end

local function setup_ui()
	local s = screen[PRIMARY]
	local box = wibox({
		bg = '#222222',
		width = width,
		height = height,
		x = s.workarea.x + (s.workarea.width / 2) - (width / 2),
		y = s.workarea.y + s.workarea.height - height,
		ontop = true,
		opacity = 0.75,
		type = 'utility'
	})

	ui = box

	local rows = {
		wibox.layout.flex.horizontal(),
		wibox.layout.flex.horizontal(),
		wibox.layout.flex.horizontal()
	}

	for i=0,8 do
		local row = math.floor(i / 3) + 1
		local key = i + 1

		local widget

		local hotkeyDesktopPath = config.get('launcher.hotkeys.h' .. (key), '')
		if awful.util.file_readable(hotkeyDesktopPath) then
			local desktop = menubar.utils.parse(hotkeyDesktopPath)
			hotkeys[tostring(key)] = desktop
			-- log.info('Part: %s, %s', i, inspect(desktop))

			local icon_w = wibox.widget.imagebox()
			icon_w:set_image(icon_for_desktop_entry(desktop))
			icon_w:set_resize(false)
			icon_w.width = 48
			icon_w.height = 48
			local bad = badge(icon_w)
			bad:add_badge('sw', hotkey_badge(tostring(key)), 3, 0.4, 0.4)

			widget = wibox.layout.align.horizontal()
			widget:set_second(bad)
		else
			widget = wibox.widget.textbox()
			widget:set_text(key)
			widget:set_align('center')
			widget:set_valign('center')
		end

		local margin = wibox.layout.margin(widget, 15, 15, 15, 15)
		rows[row]:add(margin)
	end

	inputbox:set_align('center')
	inputbox:set_valign('center')
	inputbox:set_text(default_search_placeholder)

	hotkey_panel:add(rows[3])
	hotkey_panel:add(rows[2])
	hotkey_panel:add(rows[1])

	local inputbox_margin = wibox.layout.margin(inputbox, 20, 20, 20, 20)

	split_container:set_middle(hotkey_panel)
	split_container:set_bottom(inputbox_margin)

	box:set_widget(split_container)
end

local function new(self)
	setup_ui()

	xdg.refresh()

	return self
end

return setmetatable(launcher, { __call = new })
