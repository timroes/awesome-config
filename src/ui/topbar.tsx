import * as wibox from 'wibox';
import * as awful from 'awful';
import * as lunaconf from 'lunaconf';
import { config } from '../lib/config';
import { execute, spawn } from '../lib/process';
import { dbus } from '../lib/dbus';
import { dpi } from '../lib/dpi';
import { createClientlist } from './clientlist';
import { theme } from '../theme/default';
import { log } from '../lib/log';
import { trigger } from './controlcenter/controlcenter';

const BAR_HEIGHT = 32;

const bars = new WeakMap<Screen, awful.Wibar<AlignLayout>>();

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

const createPrimaryScreenWidgets = () => {
  const calendarAction = config('calendar.action');
  const clockButtons = calendarAction ? awful.button([], 1, () => spawn(`dex '${calendarAction}'`)) : null;
  return wibox.widget(
    <wibox.layout.fixed.horizontal spacing={dpi(5, screen.primary)}>
      <wibox.container.margin margins={dpi(7, screen.primary)}>
        <wibox.widget.systray />
      </wibox.container.margin>
      <wibox.widget.textclock id="clock" format="%H:%M" buttons={clockButtons} />
      {trigger}
    </wibox.layout.fixed.horizontal>
  );
};

const updatePrimaryBar = () => {
  for (const s of screen) {
    if (s === screen.primary) {
      (bars.get(s)?.widget as any).set_right(createPrimaryScreenWidgets());
    } else {
      (bars.get(s)?.widget as any).set_right(null);
    }
  }
};

const createScreenBar = (s: Screen) => {
  // Remove previous bar from screen before recreating new bar
  const previousBar = bars.get(s);
  previousBar?.remove();

  const barWidget = (
    <wibox.layout.align.horizontal>
      <wibox.container.margin right={dpi(4, s)}>
        {lunaconf.tags.create_widget(s)}
      </wibox.container.margin>
      {createClientlist(s)}
      {s === screen.primary ? createPrimaryScreenWidgets() : null}
    </wibox.layout.align.horizontal>
  );

  const bar = awful.wibar({
    position: 'top',
    screen: s,
    height: dpi(BAR_HEIGHT, s),
    bg: theme.bg.base,
    widget: wibox.widget(barWidget) as AlignLayout,
  });

  bars.set(s, bar);
  updateTimezone();
};

awful.screen.connect_for_each_screen(createScreenBar);

dbus.system().onSignal<[string, { Timezone?: string }]>(null, 'org.freedesktop.DBus.Properties', 'PropertiesChanged', '/org/freedesktop/timedate1', async (event) => {
  if (event.params[1].Timezone) {
    // The system's timezone changed, refresh the clock in the menu
    updateTimezone();
  }
});

// Whenever the primary change move the widgets to the new primary bar
screen.connect_signal('primary_changed', updatePrimaryBar);
// Whenever the dpis of a screen change recreate that screen's bar
screen.connect_signal('property::dpi', createScreenBar)
