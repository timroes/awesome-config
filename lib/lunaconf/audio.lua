-- A module to offer helper to control volume, etc.
-- This module requires alsa-utils to be installed on the system.
local awful = require('awful')

local tonumber = tonumber
local tostring = tostring

local audio = {}

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
		-- If a callback has been specified inform whether sound is no on or off
		if callback then
			callback(parse_amixer_output(stdout))
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
