client.connect_signal("manage", (c) => {
  // Don't show zoom popups (or popout window) in taskbar
  if (c.class === "zoom" && c.name === "zoom") {
    c.ontop = true;
    c.skip_taskbar = true;
  }
});
