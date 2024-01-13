import { config } from "../lib/config";
import { CONFIGS_PATH } from "../lib/constants";
import { execute, isCommandAvailable, spawnOnce } from "../lib/process";

async function runPicom() {
  await spawnOnce(`picom --config ${CONFIGS_PATH}/picom.conf -b`);
}

async function restartPicom() {
  await execute("killall picom");
  await runPicom();
}

awesome.register_xproperty("_PICOM_NO_SHADOW", "boolean");
awesome.register_xproperty("_PICOM_NO_ROUNDED", "boolean");

if (!config("disable_compositor", false)) {
  client.connect_signal("manage", (c) => {
    c.set_xproperty("_PICOM_NO_SHADOW", !c.floating);
    c.set_xproperty("_PICOM_NO_ROUNDED", !c.floating);

    c.connect_signal("property::floating", (c) => {
      c.set_xproperty("_PICOM_NO_SHADOW", !c.floating);
      c.set_xproperty("_PICOM_NO_ROUNDED", !c.floating);
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