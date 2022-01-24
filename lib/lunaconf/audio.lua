-- A module to offer helper to control volume, etc.
-- This module requires alsa-utils to be installed on the system.
local awful = require('awful')
local lunaconf = {
	config = require('lunaconf.config'),
	notify = require('lunaconf.notify')
}

local tonumber = tonumber
local tostring = tostring

local audio = {}

local additional_masters = lunaconf.config.get('audio.additional_master_channels', nil)

local function parse_amixer_output(output)
	local is_muted = output:find('%[on%]') == nil
	local volume = output:match('%[(%d+)%%%]')
	return is_muted, tonumber(volume)
end

-- Toggle the main capture input mute.
-- The callback will be passed a boolean whether the capture is now muted
function audio.toggle_mic_mute(callback)
	awful.spawn.easy_async('amixer set Capture toggle', function(stdout)
		if callback then
			callback(stdout:find('%[on%]') == nil)
		end
	end)
end

-- Toggle the main output mute.
-- The callback will be passed as first parameter whether the audio is now muted
-- and the volume level (between 0 and 100) as second parameter.
function audio.toggle_mute(callback)
	awful.spawn.easy_async('amixer set Master toggle', function(stdout)
		local is_muted, volume = parse_amixer_output(stdout)
		-- If we're unmuting we also unmute additional master channels that have
		-- been specified in the config. This is a workaround for amixer not unmuting
		-- e.g. Speaker on some machines after unmuting Master.
		-- see https://bugs.launchpad.net/ubuntu/+source/alsa-utils/+bug/1026331
		-- see https://bugs.launchpad.net/ubuntu/+source/pulseaudio/+bug/878986
		if additional_masters and not is_muted then
			for _,m in ipairs(additional_masters) do
				awful.spawn.spawn('amixer set ' .. m .. ' on')
			end
		end
		-- If a callback has been specified inform whether sound is no on or off
		if callback then
			callback(is_muted, volume)
		end
	end)
end

-- Change the master volume by the specified percentage (positive or negative value).
-- The callback will be passed as first parameter whether the audio is muted
-- and the new volume level (between 0 and 100) as second parameter.
function audio.change_volume(percentage, callback)
	local volume_change = tostring(math.abs(percentage)) .. '%' .. (percentage < 0 and '-' or '+')
	awful.spawn.easy_async('amixer set Master ' .. volume_change, function(stdout)
		if callback then
			callback(parse_amixer_output(stdout))
		end
	end)
end

return audio
