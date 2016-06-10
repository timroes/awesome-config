local wibox = require('wibox')
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
	self._title:set_markup(title)
end

function listitem:set_description(description)
	self._description:set_markup('<span color="#AAA">' .. description .. '</span>')
end

local function create_ui(self)
	local item = wibox.layout.fixed.horizontal()
	item.fit = function(wi, w, h) return 48, 48 end
	self._icon = wibox.widget.imagebox()

	-- icon:set_image(icon_for_desktop_entry(desktop_entry) or default_icon)
	self._icon.fit = function(widget, w, h) return 48, 48 end
	self._icon:set_resize(true)
	self._icon.width = 48
	self._icon.height = 48

	self._title = wibox.widget.textbox()
	self._title:set_align('left')
	self._title:set_valign('bottom')

	self._description = wibox.widget.textbox()
	self._description:set_valign('top')

	local shortcut = wibox.widget.textbox()
	shortcut:set_text(tostring(self._index))
	shortcut:set_align('center')
	shortcut:set_valign('center')
	shortcut.fit = function(wid, w, h) return 30, 30 end

	self._shortcut_bg = wibox.widget.background(shortcut)

	local text = wibox.layout.flex.vertical()
	text:add(self._title)
	text:add(self._description)

	item:add(self._shortcut_bg)
	item:add(wibox.layout.margin(self._icon, 8, 8, 0, 0))
	item:add(text)

	self._placeholder = wibox.widget.background()
	self._placeholder.fit = function(wi, w, h) return 48, 48 end

	return item
end

function new(_, index)
	local self = wibox.layout.margin()

	for k, v in pairs(listitem) do
		if type(v) == "function" then
			self[k] = v
		end
	end

	self._index = index
	self._visible = true
	self._ui = create_ui(self)
	self:set_widget(self._ui)
	self:set_top(8)
	self:set_bottom(8)
	self.fit = function(wi, w, h) return 1000, 68 end
	return self
end

return setmetatable(listitem, { __call = new })
