local awful = require('awful')
local wibox = require('wibox')
local menubar = require('menubar')
local config = require('lunaconf.config')
local icons = require('lunaconf.icons')
local xdg = require('lunaconf.xdg')
local strings = require('lunaconf.strings')
local theme = require('lunaconf.theme')
local dpi = require('lunaconf.dpi')
local utils = require('lunaconf.utils')
local badge = require('lunaconf.layouts.badge')
local inifile = require('inifile')
local screens = require('lunaconf.screens')
local tostring = tostring
local lfs = require('lfs')

local listitem = require('lunaconf.launcher.listitem')

local log = require('lunaconf.log')
local menubar = require('menubar')
local inspect = require('inspect')

-- Start module
local launcher = {}

local hotkeys = {}

local launcher_screen = screens.primary()

local height = dpi.y(360, launcher_screen)
local width = dpi.x(450, launcher_screen)

local max_results_shown = 4

local config_file = awful.util.get_cache_dir() .. '/lunaconf.launcher.ini'

local default_icon = icons.lookup_icon('image-missing')
local default_search_placeholder = "or search ..."

local ui
local inputbox = wibox.widget.textbox()
local hotkey_rows

local split_container = wibox.layout.align.vertical()
local hotkey_panel = wibox.layout.flex.vertical()
local search_results = wibox.layout.fixed.vertical()
local result_items = {}
local more_results_label

local active_keygrabber

local current_search = ""
local current_shown_results = {}
local current_selected_result = nil

local function hotkey_badge(text)
	local hk_label = wibox.widget.textbox(text:upper())
	hk_label:set_align('center')
	hk_label:set_valign('center')
	hk_label.fit = function (wibox, w, h) return 30, 30 end
	local hk_badge = wibox.container.background(hk_label)
	hk_badge:set_bg('#EEEEEEAA' or theme.get().taglist_badge_bg or theme.get().bg_normal)
	hk_badge:set_fg('#000000')
	return hk_badge
end

local function icon_for_desktop_entry(desktop)
	return icons.lookup_icon(desktop.Icon) or desktop.icon_path
end

local function get_matching_apps(self)
	local result = {}

	local search = current_search:lower()

	-- This is the actual search logic to find matching applications.
	-- Here is a lot of potential to improve this logic.
	local apps = xdg.apps()
	for k,v in pairs(apps) do
		if (v.Name and v.Name:lower():find(search)) then
			table.insert(result, v)
		end
	end

	return result
end

