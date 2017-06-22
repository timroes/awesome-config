local awful = require('awful')
local lunaconf = require('lunaconf')

local dialog = lunaconf.dialogs.bar('audio-volume-high', 1)

local function show_volume_notification(is_muted, volume)
	dialog:set_value(volume)
	dialog:set_disabled(is_muted)
	dialog:set_icon(is_muted and 'audio-volume-muted' or 'audio-volume-high')
	dialog:show()
end

local function toggle_mute()
	lunaconf.audio.toggle_mute(show_volume_notification)
end

local function change_volume(direction)
	lunaconf.audio.change_volume(direction, show_volume_notification)
end

local function toggle_mic_mute()
	lunaconf.audio.toggle_mic_mute(function(is_muted)
		lunaconf.notify.show_or_update('audio.mic_mute', {
			title = 'Microphone',
			text = is_muted and 'is muted' or 'is unmuted',
			icon = 'audio-input-microphone-high-panel',
			timeout = 2
		})
	end)
end

-- Register all media hotkeys for volume and mute control.
lunaconf.keys.globals(
	awful.key({ }, 'XF86AudioMute', toggle_mute),
	awful.key({ }, 'XF86AudioRaiseVolume', function() change_volume(2) end),
	awful.key({ }, 'XF86AudioLowerVolume', function() change_volume(-2) end),
	awful.key({ }, 'XF86AudioMicMute', toggle_mic_mute),
	awful.key({ lunaconf.config.MOD }, 'XF86AudioMute', toggle_mic_mute)
)
