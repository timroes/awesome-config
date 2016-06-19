-- The style of the interface
local theme = {}

theme.font          = "Roboto Light 11"

-- theme.bg_normal     = "linear:0,0:0,28:0,#3A3A3A:1,#202020"
theme.bg_normal = "#F5F5F5AA"
theme.bg_focus      = "linear:0,0:0,28:0,#BEBEBE:1,#EEEEEE"
theme.bg_urgent     = "linear:0,0:0,28:0,#99CC00:1,#739900"
theme.bg_minimize   = "#111111"

theme.fg_normal     = "#FFFFFF"
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

-- Systray
theme.bg_systray = '#113A45'

-- Calendar
theme.cal_today = '#99CC00'

-- Titlebar
theme.titlebar_bg_normal = "#F5F5F5"
theme.titlebar_bg_focus = "#F5F5F5"
theme.titlebar_fg_normal = "#AAAAAA"
theme.titlebar_fg_focus = "#555555"
theme.floating_indicator = '#AED581'
theme.ontop_indicator = '#E57373'

-- Screenbar (the bar on top of each screen)
theme.screenbar_bg = '#333333DD'

-- Tasklist
theme.tasklist_bg_normal = '#00000000'
theme.tasklist_bg_focus = '#F5F5F5EE'

-- Taglist
theme.taglist_bg_normal = '#00000000'
theme.taglist_bg_focus = '#F5F5F5EE'
theme.taglist_badge_bg = '#455A6466'
theme.taglist_badge_fg = '#FFFFFF'
theme.taglist_screentag_bg_focus = '#78909C'

-- Tooltips
theme.tooltip_border_width = 0
theme.tooltip_bg_color = '#3F51B5DD'
theme.tooltip_fg_color = '#FFFFFF'
theme.tooltip_font = "Roboto Thin 14"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- You can use your own command to set your wallpaper
theme.wallpaper = '#333333'

theme.icon_theme = "Paper"

return theme
