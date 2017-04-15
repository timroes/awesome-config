-- A module that offers several functionality around the handling of tags.

local tags = {}

-- Returns the default tag for a specific screen index.
-- The default tag is the first tag object on that screen.
function tags.default_tag_for_screen(screenindex)
	return awful.tag.gettags(screenindex)[1]
end

return tags
