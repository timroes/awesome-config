-- This is a modified version of the original awful.widget.clienticon
-- that does also use icons looked up from the icon folder in case
-- the client does not specify an icon.

local base = require('wibox.widget.base')
local gears = require('gears')
local cairo = require('lgi').cairo

local notify = require('lunaconf.notify')
local lunaconf = {
	icons = require('lunaconf.icons')
}

local clienticon = {}
local instances = setmetatable({}, { __mode = "k" })

local function find_best_icon(client, width, height)
	local best, best_size
	for k, size in ipairs(client.icon_sizes) do
			if not best then
					best, best_size = k, size
			else
					local best_too_small = best_size[1] < width or best_size[2] < height
					local best_too_large = best_size[1] > width or best_size[2] > height
					local better_because_bigger = best_too_small and size[1] > best_size[1] and size[2] > best_size[2]
					local better_because_smaller = best_too_large and size[1] < best_size[1] and size[2] < best_size[2]
							and size[1] >= width and size[2] >= height
					if better_because_bigger or better_because_smaller then
							best, best_size = k, size
					end
			end
	end
	return best, best_size
end

function clienticon:draw(_, cr, width, height)
	local c = self._private.client
	if not c or not c.valid then
		return
	end

	local index, size = find_best_icon(c, width, height)
	local s, swidth, sheight
	if not index then
		local icon = lunaconf.icons.lookup_icon(c.instance)
		if not icon then
			-- TODO: draw replacement icon
			return
		end
		s = gears.surface.load(icon)
		swidth, sheight = gears.surface.get_size(s)
	else
		s = gears.surface(c:get_icon(index))
		swidth = size[1]
		sheight = size[2]
	end

	local aspect_w = width / swidth
	local aspect_h = height / sheight
	local aspect = math.min(aspect_w, aspect_h)
	cr:scale(aspect, aspect)

	cr:set_source_surface(s, 0, 0)
	cr:paint()

	if c.minimized then
		-- Draw minimized client icons in grayscale
		local pattern = cairo.Pattern.create_for_surface(s)
		cr:rectangle(0, 0, swidth, sheight)
		cr:set_source_rgb(0, 0, 0);
		cr:set_operator(cairo.Operator.HSL_SATURATION)
		cr:mask(pattern)
	else
	end
end

function clienticon:fit(_, width, height)
		local c = self._private.client
		if not c or not c.valid then
				return 0, 0
		end

		local index, size = find_best_icon(c, width, height)
		if not index then
			local icon = lunaconf.icons.lookup_icon(c.instance)
			if not icon then
				return 0, 0
			end
			local s = gears.surface.load(icon)
			w, h = gears.surface.get_size(s)
			size = { w, h }
		end

		local w, h = size[1], size[2]

		if w > width then
				h = h * width / w
				w = width
		end
		if h > height then
				w = w * height / h
				h = height
		end

		if h == 0 or w == 0 then
				return 0, 0
		end

		local aspect = math.min(width / w, height / h)
		return w * aspect, h * aspect
end

--- The widget's @{client}.
--
-- @property client
-- @param client

function clienticon:get_client()
		return self._private.client
end

function clienticon:set_client(c)
		if self._private.client == c then return end
		self._private.client = c
		self:emit_signal("widget::layout_changed")
		self:emit_signal("widget::redraw_needed")
end

--- Returns a new clienticon.
-- @tparam client c The client whose icon should be displayed.
-- @treturn widget A new `widget`
-- @function awful.widget.clienticon
local function new(c)
		local ret = base.make_widget(nil, nil, {enable_properties = true})

		gears.table.crush(ret, clienticon, true)

		ret._private.client = c

		instances[ret] = true

		return ret
end

local function redraw_matching(c)
	for obj in pairs(instances) do
			if obj._private.client.valid and obj._private.client == c then
					obj:emit_signal("widget::layout_changed")
					obj:emit_signal("widget::redraw_needed")
			end
	end
end

client.connect_signal("property::icon", redraw_matching)
client.connect_signal("property::minimized", redraw_matching)

return setmetatable(clienticon, {
		__call = function(_, ...)
				return new(...)
		end
})
