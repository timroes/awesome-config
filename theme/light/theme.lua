-- The style of the interface
local theme = {}

local highlight_color   = '#2196F3'
local text_on_highlight = '#FFFFFF'
local error_color       = '#F44336'

local dark_text         = '#333333'

theme.font          = "Source Sans Pro Light 11"
theme.large_font   = "Source Sans Pro 14"

theme.bg_normal     = "#F5F5F5AA"
theme.bg_focus      = "#BEBEBE"
theme.bg_urgent     = "linear:0,0:0,28:0,#99CC00:1,#739900"
theme.bg_minimize   = "#111111"

theme.fg_normal     = "#FFFFFF"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#000000"
theme.fg_minimize   = "#666666"

theme.border_width  = "1"
theme.border_normal = "#333333"
theme.border_focus  = highlight_color
theme.border_marked = "#339933"

-- Clientswitcher
theme.clientswitcher_font = theme.large_font
theme.clientswitcher_hotkey_font = 'monospace 16'
theme.clientswitcher_hotkey_bg = highlight_color

-- Dialogs
theme.dialog_bg = '#FFFFFF'
theme.dialog_fg = dark_text
theme.dialog_bar_fg = highlight_color
theme.dialog_bar_disabled_fg = '#AAAAAA'
theme.dialog_bar_bg = '#E0E0E0'

-- Notifications
theme.notification_bg = "#FFFFFF"
theme.notification_fg = dark_text
theme.notitication_border_width = 0
theme.notification_margin = 7
theme.notification_spacing = 7
theme.notification_padding = 5
theme.notification_opacity = 0.9

-- Calendar
theme.cal_today_bg = highlight_color
theme.cal_today = text_on_highlight

-- Battery widget
theme.battery_bar_color = highlight_color
theme.battery_warning_color = error_color

-- Titlebar
theme.titlebar_bg_normal = "#F5F5F5"
theme.titlebar_bg_focus = "#F5F5F5"
theme.titlebar_fg_normal = "#AAAAAA"
theme.titlebar_fg_focus = "#555555"
theme.ontop_indicator = '#E57373'

-- Screenbar (the bar on top of each screen)
theme.screenbar_bg = '#454545'
theme.screenbar_fg = '#E0E0E0'
theme.screenbar_inactive_fg = '#888888'

-- Systray
theme.bg_systray = theme.screenbar_bg

-- Tasklist
theme.tasklist_bg_normal = '#00000000'
theme.tasklist_bg_focus = '#F5F5F5EE'

theme.tag_name_font = 'monospace 11'
theme.tag_color_bg = '#CCCCCC'
theme.tag_color_selected_bg = highlight_color

-- Taglist
theme.taglist_bg_normal = '#00000000'
theme.taglist_badge_bg = '#455A6466'
theme.taglist_badge_fg = '#FFFFFF'
theme.taglist_screentag_bg_focus = '#78909C'

-- Tooltips
theme.tooltip_border_width = 0
theme.tooltip_bg = theme.notification_bg
theme.tooltip_fg = theme.notification_fg

-- Wallpaper color if no wallpaper is set in config
theme.wallpaper = '#F1F1F1'

theme.icon_theme = "Paper"

return theme
