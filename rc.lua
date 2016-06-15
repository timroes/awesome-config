-- Standard awesome library
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Notification library
local naughty = require("naughty")

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

-- Add luarocks pathes to package pathes
local luarockPath = awful.util.pread('luarocks path --lr-path')
local luarockCpath = awful.util.pread('luarocks path --lr-cpath')

-- Set path configuration
local configpath = awful.util.getdir('config')
scriptpath = configpath .. "/scripts/"
package.path = configpath .. "/lib/?.lua;" .. configpath .. "/lib/?/init.lua;" .. luarockPath .. ";" .. package.path
package.cpath = luarockCpath .. ";" .. package.cpath

local log = require('lunaconf.log')

-- Include functions
dofile(configpath .. "/functions.lua")

-- Clear all shortcuts before including any config files
root.keys({ })

-- {{{ Load custom scripts from custom.d directory
local lfs = require('lfs')
local confs = {}
local customdir = configpath .. '/conf.d/'
for s in lfs.dir(customdir) do
	local f = lfs.attributes(customdir .. s)
	if s:sub(-4) == ".lua" and f.mode == "file" then
		table.insert(confs, customdir .. s)
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
