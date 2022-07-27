import { dbus } from '../lib/dbus';
import { execute } from '../lib/process';

dbus.system().onSignal<[string, { Timezone?: string }]>(null, 'org.freedesktop.DBus.Properties', 'PropertiesChanged', '/org/freedesktop/timedate1', (event) => {
  if (event.params[1].Timezone) {
    // The system's timezone changed, refresh the clock in the menu
    awesome.emit_signal("ts::timezone_changed", event.params[1].Timezone);
  }
});

async function getTimezone(): Promise<string> {
  const { stdout } = await execute("timedatectl show -p Timezone --value");
  return (stdout ?? "").trim();
}

// On Start get the current timezone and emit it to update the clock
// with a globe icon if not in the home timezone
getTimezone().then(tz => awesome.emit_signal("ts::timezone_changed", tz));