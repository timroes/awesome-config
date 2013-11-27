local awful = require("awful")
local MAIL_SCREEN = PRIMARY

local mail_tag = awful.tag.add("Mail", { })
awful.tag.seticon("/usr/share/pixmaps/thunderbird-icon.png", mail_tag)
awful.tag.setscreen(mail_tag, MAIL_SCREEN)
-- Limit tag to thunderbird windows
limit_tag(mail_tag, { class = "Thunderbird" })
-- start thunderbird on that tag
start_on_tag(mail_tag, "thunderbird")

awful.layout.set(awful.layout.suit.max, mail_tag)

-- Store tags that has been activated when switching to mail tag
local tags_before = nil

local focus_window = function()
	local clients = mail_tag:clients()
	for i,c in pairs(clients) do
		client.focus = c
	end
end

-- Shortcut to switch to mail tag
keys = awful.util.table.join(root.keys(),
	awful.key({ MOD }, "m", function() 
		if mail_tag.selected then
			if not client.focus or client.focus.class ~= "Thunderbird" then
				-- If we press the shortcut while the tag is open, but not focues,
				-- focus the tag instead of hiding it
				focus_window()
			else
				-- switch back to previous tags if available
				if tags_before then
					awful.tag.viewmore(tags_before, MAIL_SCREEN)
				else
					-- Switch to main tag of this screen if no previous tags has been saved
					local first_tag = default_tag_for_screen(MAIL_SCREEN)
					awful.tag.viewmore({ first_tag }, MAIL_SCREEN)
				end
			end
		else
			-- save previous tags and switch to pidgin tag
			tags_before = awful.tag.selectedlist(MAIL_SCREEN)
			awful.tag.viewmore({ mail_tag }, MAIL_SCREEN)
		end
	end)
)

root.keys(keys)

awful.rules.rules = awful.util.table.join(awful.rules.rules, {
	{
		rule = { class = "Thunderbird" },
		properties = {
			tag = mail_tag
		}
	},{
		rule = { class = "Thunderbird", instance = "Calendar" },
		properties = {
			ontop = true,
			sticky = true
		}
	}
})
