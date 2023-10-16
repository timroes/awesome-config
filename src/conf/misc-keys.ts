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
});

isCommandAvailable('import').then(() => {
  addKey(['Mod1'], 'Print', () => spawn(`${SCRIPT_PATH}/screenshot win`));
});