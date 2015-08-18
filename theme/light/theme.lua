-- The style of the interface
local theme = {}

theme.font          = "Roboto Thin 11"

-- theme.bg_normal     = "linear:0,0:0,28:0,#3A3A3A:1,#202020"
theme.bg_normal = "#F5F5F555"
theme.bg_focus      = "linear:0,0:0,28:0,#BEBEBE:1,#EEEEE"
theme.bg_urgent     = "linear:0,0:0,28:0,#99CC00:1,#739900"
theme.bg_minimize   = "#111111"

theme.fg_normal     = "#555555"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#000000"
theme.fg_minimize   = "#666666"

theme.border_width  = "1"
theme.border_normal = "#333333"
theme.border_focus  = "#33B5E5"
theme.border_marked = "#339933"

-- Notifications
theme.notify_normal_bg = "#444444"
theme.notify_normal_fg = "#FFFFFF"
theme.notify_border_width = "0"
theme.notify_opacity = 0.9

theme.bg_systray = '#2F2F2F'

-- Calendar
theme.cal_today = '#99CC00'

-- Titlebar
theme.titlebar_bg_normal = "#F5F5F599"

--theme.titlebar_bg_focus = "linear:0,0:0,28,0,#5eb942:1,#429b2e"
-- theme.titlebar_bg_focus = "linear:0,0:0,28,0,#a6d897:1,#97c88c"

theme.titlebar_bg_focus = "#F5F5F599"
theme.titlebar_fg_normal = "#AAAAAA"
theme.titlebar_fg_focus = "#555555"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"o

-- You can use your own command to set your wallpaper
theme.wallpaper = "wallpaper.jpg" 

-- You can use your own layout icons like this:
theme.layout_fairh = "/usr/share/awesome/themes/default/layouts/fairhw.png"
theme.layout_fairv = "/usr/share/awesome/themes/default/layouts/fairvw.png"
theme.layout_floating  = "/usr/share/awesome/themes/default/layouts/floatingw.png"
theme.layout_magnifier = "/usr/share/awesome/themes/default/layouts/magnifierw.png"
theme.layout_max = "/usr/share/awesome/themes/default/layouts/maxw.png"
theme.layout_fullscreen = "/usr/share/awesome/themes/default/layouts/fullscreenw.png"
theme.layout_tilebottom = "/usr/share/awesome/themes/default/layouts/tilebottomw.png"
theme.layout_tileleft   = "/usr/share/awesome/themes/default/layouts/tileleftw.png"
theme.layout_tile = "/usr/share/awesome/themes/default/layouts/tilew.png"
theme.layout_tiletop = "/usr/share/awesome/themes/default/layouts/tiletopw.png"
theme.layout_spiral  = "/usr/share/awesome/themes/default/layouts/spiralw.png"
theme.layout_dwindle = "/usr/share/awesome/themes/default/layouts/dwindlew.png"


return theme
