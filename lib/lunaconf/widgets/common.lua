local awful = require('awful')
local wibox = require('wibox')
local layout_badge = require('lunaconf.layouts.badge')
local utils = require('lunaconf.utils')
local icons = require('lunaconf.icons')
local theme = require('lunaconf.theme')
local dpi = require('lunaconf.dpi')

local common = {}

local default_icon = icons.lookup_icon('image-missing')
local root_icon = icons.lookup_icon('changes-prevent')

local theme = theme.get()

function common.create_buttons(buttons, object)
	if buttons then
		local btns = {}
		for kb, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them the the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = button { modifiers = b.modifiers, button = b.button }
			btn:connect_signal("press", function () b:emit_signal("press", object) end)
			btn:connect_signal("release", function () b:emit_signal("release", object) end)
			btns[#btns + 1] = btn
		end

		return btns
	end
end

local function screen_tag(screen)
	local label = wibox.widget.textbox(screen)
	label:set_align('center')
	label:set_valign('center')
	label.fit = function (wibox, w, h)
		return math.min(w, h), math.min(w, h)
	end
	local hk_badge = wibox.container.background(label)
	hk_badge:set_bg(theme.taglist_badge_bg or theme.bg_normal)
	local margin = wibox.container.margin(hk_badge, 6, 6, 6, 6)
	return margin
end

local function hotkey_badge(hotkey)
	local hk_label = wibox.widget.textbox(hotkey:upper())
	hk_label:set_align('center')
	hk_label:set_valign('center')
	hk_label.fit = function (wibox, w, h) return 40, 40 end
	local hk_badge = wibox.container.background(hk_label)
	hk_badge:set_bg(theme.taglist_badge_bg or theme.bg_normal)
	return hk_badge
end

-- Function to render one item in the task list
function common.icon_widgets(screen, w, buttons, label, data, objects)

	-- TODO: CLEAN THIS METHOD UP!!!

	-- update the widgets, creating them if needed
	w:reset()
	for i, o in ipairs(objects) do
		local is_client = type(o) == 'client'
		local is_tag = type(o) == 'tag'
		local is_screen_tag = is_tag and awful.tag.getproperty(o, 'screen_tag')

		local cache = data[o]
		local ib, tb, bgb, m, spacer, tooltip, main
		if cache then
			ib = cache.ib
			bgb = cache.bgb
			im = cache.im
			tooltip = cache.tooltip
			main = cache.main
		else
			ib = wibox.widget.imagebox()
			bgb = wibox.container.background()
			main = layout_badge(bgb)
			local x_margin = dpi.x(4, screen)
			local y_margin = dpi.y(4, screen)
			im = wibox.container.margin(ib, x_margin, x_margin, y_margin, y_margin)
			tooltip = awful.tooltip({
				margin_topbottom = 400, -- does not work yet
				margin_leftright = 50
			})

			-- And all of this gets a background
			bgb:set_widget(im)

			bgb:buttons(common.create_buttons(buttons, o))

			if is_client and utils.user_of_pid(o.pid) == 'root' then
				local rooticon = wibox.widget.imagebox(root_icon)
				main:add_badge(rooticon, 'right', 'bottom')
			end

			if is_tag then
				if is_screen_tag then
					im:set_widget(screen_tag(o.name))
				end
				local hotkey = awful.tag.getproperty(o, 'hotkey')
				if hotkey then
					main:add_badge(hotkey_badge(hotkey), 'right', 'bottom')
				end
			end

			data[o] = {
				ib = ib,
				bgb = bgb,
				im = im,
				tooltip = tooltip,
				main = main
			}
		end

		-- Fit tooltip to screens dpi
		dpi.textbox(tooltip.textbox, screen)

		local text, bg, bg_image, icon = label(o)

		if is_screen_tag then
			-- For screen tags apply color to text box bg and not whole button
			local box_bg
			if o.selected then
				box_bg = theme.taglist_screentag_bg_focus or bg
			else
				box_bg = theme.taglist_badge_bg or bg
			end
			im.widget.widget:set_bg(box_bg)
		else
			bgb:set_bg(bg)
		end

		if type(bg_image) == "function" then
			bg_image = bg_image(tb,o,m,objects,i)
		end
		bgb:set_bgimage(bg_image)
		-- TODO: for tag only do it once and with another default icon
		local ic = icon or icons.lookup_icon(o.instance) or icons.lookup_icon(o.class) or default_icon
		if ic then
			ib:set_image(ic)
		end

		-- TODO: make minimized window less opaque (requires #405)

		if type(o) == 'client' then
			tooltip:set_text(o.name or "<Unknown>")
			tooltip:add_to_object(bgb)
		end

		w:add(main)
	end
end

return common
