// Disable all client maximization, since we want to handle this fully via layouts
client.connect_signal("property::maximized", (c) => c.maximized = false);
client.connect_signal("property::maximized_horizontal", (c) => c.maximized_horizontal = false);
client.connect_signal("property::maximized_vertical", (c) => c.maximized_vertical = false);