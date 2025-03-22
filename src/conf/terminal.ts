import * as awful from "awful";

import { config } from "../lib/config";
import { addKey } from "../lib/keys";

const isLaptop = config("laptop", false);

const terminalTag = awful.tag.add("Terminal", {
  screen: screen.primary,
});

terminalTag.connect_signal("request::screen", () => {
  terminalTag.screen = screen.primary;
});

// When the terminal window closes unselect (hide) the tag
terminalTag.connect_signal("untagged", () => {
  terminalTag.selected = false;
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
      awful.spawn.spawn("kitty -o background_opacity=0.7", { tag: terminalTag, skip_taskbar: true, ontop: true });
    }
  } else {
    if (client.focus && client.focus.first_tag === terminalTag) {
      awful.client.focus.history.previous();
    }
    terminalTag.selected = false;
  }
}

addKey([], isLaptop ? "Print" : "Menu", toggleTerminal);
