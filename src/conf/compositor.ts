import { config } from "../lib/config";
import { CONFIGS_PATH, XProperties } from "../lib/constants";
import { dbus } from "../lib/dbus";
import { log, LogLevel } from "../lib/log";
import { execute, isCommandAvailable, spawnOnce } from "../lib/process";

async function runPicom() {
  await spawnOnce(`picom --config ${CONFIGS_PATH}/picom.conf -b`);
}

async function restartPicom() {
  await execute("killall picom");
  await runPicom();
}

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

  // Restart picom everytime we come back from sleep, since it doesn't render properly after sleep anymore.
  // This will restart picom in all cases when we switch the active login session, but that's fine since locking/unlocking is the primary way this happens for us.
  dbus
    .system()
    .onSignal<[string, { ActiveSession?: [sessionId: string, unknown] }]>(
      null,
      "org.freedesktop.DBus.Properties",
      "PropertiesChanged",
      "/org/freedesktop/login1/seat/seat0",
      (signal) => {
        if (signal.params[1].ActiveSession && signal.params[1].ActiveSession[0] === os.getenv("XDG_SESSION_ID")) {
          log("Restarting picom due to current session becoming active again.", LogLevel.DEBUG);
          restartPicom();
        }
      }
    );
}
