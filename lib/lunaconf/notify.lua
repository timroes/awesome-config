local naughty = require('naughty')
local lunaconf = {
	icons = require('lunaconf.icons')
}

local notify = {}

local notifications = {}

--- A wrapper around naughty to show notifications.
-- The notification object is the same format as passed to naughty.notify().
-- This method does uses lunaconf.icons.lookup_icon() to lookup the icons
-- according to freedesktop spec.
function notify.show(notification)
	if notification.icon then
		notification.icon = lunaconf.icons.lookup_icon(notification.icon)
	end
	return naughty.notify(notification)
end

--- Shows or updates a notification with the specified key.
-- If a notification with that key is already shown, its text and title will
-- be updated. If no notification for that key is shown a new notification
-- will be shown.
function notify.show_or_update(key, notification)
	local current_notif = notifications[key]
	if current_notif then
		naughty.replace_text(current_notif, notification.title, notification.text)
		if notification.timeout ~= 0 then
			naughty.reset_timeout(current_notif, notification.timeout or naughty.config.defaults.timeout)
		end
	else
		local orig_destroy = notification.destroy
		local destroy = function(...)
			notifications[key] = nil
			if orig_destroy then
				orig_destroy(...)
			end
		end

		notification.destroy = destroy

		local notif = notify.show(notification)
		notifications[key] = notif
	end
end


return notify
