import * as awful from "awful";

import { config } from "../lib/config";
import { addKey } from "../lib/keys";
import { XProperties } from "../lib/constants";

const keyLayout = config("keyboard.key_layout", "regular");

const terminalTag = awful.tag.add("Terminal", {
  screen: screen.primary,
});

function configureTerminalClient(c: Client) {
  c.skip_taskbar = true;
  c.ontop = true;
  c.floating = true;
  c.x = terminalTag.screen.workarea.x;
  c.y = terminalTag.screen.workarea.y;
  c.width = terminalTag.screen.workarea.width;
  c.height = terminalTag.screen.workarea.height;
  c.unresizeable = true;
  c.unmoveable = true;
  c.set_xproperty(XProperties.NO_DECORATION, true);
}

terminalTag.connect_signal("request::screen", () => {
  terminalTag.screen = screen.primary;
});

terminalTag.connect_signal("tagged", (tag: Tag, c: Client) => {
  // Don't allow anything beside the kitty terminal on this tag
  if (c.class !== "kitty") {
    c.move_to_tag(c.screen.tags.find((t) => t.common_tag)!);
  }
});

client.connect_signal("manage", (c: Client) => {
  if (c.first_tag === terminalTag) {
    configureTerminalClient(c);
  }
});

// When the terminal window closes unselect (hide) the tag
terminalTag.connect_signal("untagged", () => {
  if (terminalTag.clients().length === 0) {
    terminalTag.selected = false;
  }
});

// If another client gains focus on the same screen that the terminal tag is, while the terminal tag is selected, unselect it
client.connect_signal("focus", () => {
  if (terminalTag.selected && client.focus?.screen === terminalTag.screen && client.focus.first_tag !== terminalTag) {
    terminalTag.selected = false;
  }
});

function toggleTerminal() {
  if (!terminalTag.selected) {
    terminalTag.selected = true;
    const clients = terminalTag.clients();
    if (clients.length > 0) {
      client.focus = clients[0];
    } else {
      awful.spawn.spawn("kitty -o background_opacity=0.7", {
        tag: terminalTag,
        callback: (c) => {
          configureTerminalClient(c);
        },
      });
    }
  } else {
    if (client.focus && client.focus.first_tag === terminalTag) {
      awful.client.focus.history.previous();
    }
    terminalTag.selected = false;
  }
}

if (keyLayout === "assistant") {
  // Keycode for "Assistant" key beside space bar in Awesome
  addKey(["Shift", "Mod4"], "XF86TouchpadOff", toggleTerminal);
  addKey([], "XF86Assistant", toggleTerminal);
} else if (keyLayout === "print") {
  addKey([], "Print", toggleTerminal);
} else {
  addKey([], "Menu", toggleTerminal);
}
