import { config } from "../lib/config";
import { SUPER } from "../lib/constants";
import { addKey } from "../lib/keys";
import { MouseButtonIndex } from "../lib/mouse";
import { isCommandAvailable, spawn } from "../lib/process";

const keyLayout = config("keyboard.key_layout", "regular");

// Open file exporer in home directory
addKey([SUPER], "e", () => spawn("xdg-open $HOME"));
addKey([SUPER, "Control"], "Delete", () => awesome.restart());

isCommandAvailable("flameshot").then(() => {
  const takeScreenshot = () => spawn("flameshot gui -p /tmp");
  const takeWindowScreenshot = () => {
    mousegrabber.run((m) => {
      if (m.buttons[MouseButtonIndex.PRIMARY]) {
        const c = mouse.current_client;
        if (c) {
          c.raise();
          spawn(`flameshot gui -p /tmp --region ${c.width}x${c.height}+${c.x}+${c.y}`);
        }
        return false;
      }
      return !m.buttons[MouseButtonIndex.SECONDARY];
    }, "crosshair");
  };

  const takeFullScreenshot = () => spawn("flameshot full -p /tmp");

  if (keyLayout === "assistant") {
    addKey([], "Menu", takeScreenshot);
    // Alt + Assistant key
    addKey(["Shift", "Mod4", "Mod1"], "XF86TouchpadOff", takeWindowScreenshot);
  } else if (keyLayout === "print") {
    addKey(["Control"], "Print", takeScreenshot);
    addKey(["Mod1"], "Print", takeWindowScreenshot);
  } else {
    addKey([], "Print", takeScreenshot);
    addKey(["Mod1"], "Print", takeWindowScreenshot);
    addKey([SUPER], "Print", takeFullScreenshot);
  }
});
