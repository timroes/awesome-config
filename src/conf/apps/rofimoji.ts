import { CONFIGS_PATH } from "../../lib/constants";
import { addKey } from "../../lib/keys";
import { isCommandAvailable, spawn } from "../../lib/process";

isCommandAvailable("rofimoji").then(() => {
  addKey(["Mod1"], "space", () => spawn(`rofimoji -s neutral --selector-args="-theme ${CONFIGS_PATH}/rofimoji.theme.rasi"`));
});
