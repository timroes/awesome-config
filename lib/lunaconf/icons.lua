--- A slightly modified version of awesome's original `menubar.utils` function
--- https://github.com/awesomeWM/awesome/blob/master/lib/menubar/utils.lua
---
--- @author Antonio Terceiro

local glib = require("lgi").GLib
local theme = require("lunaconf.theme")
local awful_util = require("awful.util")
local inifile = require('inifile')
local strings = require('lunaconf.strings')
local utils = require('lunaconf.utils')

local icons = {}

local icon_cache = {}

--- List of supported icon formats.
local icon_formats = { "svg", "png", "xpm" }

--- Check whether the icon format is supported.
-- @param icon_file Filename of the icon.
-- @return true if format is supported, false otherwise.
local function is_format_supported(icon_file)
	for _, f in ipairs(icon_formats) do
		if icon_file:match('%.' .. f) then
			return true
		end
	end
	return false
end

local icon_lookup_path = nil
local function get_icon_lookup_path()
	if not icon_lookup_path then
		icon_lookup_path = {}
		local icon_theme_paths = {}
		local icon_theme = theme.get().icon_theme

		-- Add all directories which could contain icon themes to paths list
		local paths = glib.get_system_data_dirs()
		table.insert(paths, 1, glib.get_user_data_dir() .. '/')


		-- Note: We add first the hicolor themes, since we will reverse the order
		-- of all directories later on when selecting all subdirectories. Since we want
		-- to have the actual theme files precedence to the hicolor icons, we add
		-- hicolor here first.
		-- Add all hicolor themes as fallback
		for k,dir in ipairs(paths)do
			table.insert(icon_theme_paths, dir..'icons/hicolor/') -- fallback theme
		end
		-- If the user set an icon theme add all that folders to the list to look for index.theme files later
		if icon_theme then
			for k,dir in ipairs(paths) do
				table.insert(icon_theme_paths, dir .. 'icons/' .. icon_theme .. '/')
			end
		end

		-- Parse the index.theme file of all used icon themes
		for i, icon_theme_path in ipairs(icon_theme_paths) do
			local index_file_name = icon_theme_path .. 'index.theme'
			if awful_util.file_readable(index_file_name) then
				local theme_index = inifile.parse(index_file_name)
				local directories = strings.split(theme_index['Icon Theme'].Directories, ",")
				for j,dir in ipairs(directories) do
					table.insert(icon_lookup_path, 1, icon_theme_path .. dir .. '/')
				end
			else
				-- The theme has no index.theme so we just list all folder recursively
				local all_dirs = utils.list_directories(icon_theme_path)
				utils.merge_into_table(icon_lookup_path, all_dirs, true)
			end
		end
	end
	return icon_lookup_path
end

--- Lookup an icon in different folders of the filesystem.
-- @param icon_file Short or full name of the icon.
-- @return full name of the icon.
function icons.lookup_icon(icon_file)
	if not icon_file or icon_file == "" then
		return ""
	end

	local from_cache = icon_cache[icon_file]
	if from_cache ~= nil then
		return from_cache
	end

	if icon_file:sub(1, 1) == '/' and is_format_supported(icon_file) then
		-- If the path to the icon is absolute and its format is
		-- supported, do not perform a lookup.
		local result = awful_util.file_readable(icon_file) and icon_file or nil
		icon_cache[icon_file] = result
		return result
	else
		for i, directory in ipairs(get_icon_lookup_path()) do
			if is_format_supported(icon_file) and awful_util.file_readable(directory .. icon_file) then
				local result = directory .. icon_file
				icon_cache[icon_file] = result
				return result
			else
				-- log.info("Looking for icon %s in %s", icon_file, directory)
				-- Icon is probably specified without path and format,
				-- like 'firefox'. Try to add supported extensions to
				-- it and see if such file exists.
				for _, format in ipairs(icon_formats) do
					local possible_file = directory .. icon_file .. "." .. format
					if awful_util.file_readable(possible_file) then
						icon_cache[icon_file] = possible_file
						return possible_file
					end
				end
			end
		end
		icon_cache[icon_file] = default_icon
		return default_icon
	end
end

return icons
