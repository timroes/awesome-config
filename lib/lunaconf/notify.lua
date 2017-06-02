local naughty = require('naughty')
local lunaconf = {
	icons = require('lunaconf.icons')
}

local notify = {}

local notifications = {}
local notification_icons = {}

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
	local previous_icon = notification_icons[key]
	-- Replace text and reset timeout if there is already a previous notification
	-- and the icon hasn't been changed since.
	if current_notif and previous_icon == notification.icon then
		naughty.replace_text(current_notif, notification.title, notification.text)
		if notification.timeout ~= 0 then
			naughty.reset_timeout(current_notif, notification.timeout or naughty.config.defaults.timeout)
		end
	else
		local orig_destroy = notification.destroy
		local destroy = function(...)
			notifications[key] = nil
			notification_icons[key] = nil
			if orig_destroy then
				orig_destroy(...)
			end
		end

		notification.destroy = destroy

		-- If there is already a previous notification for this key replace it.
		-- This will happen if the notification has another icon, so we can't use
		-- replace_text above.
		if current_notif then
			notification.replaces_id = current_notif.id
		end

		-- Store icon of this notification for later comparison
		notification_icons[key] = notification.icon

		local notif = notify.show(notification)
		notifications[key] = notif
	end
end


return notify
