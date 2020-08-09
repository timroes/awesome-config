local notify = require('lunaconf.notify')
local awful = require('awful')
local gears = require('gears')
local lunaconf = {
	screens = require('lunaconf.screens')
}
local screen = screen
local client = client
local widget = require('lunaconf.tags.widget')

local module = {}

local selected_tag_index = 1
local tag_count = 1

-- ############
-- Private APIs
-- ############

local function create_tag(s)
	return awful.tag.add('🏷', {
		screen = s,
		layout = awful.layout.suit.max,
		common_tag = true		
	})
end

-- This function selects on all screens the tag that's currently set via selected_tag_index
local function view_only_current_tags()
	for s in screen do
		s.common_tags[selected_tag_index]:view_only()
		s:emit_signal('common_tag::selected', selected_tag_index)
	end
end

-- Tries focusing a client on a given screen. Will return true if a client
-- could be focused, false otherwise.
local function focus_client_on_screen(scr)
	if scr.clients[1] then
		client.focus = scr.clients[1]
		return true
	else
		return false
	end
end

-- Tries to focus an client after a tag switch. Accepts a preferred screen on which first trying
-- to focus a client, before falling back to other screens.
local function focus_client(preferred_screen)
	if preferred_screen and focus_client_on_screen(preferred_screen) then
		return
	end
	if focus_client_on_screen(lunaconf.screens.primary()) then
		return
	end
	for s in screen do
		if focus_client_on_screen(s) then
			return
		end
	end
end

-- #################################
-- init logic that setups the module
-- #################################

awful.screen.connect_for_each_screen(function (s)
	s.common_tags = {}
	-- Create a new common tag for the current count of tags
	for i=1,tag_count do
		local tag = create_tag(s)
		tag.selected = true
		-- Attach to the 
		table.insert(s.common_tags, tag)
	end
end)

-- Move all clients of a tag to the primary screen, if a tag gets removed because of the removal
-- of the screen that tag was on.
tag.connect_signal('removal-pending', function (t)
	for _, c in pairs(t:clients()) do
		c:move_to_tag(module.get_current_tag(lunaconf.screens.primary()))
	end
end)

-- Don't add newly created clients to all currently visible tags, only to the
-- primary tag of the screen they are created on.
client.connect_signal('manage', function(c)
	c:tags({ module.get_current_tag(c.screen) })
end)

-- ###########
-- Public APIs
-- ###########

function module.get_current_tag(scr)
	return scr.common_tags[selected_tag_index]
end

-- This will create a new tag (on each screen) and attach it to the end
-- of the tag list for each screen.
function module.create_tag()
	tag_count = tag_count + 1
	selected_tag_index = tag_count
	for s in screen do
		local tag = create_tag(s)
		table.insert(s.common_tags, tag)
		tag:view_only()
		s:emit_signal('common_tag::changed', tag_count)
		s:emit_signal('common_tag::selected', selected_tag_index)
	end
end

-- This will create a new tag (see create_tag function) and move the currently focused
-- client to this tag.
function module.create_tag_with_current_client()
	local focused_client = client.focus
	module.create_tag()
	if focused_client then
		focused_client:tags({ module.get_current_tag(focused_client.screen) })
	end
end

-- Closes the current tag, i.e. moves all its clients to the next focused tag of that screen
-- and then deletes the tag
function module.close_current_tag()
	-- Forbid closing of the last tag
	if tag_count <= 1 then
		return
	end

	tag_count = tag_count - 1
	local prev_selected_index = selected_tag_index
	-- Mark the selected_tag_index correctly for the now focused tag
	selected_tag_index = math.max(1, selected_tag_index - 1)
	for s in screen do
		local fallback_tag = s.common_tags[prev_selected_index == 1 and 2 or prev_selected_index - 1]
		local tag = table.remove(s.common_tags, prev_selected_index)
		-- Delete tag and move all clients from it to the fallback client
		tag:delete(fallback_tag, true)
		s:emit_signal('common_tag::changed', tag_count)
		s:emit_signal('common_tag::selected', selected_tag_index)
		-- View only the fallback client
		fallback_tag:view_only()
	end
end

function module.find_tag_index(tag)
	if not tag or not tag.common_tag then
		return nil
	end
	for i, t in ipairs(tag.screen.common_tags) do
		if t == tag then
			return i
		end
	end
	return nil
end

function module.select_tag(index)
	local focused_screen = client.focus and client.focus.screen
	selected_tag_index = gears.math.cycle(tag_count, index)
	view_only_current_tags()
	focus_client(focused_screen)
end

function module.prev_tag()
	module.select_tag(selected_tag_index - 1)
end

function module.next_tag()
	module.select_tag(selected_tag_index + 1)
end

-- Moves the currently focused client to the next tag and switch to it.
function module.move_to_next_tag()
	local focused = client.focus
	module.next_tag()
	if focused then
		focused:tags({ module.get_current_tag(focused.screen) })
		client.focus = focused
	end
end

-- Moves the currently focused client to the previous tag and switches to it.
function module.move_to_prev_tag()
	local focused = client.focus
	module.prev_tag()
	if focused then
		focused:tags({ module.get_current_tag(focused.screen) })
		client.focus = focused
	end
end

function module.create_widget(for_screen)
	return widget(for_screen, module, { tag_count = tag_count, selected_tag = selected_tag_index })
end

return module