local function change_selected_item(index)
	-- check that new index is within boundaries
	index = math.max(index, 1)
	index = math.min(index, math.min(#current_shown_results, max_results_shown))

	-- If the index has changed (and we have any results to highlight)
	if index ~= current_selected_result and #current_shown_results > 0 then
		-- Clear the highlight of the previously highlighted item (if any)
		if current_selected_result then
			result_items[current_selected_result]:set_highlight(false)
		end
		-- Highlight the new index
		result_items[index]:set_highlight(true)
		current_selected_result = index
	end
end

local function update_result_list(self)
	-- Load all matching results
	current_shown_results = get_matching_apps(self)

	-- Reset the result list
	-- search_results:reset()
	change_selected_item(1)

	-- Add the results to the result list
	for k,v in pairs(result_items) do
		if current_shown_results[k] then
			local desktop = current_shown_results[k]
			result_items[k]:set_visible(true)
			result_items[k]:set_icon(icon_for_desktop_entry(desktop) or default_icon)
			result_items[k]:set_title(desktop.Name)
			result_items[k]:set_description(desktop.Comment or desktop.Exec or '')
		else
			result_items[k]:set_visible(false)
		end
		-- search_results:add(application_item(v, k))
	end

	local unshown_results = #current_shown_results - 4
	if unshown_results > 0 then
		more_results_label:set_markup('<span color="#BBBBBB">and ' .. tostring(unshown_results) .. ' more</span>')
	else
		more_results_label:set_text(' ')
	end

	-- search_results:add(wibox.container.margin(more_results, 20, 20, 5, 5))
end

local function on_query_changed(self)
	if current_search and #current_search > 0 then
		-- The user entered a search term so show a result list
		inputbox:set_markup('<b>' .. current_search .. '</b>')
		local bg = wibox.container.background(search_results)
		split_container:set_middle(bg)
		update_result_list(self)
	else
		-- No search anymore so show hotkey panel again
		inputbox:set_text(default_search_placeholder)
		split_container:set_middle(hotkey_panel)
	end
end

local function reload_hotkeys()
	local ini = {}
	if awful.util.file_readable(config_file) then
		ini = inifile.parse(config_file)
	end

	ini['Hotkeys'] = ini['Hotkeys'] or {}

	for i,v in ipairs(hotkey_rows) do
		v:reset()
	end

	for i=0,8 do
		local row = math.floor(i / 3) + 1
		local key = i + 1

		local widget

		local hotkeyDesktopPath = ini['Hotkeys'][tostring(key)]
		if hotkeyDesktopPath and awful.util.file_readable(hotkeyDesktopPath) then
			local desktop = menubar.utils.parse_desktop_file(hotkeyDesktopPath)
			hotkeys[tostring(key)] = desktop

			local icon_w = wibox.widget.imagebox()
			icon_w:set_image(icon_for_desktop_entry(desktop))
			icon_w:set_resize(true)
			icon_w.width = dpi.x(48, launcher_screen)
			icon_w.height = dpi.y(48, launcher_screen)
			local bad = badge(icon_w)
			bad:add_badge(hotkey_badge(tostring(key)), 'left', 'bottom')

			widget = wibox.layout.align.horizontal()
			widget:set_second(bad)
		else
			widget = wibox.widget.textbox()
			widget:set_text(key)
			widget:set_align('center')
			widget:set_valign('center')
		end

		local margin = wibox.container.margin(widget)
		local x_margin = dpi.x(15, launcher_screen)
		local y_margin = dpi.y(15, launcher_screen)
		margin:set_left(x_margin)
		margin:set_right(x_margin)
		margin:set_top(y_margin)
		margin:set_bottom(y_margin)
		hotkey_rows[row]:add(margin)
	end

	split_container:emit_signal("widget::updated")

end

-- This function stores the specified desktop_entry on the hotkey with the
-- specified key. Key should be between 1 and 9. This method won't validate
-- this.
-- The method will update the config file for this hotkey and reload the panel.
local function save_hotkey(self, key, desktop_entry)
	local ini = {}
	if awful.util.file_readable(config_file) then
		ini = inifile.parse(config_file)
	end
	ini['Hotkeys'] = ini['Hotkeys'] or {}
	ini['Hotkeys'][tostring(key)] = desktop_entry.file
	-- Create cache folder if it doesn't exist yet
	lfs.mkdir(awful.util.get_cache_dir())
	inifile.save(config_file, ini, 'io')
	reload_hotkeys()
	current_search = ""
	on_query_changed(self)
end

local function store_currently_highlighted_to_hotkey(self, key)
	local desktop_entry = current_shown_results[current_selected_result]
	if desktop_entry then
		log.info("Store %s to hotkey %s", desktop_entry.Name, key)
		save_hotkey(self, key, desktop_entry)
	end
end

-- Starts a specific desktop file. It requires the parsed desktop file as a table
-- passed to the function.
-- @return a boolean whether the desktop entry could be started (true) or not (false)
local function start_desktop_entry(desktop_entry)
	if not desktop_entry or not desktop_entry.file then
		return false
	end

	log.info("Starting %s via desktop file: %s", desktop_entry.Name, desktop_entry.file)
	utils.spawn("dex '" .. desktop_entry.file .. "'")
	return true
end

local function close(self)
	ui.visible = false
	if #current_search > 0 then
		current_search = ""
		on_query_changed(self)
	end
	awful.keygrabber.stop(active_keygrabber)
end

local function start_from_search_results(key)
	local desktop_entry = current_shown_results[tonumber(key)]
	if start_desktop_entry(desktop_entry) then
		close()
	end
end

local function start_hotkey(key)
	if start_desktop_entry(hotkeys[key]) then
		close()
	end
end

local function keyhandler(self, modifiers, key, event)
	-- Rewrite the modifiers map to a proper table you can lookup modifiers in
	local mod = {}
	for k, v in ipairs(modifiers) do mod[v] = true end

	-- Only handle release events while the main modifier key isn't pressed
	if event ~= "release" or mod[config.MOD] then
		return false
	end

	if key == "Escape" then
		-- on Escape close the launcher
		close(self)
	elseif #current_search == 0 and hotkeys[key] ~= nil then
		-- If its a hotkey (and we haven't searched for anything) start that program
		start_hotkey(key)
	elseif #current_search > 0 and mod['Control'] and key:match("[1-9]") then
		-- If the user presses Ctrl + hotkey button while in search results store a hotkey
		store_currently_highlighted_to_hotkey(self, key)
	elseif #current_search > 0 and (key == "1" or key == "2" or key == "3" or key == "4") then
		start_from_search_results(key)
	elseif key == "BackSpace" then
		-- Backspace just deletes one letter (as one would expect)
		current_search = current_search:sub(0, -2)
		on_query_changed(self)
	elseif key == "Delete" then
		-- Delete will delete the whole input (as one would not expect)
		current_search = ""
		on_query_changed(self)
	elseif key:wlen() == 1 then
		-- If the key is just one letter it is most likely a character key so append it
		current_search = strings.trim_start(current_search .. key)
		on_query_changed(self)
	elseif #current_search > 0 and key == "Up" then
		change_selected_item(current_selected_result - 1)
	elseif #current_search > 0 and key == "Down" then
		change_selected_item(current_selected_result + 1)
	elseif #current_search > 0 and (key == "Return" or key == "KP_Enter") then
		start_from_search_results(current_selected_result)
	end

	return false
end

function launcher:toggle()
	ui.visible = not ui.visible
	if ui.visible then
		active_keygrabber = awful.keygrabber.run(function(...) keyhandler(self, ...) end)
	end
end

local function setup_result_list_ui()
	-- Setup the right amount of listitems
	for i = 1, max_results_shown do
		local item = listitem(i, launcher_screen)
		table.insert(result_items, item)
		search_results:add(item)
	end

	-- setup "and x more" label
	more_results_label = wibox.widget.textbox(' ')
	more_results_label:set_align('right')
	more_results_label:set_valign('center')
	search_results:add(wibox.container.margin(more_results_label, 20, 20, 5, 5))
end

local function setup_ui(self)
	local box = wibox({
		bg = '#222222',
		width = width,
		height = height,
		x = launcher_screen.workarea.x + (launcher_screen.workarea.width / 2) - (width / 2),
		y = math.ceil(launcher_screen.workarea.y + launcher_screen.workarea.height - height),
		ontop = true,
		opacity = 0.9,
		type = 'utility'
	})

	ui = box

	hotkey_rows = {
		wibox.layout.flex.horizontal(),
		wibox.layout.flex.horizontal(),
		wibox.layout.flex.horizontal()
	}

	inputbox:set_align('center')
	inputbox:set_valign('center')
	inputbox:set_text(default_search_placeholder)

	hotkey_panel:add(hotkey_rows[3])
	hotkey_panel:add(hotkey_rows[2])
	hotkey_panel:add(hotkey_rows[1])

	local inputbox_margin = wibox.container.margin(inputbox, 20, 20, 20, 20)

	split_container:set_middle(hotkey_panel)
	split_container:set_bottom(inputbox_margin)

	box:set_widget(split_container)

	setup_result_list_ui()
end

local function new(self)
	setup_ui(self)
	reload_hotkeys(self)

	xdg.refresh()

	return self
end

return setmetatable(launcher, { __call = new })
