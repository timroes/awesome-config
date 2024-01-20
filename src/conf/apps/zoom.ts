client.connect_signal("manage", (c) => {
  // Don't show zoom popups in taskbar
  if (c.class === "zoom" && c.motif_wm_hints?.decorations?.title === false) {
    c.skip_taskbar = true;
  }
});