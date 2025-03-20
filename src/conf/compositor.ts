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

const FLOATING_XPROP = "_AWESOMEWM_FLOATING";

awesome.register_xproperty(FLOATING_XPROP, "boolean");

if (!config("disable_compositor", false)) {
  client.connect_signal("manage", (c) => {
    c.set_xproperty(FLOATING_XPROP, c.floating);
  });

  client.connect_signal("property::floating", (c) => {
    c.set_xproperty(FLOATING_XPROP, c.floating);
  });

  isCommandAvailable("picom").then(() => {
    screen.connect_signal("list", restartPicom);
    screen.connect_signal("property::geometry", restartPicom);

    if (!awesome.composite_manager_running) {
      runPicom();
    }
  });
}