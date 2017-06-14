local wibox = require('wibox')
local dpi = require('lunaconf.dpi')
local widget_base = require("wibox.widget.base")

local tostring = tostring

local listitem = {}

local image = {}

function listitem:set_icon(icon)
	self._icon:set_image(icon)
end

function listitem:set_highlight(highlight)
	if highlight then
		self._shortcut_bg:set_bg('#2196F3')
	else
		self._shortcut_bg:set_bg(nil)
	end
end

function listitem:set_visible(is_visible)
	if is_visible == self._visible then
		return
	end

	self._visible = is_visible
	if is_visible then
		self:set_widget(self._ui)
	else
		self:set_widget(self._placeholder)
	end
end

function listitem:set_title(title)
	self._title:set_text(title)
end

function listitem:set_description(description)
	self._description:set_markup('<span color="#AAA">' .. description .. '</span>')
end

local function create_ui(self)
	local item = wibox.layout.fixed.horizontal()
	item.fit = function(wi, w, h) return dpi.x(48, self._screen), dpi.y(48, self._screen) end
	self._icon = wibox.widget.imagebox()

	-- icon:set_image(icon_for_desktop_entry(desktop_entry) or default_icon)
	self._icon.fit = function(widget, w, h) return dpi.x(48, self._screen), dpi.y(48, self._screen) end
	self._icon:set_resize(true)
	self._icon.width = dpi.x(48, self._screen)
	self._icon.height = dpi.y(48, self._screen)

	self._title = wibox.widget.textbox(nil, self._screen)
	self._title:set_align('left')
	self._title:set_valign('bottom')

	self._description = wibox.widget.textbox(nil, self._screen)
	self._description:set_valign('top')

	local shortcut = wibox.widget.textbox(nil, self._screen)
	shortcut:set_text(tostring(self._index))
	shortcut:set_align('center')
	shortcut:set_valign('center')
	shortcut.fit = function(wid, w, h) return dpi.x(30, self._screen), dpi.y(30, self._screen) end

	self._shortcut_bg = wibox.container.background(shortcut)

	local text = wibox.layout.flex.vertical()
	text:add(self._title)
	text:add(self._description)

	item:add(self._shortcut_bg)
	item:add(wibox.container.margin(self._icon, dpi.x(8, self._screen), dpi.y(8, self._screen), 0, 0))
	item:add(text)

	self._placeholder = wibox.container.background()
	self._placeholder.fit = function(wi, w, h) return dpi.x(48, self._screen), dpi.y(48, self._screen) end

	return item
end

function new(_, index, screen)
	local self = wibox.container.margin()

	self._screen = screen

	for k, v in pairs(listitem) do
		if type(v) == "function" then
			self[k] = v
		end
	end

	self._index = index
	self._visible = true
	self._ui = create_ui(self)
	self:set_widget(self._ui)
	self:set_top(dpi.y(8, self._screen))
	self:set_bottom(dpi.y(8, self._screen))
	self.fit = function(wi, w, h) return dpi.x(1000, self._screen), dpi.y(68, self._screen) end
	return self
end

return setmetatable(listitem, { __call = new })
