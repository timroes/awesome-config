local lfs = require('lfs')

-- Split strings
function split(str, sep)
	local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

-- Return the default tag for a specific screen index.
-- The default tag is the first tag object on that screen.
function default_tag_for_screen(screenindex)
	return awful.tag.gettags(screenindex)[1]
end

-- Return the default tag for another tag.
-- The default tag is the first tag on the screen of the given tag.
function default_tag_for_tag(tag)
	return default_tag_for_screen(awful.tag.getscreen(tag))
end

-- Limit clients (see below)
local tag_limits = {}

client.connect_signal("tagged", function(c, t)
	local move_client = function()
		if #c:tags() <= 1 then
			-- We have only one or less tags on the client
			-- so we do need to move it
			local alternative_tag = default_tag_for_tag(t)
			awful.client.movetotag(alternative_tag, c)
			awful.tag.viewmore({ alternative_tag }, awful.tag.getscreen(alternative_tag))
			client.focus = c
			c:raise()
		end
	end

	-- Allow floating, ontop clients everywhere
	if c.floating and c.skip_taskbar then
		return
	end

	-- Filter the client
	local filter = tag_limits[t]
	if not filter then return end -- No filter defined for that tag
	for k,v in pairs(filter) do
		-- If client doesn't match specific rule move it
		if c[k] ~= v then
			move_client()
			return
		end
	end
end)
