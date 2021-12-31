import { SUPER, SCRIPT_PATH } from "../lib/constants";
import { addKey } from "../lib/keys";
import { isCommandAvailable, spawn } from "../lib/process";

// Open file exporer in home directory
addKey([SUPER], 'e', () => spawn('xdg-open $HOME'));
addKey([SUPER, 'Control'], 'Delete', () => awesome.restart());

isCommandAvailable('import').then(() => {
  addKey(['Mod1'], 'Print', () => spawn(`${SCRIPT_PATH}/screenshot win`));
  addKey([SUPER], 'Print', () => spawn(`${SCRIPT_PATH}/screenshot scr`))
});