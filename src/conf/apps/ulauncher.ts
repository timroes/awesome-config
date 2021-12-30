client.connect_signal('manage', (c) => {
  if (c.class === 'Ulauncher') {
    c.disable_shadow = true;
  }
})