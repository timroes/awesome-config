local awful = require("awful")
local screen = screen
local client = client
local mouse = mouse
local screen = screen
local mousegrabber = mousegrabber
local table = table

local clients = {}

local attributes = {}

--- Start moving the client in a "smart" way.
--- If the client is floating it will immediately move (and snap to other clients).
--- If it is not a floating client, a small threshold will be added before the client
--- will be made floating and starts moving.
--- When the movement ends and the client exactly fills a maximized screen it will be made
--- unfloating again.
-- @param c The client to move.
function clients.smart_move(c)
	clients.move(c, {
		snap = 8,
		threshold = c.floating and 0 or 8,
		threshold_cb = function() c.floating = true end,
		finished_cb = function()
			local s = screen[c.screen].workarea
			local g = c:geometry()
			if awful.layout.get(c.screen) == awful.layout.suit.max
					and s.x == g.x
					and s.y == g.y
					and s.width == g.width
					and s.height == g.height then
				c.floating = false
			end
		end
	})
end

--- Let a client follow the mouse until all mouse button are released.
--- Only moves floating clients or clients on a floating layout.
-- @param c The client to move, or the focused one if nil.
-- @param args An optional table with arguments:
-- @param args.snap Clients will snap to screen borders and other clients in that distance
-- @param args.threshold Mouse needs to move at least that far before moving will be started.
-- @param args.threshold_cb A callback function that will be called as soon as the defined
--                          threshold has been passed and the client actually starts moving.
--                          Won't be called when you specify a threshold
-- @param args.finished_cb An optional callback function, that will be called
--                 when moving the client has been finished. The client
--                 that has been moved will be passed to that function.
function clients.move(c, args)
	local c = c or client.focus
	local args = args or {}

	client.focus = c
	c:raise()

	if not c
		or c.fullscreen
		or c.type == "desktop"
		or c.type == "splash"
		or c.type == "dock" then
		return
	end

	local snap = args.snap or 0
	local threshold = args.threshold or 0
	local threshold_cb = args.threshold_cb
	local finished_cb = args.finished_cb

	local client_orig = c:geometry()
	local mouse_orig = mouse.coords()
	-- The offset of the mouse click inside the window
	local offset_x = mouse_orig.x - client_orig.x
	local offset_y = mouse_orig.y - client_orig.y
	-- Only allow moving in the non-maximized directions
	local fixed_x = c.maximized_horizontal
	local fixed_y = c.maximized_vertical

	local is_moving = false

	mousegrabber.run(function (ev)
			for k, v in ipairs(ev.buttons) do
				if v then
					-- If still under threshold check if we should start moving
					if not is_moving then
						local diff_x = math.abs(ev.x - mouse_orig.x)
						local diff_y = math.abs(ev.y - mouse_orig.y)
						if math.sqrt(diff_x * diff_x + diff_y * diff_y) > threshold then
							is_moving = true
							if threshold_cb then threshold_cb() end
						end
					end

					-- If we passed the threshold already, move the client
					if is_moving then
						if awful.layout.get(c.screen) == awful.layout.suit.floating or c.floating then
							local x = ev.x - offset_x
							local y = ev.y - offset_y
							c:geometry(awful.mouse.snap(c, snap, x, y, fixed_x, fixed_y))
						end
					end
					return true
				end
			end

			if finished_cb then
				finished_cb(c)
			end
			return false
	end, "fleur")
end

return clients
