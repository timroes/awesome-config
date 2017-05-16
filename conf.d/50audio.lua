local awful = require('awful')
local lunaconf = require('lunaconf')

local function show_volume_notification(is_muted, volume)
	-- Number of blocks to draw for volume (0 volume = 0, 1-9 = 1, ..., 90-99 = 10, 100 = 11)
	local volume_rounded = volume == 0 and 0 or math.floor(volume / 10) + 1
	-- Depending on mute state use different shaded block drawing chars to paint a bar
	local volume_blocks = string.rep(is_muted and '▒' or '█', volume_rounded) .. string.rep('░', 11 - volume_rounded)
	lunaconf.notify.show_or_update('audio.volume', {
		title = 'Volume' .. (is_muted and ' (off)' or ' (' .. tostring(volume) .. '%)'),
		text = volume_blocks,
		icon = is_muted and 'audio-volume-muted' or 'audio-volume-high',
		timeout = 2
	})
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
