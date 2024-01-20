import * as wibox from 'wibox';
import * as awful from 'awful';
import * as lunaconf from 'lunaconf';
import * as screens from "../lib/screen";
import { config } from '../lib/config';
import { execute, spawn } from '../lib/process';
import { dbus } from '../lib/dbus';
import { dpiX, dpiY } from '../lib/dpi';
import { createClientlist } from './clientlist';
import { theme } from '../theme/default';

const BAR_HEIGHT = 32;
const sidebar = lunaconf.sidebar.get();

const bars = new WeakMap<Screen, awful.Wibar<wibox.AlignLayout>>();

const createPrimaryScreenWidgets = () => {
  const calendarAction = config('calendar.action');
  const clockButtons = calendarAction ? awful.button([], 1, () => spawn(`dex '${calendarAction}'`)) : null;
  return wibox.widget(
    <wibox.layout.fixed.horizontal spacing={dpiX(5, screen.primary)}>
      <wibox.container.margin margins={dpiY(7, screen.primary)}>
        <wibox.widget.systray />
      </wibox.container.margin>
      <wibox.widget.textclock id="clock" format="%H:%M" buttons={clockButtons} />
      {sidebar.trigger}
    </wibox.layout.fixed.horizontal>
  );
};

const updatePrimaryBar = () => {
  for (const s of screens.screens_as_array()) {
    if (s === screen.primary) {
      (bars.get(s)?.widget as any).set_right(createPrimaryScreenWidgets());
    } else {
      (bars.get(s)?.widget as any).set_right(null);
    }
  }
  updateTimezone();
};

awful.screen.connect_for_each_screen((s) => {
  const barWidget = (
    <wibox.layout.align.horizontal>
      {lunaconf.tags.create_widget(s)}
      {createClientlist(s)}
    </wibox.layout.align.horizontal>
  );

  const bar = awful.wibar({
    position: 'top',
    screen: s,
    height: dpiY(BAR_HEIGHT, s),
    bg: theme.bg.base,
    widget: wibox.widget(barWidget) as wibox.AlignLayout,
  });

  bars.set(s, bar);
});

const updateTimezone = async () => {
  const clock = bars.get(screen.primary)?.widget?.third.get_children_by_id("clock")[0] as TextClock | undefined;
  if (!clock) {
    return;
  }
  const { stdout } = await execute("date +%Z");
  const tz = (stdout ?? "").trim();
  const isHomeTimezone = tz == "CET" || tz == "CEST"
  clock.format = isHomeTimezone ? "%H:%M" : `%H:%M  <span color='gray'>(${tz})</span>`;
  clock.force_update();
};

dbus.system().onSignal<[string, { Timezone?: string }]>(null, 'org.freedesktop.DBus.Properties', 'PropertiesChanged', '/org/freedesktop/timedate1', async (event) => {
  if (event.params[1].Timezone) {
    // The system's timezone changed, refresh the clock in the menu
    updateTimezone();
  }
});

// Whenever the primary change move the widgets to the new primary bar
screen.connect_signal('primary_changed', updatePrimaryBar);
// Initialize the widgets on the current primary
updatePrimaryBar();
