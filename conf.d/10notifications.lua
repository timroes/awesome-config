local naughty = require('naughty')
local beautiful = require('beautiful')
local lntheme = require("lunaconf.theme")

local theme = lntheme.get()

naughty.config.spacing = 10
naughty.config.padding = 10

naughty.config.defaults.icon_size = 48
naughty.config.defaults.position = 'top_right'
naughty.config.defaults.border_width = theme.notify_border_width
naughty.config.defaults.opacity = theme.notify_opacity or 1.0
naughty.config.defaults.margin = 7

naughty.config.presets.normal.bg = theme.notify_normal_bg or "#000000"
naughty.config.presets.normal.fg = theme.notify_normal_fg or "#FFFFFF"
