import * as gears from 'gears';
import * as lunaconf from 'lunaconf';
import { config } from '../lib/config';
import { SCRIPT_PATH, SUPER } from '../lib/constants';
import { dbus } from '../lib/dbus';
import { addKey } from '../lib/keys';
import { log, LogLevel } from '../lib/log';
import { spawn, spawnOnce } from '../lib/process';

const screensaverTimeout = config('screensaver.timeout', 10);
const suspendDelay = config('screensaver.suspend_delay', 10);

const LOCK_COMMAND = `${SCRIPT_PATH}/lockscreen.sh`;

addKey([SUPER], 'l', () => spawn(LOCK_COMMAND));

// Start xautolock which will lock the screen after the configured `screensaver.timeout`
// It locks the screen the same way than using the shortcut to lock it immediately.
spawnOnce(`xautolock -time ${screensaverTimeout} -locker ${LOCK_COMMAND}`);

// Start the script that will monitor the DBus for screensaver inhibit/uninhibit messages and turn them into signals
spawnOnce(`${SCRIPT_PATH}/dbus-screensaver-monitor.sh`, '-x dbus-screensaver-monitor.sh');

const inhibitingApps = new Set<string>();
// Listen on the signals emitted by the dbus-screensaver-monitor.sh script and keep track of which senders inhibits
// the screensaver. Prevent auto screen sleep as long as there is at least one sender still inhibiting
dbus.session().onSignal<[sender: string]>(null, 'de.timroes.awesome.ScreenSaver', null, null, (signal) => {
  const [sender] = signal.params;
  log(`Screensaver ${signal.signalName} by ${sender}`, LogLevel.DEBUG);
  if (signal.signalName === 'Inhibit') {
    inhibitingApps.add(sender);
  } else {
    inhibitingApps.delete(sender);
  }
  lunaconf.sidebar.get().set_screensleep(inhibitingApps.size > 0);
});

// The following code handles going to sleep after locking the machine with some delay.
let suspendTimer: gears.TimerInstance | undefined;

dbus.system().onSignal(null, 'org.freedesktop.login1.Session', 'Lock', null, () => {
  // Whenever the screen (i.e. the session) gets locked start a timer with screensaver.suspend_delay
  // after which the screen will be put to suspend-then-hibernate
  // For this to work make sure to symlink configs/global/polkit.10-suspend.rules correctly!
  suspendTimer = gears.timer.start_new(suspendDelay * 60, () => {
    spawn('systemctl suspend-then-hibernate');
    suspendTimer = undefined;
  });
});

dbus.system().onSignal(null, 'org.freedesktop.login1.Session', 'Unlock', null, () => {
  // Whenever the session gets unlocked again make sure to cancel any potential running suspend timer
  suspendTimer?.stop();
});
