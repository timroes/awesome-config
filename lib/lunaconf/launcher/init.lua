local awful = require('awful')
local wibox = require('wibox')
local config = require('lunaconf.config')
local icons = require('lunaconf.icons')
local xdg = require('lunaconf.xdg')
local strings = require('lunaconf.strings')
local theme = require('lunaconf.theme')
local badge = require('lunaconf.layouts.badge')
local tostring = tostring

local listitem = require('lunaconf.launcher.listitem')

local log = require('lunaconf.log')
local menubar = require('menubar')

-- Start module
local launcher = {}

local hotkeys = {}

local height = 360
local width = 450

local max_results_shown = 4

local default_icon = icons.lookup_icon('image-missing')
local default_search_placeholder = "or search ..."

local ui
local inputbox = wibox.widget.textbox()
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

local function update_result_list()
	-- Load all matching results
	current_shown_results = get_matching_apps()

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

	-- search_results:add(wibox.layout.margin(more_results, 20, 20, 5, 5))
end

local function on_query_changed()
	if current_search and #current_search > 0 then
		-- The user entered a search term so show a result list
		inputbox:set_markup('<b>' .. current_search .. '</b>')
		local bg = wibox.widget.background(search_results)
		split_container:set_middle(bg)
		update_result_list()
	else
		-- No search anymore so show hotkey panel again
		inputbox:set_text(default_search_placeholder)
		split_container:set_middle(hotkey_panel)
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
	awful.util.spawn("dex " .. desktop_entry.file)
	return true
end

local function close()
	ui.visible = false
	current_search = ""
	on_query_changed()
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

local function keyhandler(modifiers, key, event)
	-- Rewrite the modifiers map to a proper table you can lookup modifiers in
	local mod = {}
	for k, v in ipairs(modifiers) do mod[v] = true end

	-- Only handle release events while the main modifier key isn't pressed
	if event ~= "release" or mod[config.MOD] then
		return false
	end

	if key == "Escape" then
		-- on Escape close the launcher
		close()
	elseif #current_search == 0 and hotkeys[key] ~= nil then
		-- If its a hotkey (and we haven't searched for anything) start that program
		start_hotkey(key)
	elseif #current_search > 0 and (key == "1" or key == "2" or key == "3" or key == "4") then
		start_from_search_results(key)
	elseif key == "BackSpace" then
		-- Backspace just deletes one letter (as one would expect)
		current_search = current_search:sub(0, -2)
		on_query_changed()
	elseif key == "Delete" then
		-- Delete will delete the whole input (as one would not expect)
		current_search = ""
		on_query_changed()
	elseif key:wlen() == 1 then
		-- If the key is just one letter it is most likely a character key so append it
		current_search = strings.trim(current_search .. key)
		on_query_changed()
	elseif #current_search > 0 and key == "Up" then
		change_selected_item(current_selected_result - 1)
	elseif #current_search > 0 and key == "Down" then
		change_selected_item(current_selected_result + 1)
	elseif #current_search > 0 and (key == "Return" or key == "KP_Enter") then
		start_from_search_results(current_selected_result)
	end

	return false
end

function launcher.toggle()
	ui.visible = not ui.visible
	if ui.visible then
		active_keygrabber = awful.keygrabber.run(keyhandler)
	end
end

local function setup_result_list_ui()
	-- Setup the right amount of listitems
	for i = 1, max_results_shown do
		local item = listitem(i)
		table.insert(result_items, item)
		search_results:add(item)
	end

	-- setup "and x more" label
	more_results_label = wibox.widget.textbox(' ')
	more_results_label:set_align('right')
	more_results_label:set_valign('center')
	search_results:add(wibox.layout.margin(more_results_label, 20, 20, 5, 5))
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

	setup_result_list_ui()
end

local function new(self)
	setup_ui()

	xdg.refresh()

	return self
end

return setmetatable(launcher, { __call = new })
