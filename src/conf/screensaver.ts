import * as gears from "gears";
import * as lunaconf from "lunaconf";
import { config } from "../lib/config";
import { SCRIPT_PATH, SUPER } from "../lib/constants";
import { dbus } from "../lib/dbus";
import { addKey } from "../lib/keys";
import { log, LogLevel } from "../lib/log";
import { spawn, spawnOnce } from "../lib/process";

const screensaverTimeout = config("screensaver.timeout", 10);
const suspendDelay = config("screensaver.suspend_delay", 10);

const LOCK_COMMAND = `${SCRIPT_PATH}/lockscreen.sh`;

addKey([SUPER], "l", () => spawn(LOCK_COMMAND));

// Start xautolock which will lock the screen after the configured `screensaver.timeout`
// It locks the screen the same way than using the shortcut to lock it immediately.
spawnOnce(`xautolock -time ${screensaverTimeout} -locker ${LOCK_COMMAND}`);

// The following code handles going to sleep after locking the machine with some delay.
let suspendTimer: gears.TimerInstance | undefined;

dbus.system().onSignal(null, "org.freedesktop.login1.Session", "Lock", null, () => {
  // Whenever the screen (i.e. the session) gets locked start a timer with screensaver.suspend_delay
  // after which the screen will be put to suspend-then-hibernate
  // For this to work make sure to symlink configs/global/polkit.10-suspend.rules correctly!
  suspendTimer = gears.timer.start_new(suspendDelay * 60, () => {
    spawn("systemctl suspend-then-hibernate");
    suspendTimer = undefined;
  });
});

dbus.system().onSignal(null, "org.freedesktop.login1.Session", "Unlock", null, () => {
  // Whenever the session gets unlocked again make sure to cancel any potential running suspend timer
  suspendTimer?.stop();
});
