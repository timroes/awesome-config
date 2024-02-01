
const colors = {
  blue: {
    darkest: '#0f172a',
    dark: '#24283b',
    medium: '#3730a3',
    light: '#79AAD9',
  },
  gray: {
    darkest: '#030712',
    medium: '#6b7280',
    lightest: '#f9fafb',
  },
  pink: {
    light: '#f0abfc',
  },
  green: {
    medium: '#54B399',
  },

  // Legacy color definitions
  text: {
    dark: '#343741',
    gray: '#69707D',
    light_gray: '#98A2B3'
  },
  bg: {
    green: '#54B399',
    blue: '#006BB4',
    lightBlue: '#79AAD9',
    red: '#BD271E',
    pink: '#EE789D',
    rose: '#E4A6C7',
    yellow: '#D6BF57',
    orange: '#DA8B45',
    purple: '#A987D1'
  }
} as const;

const highlight_color = colors.bg.blue
const highlight_text_bg = colors.bg.lightBlue;
const highlight_text_color = colors.text.dark;

const base = {
  font: {
    regular: 'Inter Light 10',
    bold: 'Inter Bold 10',
    large: 'Inter Regular 14',
  },

  bg: {
    base: colors.blue.darkest,
    panel: colors.blue.dark,
  },

  text: {
    dark: colors.gray.darkest,
    light: colors.gray.lightest,
  },

  highlight: {
    disabled: colors.gray.medium,
    regular: colors.blue.light,
    success: colors.green.medium,
  },

  transparent: '#00000000',
} as const;

const clientlist = {
  bg: {
    normal: base.bg.panel,
    focused: colors.blue.medium,
    minimized: base.bg.panel,
    urgent: colors.pink.light,
  },
  fg: {
    normal: base.text.light,
    focused: base.text.light,
    minimized: colors.gray.medium,
    urgent: base.text.dark,
  },
  indicators: {
    ontop: colors.pink.light,
  },
};

export const theme = { ...base, clientlist } as const;

/**
 * Only settings that are required in beautiful to be set, should be part of this export.
 */
export const beautiful = {
  font: theme.font.regular,
  large_font: theme.font.large,

  bg_normal    : "#F5F5F5AA",
  bg_focus     : "#BEBEBE",
  bg_urgent    : "linear:0,0:0,28:0,#99CC00:1,#739900",
  bg_minimize  : "#111111",

  fg_normal    : "#D3DAE6",
  fg_focus     : "#000000",
  fg_urgent    : "#000000",
  fg_minimize  : "#666666",

  border_width : "1",
  border_normal: "#333333",
  border_focus : highlight_color,
  border_marked: "#339933",

  dialog_bg: '#FFFFFF',
  dialog_fg: colors.text.dark,
  dialog_bar_fg: highlight_color,
  dialog_bar_disabled_fg: '#AAAAAA',
  dialog_bar_bg: '#E0E0E0',
  dialog_chooser_highlight: highlight_text_bg,
  dialog_chooser_highlight_border: highlight_color,

  notification_bg: "#FFFFFF",
  notification_fg: colors.text.dark,
  notitication_border_width: 0,
  notification_margin: 7,
  notification_spacing: 7,
  notification_padding: 5,
  notification_opacity: 0.9,
  notification_width: 320,
  notification_icon_size: 42,

  bg_systray: theme.bg.base,
  systray_icon_spacing: 8,

  tag_color_fg: theme.bg.base,
  tag_color_bg: colors.text.gray,
  tag_color_selected_bg: colors.bg.lightBlue,

  sidebar_bg: theme.bg.base,
  sidebar_shaded_text: colors.text.light_gray,
  sidebar_trigger_color: colors.text.gray,
  sidebar_panel_bg: colors.blue.dark,
  sidebar_dnd_color: colors.bg.pink,
  sidebar_screensleep_color: colors.bg.yellow,

  stats_memory: colors.bg.purple,
  stats_cpu: colors.bg.purple,

  calendar_today: highlight_text_bg,
  calendar_hover: highlight_text_bg,
  calendar_hover_text: highlight_text_color,
  calendar_highlight: colors.bg.rose,
  calendar_highlight_text: highlight_text_color,

  battery_charging: colors.bg.lightBlue,
  battery_fully_charged: colors.bg.blue,
  battery_good: colors.bg.green,
  battery_empty: colors.bg.orange,
  battery_critical: colors.bg.red,

  switch_bg: '#98A2B3',
  switch_bg_active: highlight_color,
  switch_handle: '#F5F7FA',

  tooltip_border_width: 0,
  tooltip_bg: "#FFFFFF",
  tooltip_fg: colors.text.dark,

  wallpaper: '#131b2b',

  icon_theme: "Paper",
};
