import * as awful from "awful";

import { config } from "../../lib/config";
import { CONFIGS_PATH } from "../../lib/constants";
import { execute, isCommandAvailable, spawnOnce } from "../../lib/process";
import { log } from "../../lib/log";

async function runPicom() {
  await spawnOnce(`picom --config ${CONFIGS_PATH}/picom.conf -b`);
}

async function restartPicom() {
  await execute("killall picom");
  await runPicom();
}

awesome.register_xproperty("_PICOM_NO_SHADOW", "boolean");
awful.client.object.set_disable_shadow = (client: Client, value: boolean) => {
  client.set_xproperty("_PICOM_NO_SHADOW", value);
};

if (!config("disable_compositor", false)) {
  client.connect_signal("manage", (c) => {
    c.disable_shadow = !c.floating;
    c.connect_signal("property::floating", (c) => {
      c.disable_shadow = !c.floating;
    });
  });

  isCommandAvailable("picom").then(() => {
    screen.connect_signal("list", restartPicom);
    screen.connect_signal("property::geometry", restartPicom);

    if (!awesome.composite_manager_running) {
      runPicom();
    }
  });
}