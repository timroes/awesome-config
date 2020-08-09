local awful = require('awful')
local gears = require('gears')
local lunaconf = require('lunaconf')

lunaconf.keys.globals(
	awful.key({ lunaconf.config.MOD }, 'n', lunaconf.tags.create_tag),
	awful.key({ lunaconf.config.MOD, 'Control' }, 'n', lunaconf.tags.create_tag_with_current_client),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'n', lunaconf.tags.create_tag_with_current_client),
	awful.key({ lunaconf.config.MOD }, 'w', lunaconf.tags.close_current_tag),
	awful.key({ lunaconf.config.MOD }, 'Home', lunaconf.tags.prev_tag),
	awful.key({ lunaconf.config.MOD, 'Control' }, 'Home', lunaconf.tags.move_to_prev_tag),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'Home', lunaconf.tags.move_to_prev_tag),
	awful.key({ lunaconf.config.MOD }, 'End', lunaconf.tags.next_tag),
	awful.key({ lunaconf.config.MOD, 'Control' }, 'End', lunaconf.tags.move_to_next_tag),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'End', lunaconf.tags.move_to_next_tag),
	awful.key({ lunaconf.config.MOD }, 'Up', lunaconf.tags.prev_tag),
	awful.key({ lunaconf.config.MOD, 'Control' }, 'Up', lunaconf.tags.move_to_prev_tag),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'Up', lunaconf.tags.move_to_prev_tag),
	awful.key({ lunaconf.config.MOD }, 'Down', lunaconf.tags.next_tag),
	awful.key({ lunaconf.config.MOD, 'Control' }, 'Down', lunaconf.tags.move_to_next_tag),
	awful.key({ lunaconf.config.MOD, 'Shift' }, 'Down', lunaconf.tags.move_to_next_tag)
)

client.connect_signal('request::activate', function(c, context)
	-- TODO: Check which logic of awful.ewmh.activate we need to take over
	-- If a client requests activation, whose tag is not selected, activate the tag (on all screens)
	if not c.first_tag.selected then
		local common_tag_index = lunaconf.tags.find_tag_index(c.first_tag)
		if common_tag_index then
			lunaconf.tags.select_tag(common_tag_index)
		else
			c.first_tag.selected = true
		end
	end
end)
