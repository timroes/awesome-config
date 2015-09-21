--- A slightly modified version of awesome's original `menubar.utils` function
--- https://github.com/awesomeWM/awesome/blob/master/lib/menubar/utils.lua
---
--- @author Antonio Terceiro


local glib = require("lgi").GLib
local theme = require("lunaconf.theme")
local awful_util = require("awful.util")

local icons = {}

local all_icon_sizes = {
	'128x128' ,
	'96x96',
	'72x72',
	'64x64',
	'48x48',
	'36x36',
	'32x32',
	'24x24',
	'22x22',
	'16x16'
}

--- List of supported icon formats.
local icon_formats = { "png", "xpm", "svg" }

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
		local paths = glib.get_system_data_dirs()
		table.insert(paths, 1, glib.get_user_data_dir())
		table.insert(paths, 1, glib.get_home_dir() .. '/.icons')
		for k,dir in ipairs(paths)do
			if icon_theme then
				table.insert(icon_theme_paths, dir..'/icons/' .. icon_theme .. '/')
			end
			table.insert(icon_theme_paths, dir..'/icons/hicolor/') -- fallback theme
		end
		for i, icon_theme_directory in ipairs(icon_theme_paths) do
			for j, size in ipairs(all_icon_sizes) do
				-- TODO: another for loop
				table.insert(icon_lookup_path, icon_theme_directory .. size .. '/apps/')
				table.insert(icon_lookup_path, icon_theme_directory .. size .. '/categories/')
				table.insert(icon_lookup_path, icon_theme_directory .. size .. '/devices/')
				table.insert(icon_lookup_path, icon_theme_directory .. size .. '/mimetypes/')
				table.insert(icon_lookup_path, icon_theme_directory .. size .. '/places/')
				table.insert(icon_lookup_path, icon_theme_directory .. size .. '/status/')
			end
		end
		for k,dir in ipairs(paths)do
			-- lowest priority fallbacks
			table.insert(icon_lookup_path, dir..'/pixmaps/')
			table.insert(icon_lookup_path, dir..'/icons/')
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

	if icon_file:sub(1, 1) == '/' and is_format_supported(icon_file) then
		-- If the path to the icon is absolute and its format is
		-- supported, do not perform a lookup.
		return awful_util.file_readable(icon_file) and icon_file or nil
	else
		for i, directory in ipairs(get_icon_lookup_path()) do
			if is_format_supported(icon_file) and awful_util.file_readable(directory .. icon_file) then
				return directory .. icon_file
			else
				-- Icon is probably specified without path and format,
				-- like 'firefox'. Try to add supported extensions to
				-- it and see if such file exists.
				for _, format in ipairs(icon_formats) do
					local possible_file = directory .. icon_file .. "." .. format
					if awful_util.file_readable(possible_file) then
						return possible_file
					end
				end
			end
		end
		return default_icon
	end
end

return icons