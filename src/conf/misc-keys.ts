import { notify } from "lunaconf";
import { SUPER, SCRIPT_PATH } from "../lib/constants";
import { addKey } from "../lib/keys";
import { isCommandAvailable, spawn } from "../lib/process";

// Open file exporer in home directory
addKey([SUPER], 'e', () => spawn('xdg-open $HOME'));
addKey([SUPER, 'Control'], 'Delete', () => awesome.restart());

isCommandAvailable('flameshot').then(() => {
  addKey([], 'Print', () => spawn('flameshot gui -p /tmp'));
  addKey([], 'XF86Launch2', () => spawn(`flameshot gui -p /tmp`));
  addKey([SUPER], 'Print', () => spawn(`flameshot full -p /tmp`));

  addKey(['Mod1'], 'Print', () => {
    mousegrabber.run((m) => {
      if (m.buttons[0]) {
        const c = mouse.current_client;
        if (c) {
          c.raise();
          spawn(`flameshot gui -p /tmp --region ${c.width}x${c.height}+${c.x}+${c.y}`);
        }
        return false;
      }
      return !m.buttons[2];
    }, "crosshair");
    
  });
});
