import { config } from "../lib/config";
import { CONFIGS_PATH, XProperties } from "../lib/constants";
import { execute, isCommandAvailable, spawnOnce } from "../lib/process";

async function runPicom() {
  await spawnOnce(`picom --config ${CONFIGS_PATH}/picom.conf -b`);
}

async function restartPicom() {
  await execute("killall picom");
  await runPicom();
}

awesome.register_xproperty(XProperties.FLOATING, "boolean");
awesome.register_xproperty(XProperties.NO_DECORATION, "boolean");

if (!config("disable_compositor", false)) {
  client.connect_signal("manage", (c) => {
    c.set_xproperty(XProperties.FLOATING, c.floating);
  });

  client.connect_signal("property::floating", (c) => {
    c.set_xproperty(XProperties.FLOATING, c.floating);
  });

  isCommandAvailable("picom").then(() => {
    screen.connect_signal("list", restartPicom);
    screen.connect_signal("property::geometry", restartPicom);

    if (!awesome.composite_manager_running) {
      runPicom();
    }
  });
}