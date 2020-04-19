-- The style of the interface
local theme = {}

-- Define the color palette to use
local colors = {
	text = {
		dark = '#343741'
	},
	bg = {
		green = '#54B399',
		blue = '#006BB4',
		red = '#E7664C',
		pink = '#EE789D',
		rose = '#E4A6C7',
		yellow = '#D6BF57'
	} 
}

local highlight_color = colors.bg.blue
local highlight_text_bg = '#9CCFF7'
local highlight_text_color = colors.text.dark

local panel_bg = '#343741'

theme.font          = "Source Sans Pro 11"
theme.large_font   = "Source Sans Pro 14"

theme.bg_normal     = "#F5F5F5AA"
theme.bg_focus      = "#BEBEBE"
theme.bg_urgent     = "linear:0,0:0,28:0,#99CC00:1,#739900"
theme.bg_minimize   = "#111111"

theme.fg_normal     = "#D3DAE6"
theme.fg_focus      = "#000000"
theme.fg_urgent     = "#000000"
theme.fg_minimize   = "#666666"

theme.border_width  = "1"
theme.border_normal = "#333333"
theme.border_focus  = highlight_color
theme.border_marked = "#339933"

-- Dialogs
theme.dialog_bg = '#FFFFFF'
theme.dialog_fg = colors.text.dark
theme.dialog_bar_fg = highlight_color
theme.dialog_bar_disabled_fg = '#AAAAAA'
theme.dialog_bar_bg = '#E0E0E0'
theme.dialog_chooser_highlight = highlight_text_bg
theme.dialog_chooser_highlight_border = highlight_color

-- Notifications
theme.notification_bg = "#FFFFFF"
theme.notification_fg = colors.text.dark
theme.notitication_border_width = 0
theme.notification_margin = 7
theme.notification_spacing = 7
theme.notification_padding = 5
theme.notification_opacity = 0.9
theme.notification_width = 320
theme.notification_icon_size = 42

-- Battery widget
theme.battery_bar_color = highlight_color
theme.battery_warning_color = colors.bg.red

-- Titlebar
theme.titlebar_bg_normal = "#F5F5F5"
theme.titlebar_bg_focus = "#F5F5F5"
theme.titlebar_fg_normal = "#AAAAAA"
theme.titlebar_fg_focus = "#555555"
theme.ontop_indicator = colors.bg.red

-- Screenbar (the bar on top of each screen)
theme.screenbar_bg = panel_bg
theme.screenbar_fg = '#E0E0E0'

-- Systray
theme.bg_systray = theme.screenbar_bg

-- Tasklist
theme.tasklist_bg_normal = '#00000000'
theme.tasklist_bg_focus = '#F5F5F5EE'

theme.tag_name_font = 'monospace 11'
theme.tag_color_bg = '#CCCCCC'
theme.tag_color_selected_bg = highlight_color

-- Sidebar
theme.sidebar_bg = panel_bg
theme.sidebar_trigger_color = '#69707D'
theme.sidebar_panel_bg = '#40434f'
theme.sidebar_dnd_color = colors.bg.pink
theme.sidebar_screensleep_color = colors.bg.yellow

-- Calendar
theme.calendar_today = colors.bg.green
theme.calendar_hover = highlight_text_bg
theme.calendar_hover_text = highlight_text_color
theme.calendar_highlight = colors.bg.rose
theme.calendar_highlight_text = highlight_text_color

-- Switches
theme.switch_bg = '#98A2B3'
theme.switch_bg_active = highlight_color
theme.switch_handle = '#F5F7FA'

-- Tooltips
theme.tooltip_border_width = 0
theme.tooltip_bg = theme.notification_bg
theme.tooltip_fg = theme.notification_fg

-- Wallpaper color if no wallpaper is set in config
theme.wallpaper = '#131b2b'

theme.icon_theme = "Paper"

return theme
