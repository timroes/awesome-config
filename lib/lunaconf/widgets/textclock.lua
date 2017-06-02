---------------------------------------------------------------------------
--- Text clock widget.
-- This is a copy of the new textclock widget in awesome master. I will copy it
-- here until awesome 3.6 is released.
--
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Julien Danjou
-- @release @AWESOME_VERSION@
-- @classmod wibox.widget.textclock
---------------------------------------------------------------------------

local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local timer = timer
local DateTime = require("lgi").GLib.DateTime
local log = require('lunaconf.log')

local textclock = { mt = {} }

--- This lowers the timeout so that it occurs "correctly". For example, a timeout
-- of 60 is rounded so that it occurs the next time the clock reads ":00 seconds".
local function calc_timeout(real_timeout)
    return real_timeout - os.time() % real_timeout
end

--- Create a textclock widget. It draws the time it is in a textbox.
--
-- @tparam[opt=" %a %b %d, %H:%M "] string format The time format.
-- @tparam[opt=60] number timeout How often update the time (in seconds).
-- @treturn table A textbox widget.
-- @function wibox.widget.textclock
function textclock.new(format, timeout)
    format = format or " %a %b %d, %H:%M "
    timeout = timeout or 60

    local w = textbox()
		w._private = {}
    local t
    function w._private.textclock_update_cb()
        local time = DateTime.new_now_local():format(format)
				log.info("########## time: %s", time)
        w:set_markup(time)
        t.timeout = calc_timeout(timeout)
        t:again()
        return true -- Continue the timer
    end
    t = timer({ timeout = timeout })
		t:connect_signal("timeout", w._private.textclock_update_cb)
		t:start()
    t:emit_signal("timeout")
    return w
end

function textclock.mt:__call(...)
    return textclock.new(...)
end

--@DOC_widget_COMMON@

--@DOC_object_COMMON@

return setmetatable(textclock, textclock.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
