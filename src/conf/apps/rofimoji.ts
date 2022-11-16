import { addKey } from "../../lib/keys";
import { log } from "../../lib/log";
import { isCommandAvailable, spawn } from "../../lib/process";

isCommandAvailable('rofimoji').then(() => {
  addKey(['Mod1'], 'space', () => spawn('rofimoji'));
});