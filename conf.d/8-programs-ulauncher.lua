client.connect_signal('manage', function(c)
	if c.class == 'Ulauncher' then
		c.disable_shadow = true
	end
end)
