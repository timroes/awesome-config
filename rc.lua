-- Require the luarocks loader for luarocks dependencies
require('luarocks.loader')

-- Standard awesome library
local gears = require('gears')

-- Add our lib folder to the require lookup path
local configpath = gears.filesystem.get_configuration_dir()
package.path = configpath .. "/lib/?.lua;" .. configpath .. "/lib/?/init.lua;" .. package.path

local naughty = require('naughty')

function dbg(string)
	naughty.notify({
		icon = 'preferences-system',
		timeout = 0,
		text = tostring(string)
	})
end

-- {{{ Error handling
-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
				text = err })
		in_error = false
	end)
end
-- }}}

-- Add inspect as global variable, so we can just use it during development
inspect = require('inspect')

local log = require('lunaconf.log')
local awful = require('awful')

-- Clear all shortcuts before including any config files
root.keys({ })

-- {{{ Load custom scripts from conf.d directory
local lfs = require('lfs')
local confs = {}
local confd = configpath .. '/conf.d/'
for s in lfs.dir(confd) do
	local f = lfs.attributes(confd .. s)
	if s:sub(-4) == ".lua" and f.mode == "file" then
		table.insert(confs, confd .. s)
	end
end
-- Load conf files in alphabetical order
table.sort(confs)
for i,conf in pairs(confs) do
	local config = awful.util.checkfile(conf)
	if type(config) == 'function' then
		log.info('Loading config file %s', conf)
		config()
	else
		log.err('Skipping %s due to error: %s', conf, config)
	end
end
-- }}}
