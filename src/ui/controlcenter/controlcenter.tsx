import * as awful from "awful";
import * as gears from "gears";
import * as wibox from "wibox";

import { SUPER } from "../../lib/constants";
import { addKey } from "../../lib/keys";
import { ControlWidget, Handler, TriggerState } from "./control-widget";
import { SettingsWidget } from "./settings";
import { theme } from "../../theme/default";
import { dpi } from "../../lib/dpi";
import { CalendarWidget } from "./calendar";
import { BluetoothControl } from "./bluetooth";
import { MouseButton } from "../../lib/mouse";
import { createWidget } from "../../lib/widget";
import { PlayerControl } from "./playercontrol";
import { log } from "../../lib/log";

let previouslyFocusedClient: Client | null = null;

let triggerState: TriggerState = {
  battery: "unknown",
  dnd: false,
  keepAwake: false,
};

const handler: Handler = {
  setTriggerState(state) {
    triggerState = {
      ...triggerState,
      ...state,
    };
    trigger.emit_signal("widget::redraw_needed");
  },
  requestRelayout() {
    // TODO: not sure how to solve it
    gears.timer.start_new(0.2, () => {
      log(`request relayou ${tostring((popup.widget as any).widget)}`);
      (popup.widget as any).widget.emit_signal("widget::layout_changed");
    })
  }
};

const widgets: ControlWidget[] = [
  new SettingsWidget(handler),
  new CalendarWidget(handler),
  new PlayerControl(handler),
  new BluetoothControl(handler),
];

function renderWidgets(s: Screen) {
  return (
    <wibox.container.margin forced_width={dpi(400, s)} left={dpi(10, s)} right={dpi(10, s)} top={dpi(15, s)} bottom={dpi(15, s)}>
      <wibox.layout.fixed.vertical spacing={dpi(8, s)}>
        {...widgets.map((widget) => widget.renderAndStore(s))}
      </wibox.layout.fixed.vertical>
    </wibox.container.margin>
  );
}

const placementFn = (popup: awful.Drawable) => {
  awful.placement.align(popup, { honor_workarea: true, position: "top_right", margins: { top: dpi(10, screen.primary), right: dpi(10, screen.primary) }})
};

const popup = awful.popup({
  type: "dialog",
  screen: screen.primary,
  visible: false,
  bg: theme.bg.base,
  ontop: true,
  placement: placementFn,
  widget: wibox.widget(renderWidgets(screen.primary)),
});

const keygrabber: awful.KeygrabberFn = (modifiers, key, event) => {
  // Ignore Num Pad modifier
  modifiers = modifiers.filter(mod => mod !== "Mod2");
  if (event === "press" && (key === "Escape" || modifiers.length === 1 && modifiers[0] === SUPER && key === "\\")) {
    hide();
  } else if (event === "press") {
    widgets.forEach((widget) => widget.onKeyPress(modifiers, key));
  }
};

function show() {
  if (client.focus) {
    previouslyFocusedClient = client.focus;
    client.focus = null;
  }
  placementFn(popup);
  widgets.forEach((widget) => widget.onShow());
  awful.keygrabber.run(keygrabber);
  popup.visible = true;
}

function hide(): void {
  popup.visible = false;
  awful.keygrabber.stop(keygrabber);
  widgets.forEach((widget) => widget.onHide());

  // Focus previously focused client again
  if (previouslyFocusedClient?.valid) {
    client.focus = previouslyFocusedClient;
  }
  previouslyFocusedClient = null;
}

function toggle() {
  popup.visible ? hide() : show();
}

const batteryTriggerColors: Record<TriggerState["battery"], string> = {
  unknown: theme.controlcenter.trigger.inactive,
  green: theme.controlcenter.trigger.battery.green,
  orange: theme.controlcenter.trigger.battery.orange,
  red: theme.controlcenter.trigger.battery.red, 
};

const createTrigger = (s: Screen) => {
  return wibox.widget(
    <wibox.layout.fixed.horizontal buttons={awful.button([], MouseButton.PRIMARY, () => toggle())}>
      {createWidget({
        fit(widget, context, width, height): LuaMultiReturn<[number, number]> {
          return $multi(Math.min(height, width), Math.min(height, width));
        },
        draw(widget, context, cr, width, height) {
          const regularColor = theme.controlcenter.trigger.inactive;

          // Top left square which indicates the dnd status
          cr.set_source_rgb(...gears.color.parse_color(triggerState.dnd ? theme.controlcenter.trigger.dnd : regularColor));
          gears.shape.transform(gears.shape.rounded_rect)
            .translate(0.15 * width, 0.15 * height)(cr, 0.3 * width, 0.3 * height, dpi(2, s));
          cr.fill();

          // Top right square
          cr.set_source_rgb(...gears.color.parse_color(batteryTriggerColors[triggerState.battery]));
          gears.shape.transform(gears.shape.rounded_rect)
            .translate(0.55 * width, 0.15 * height)(cr, 0.3 * width, 0.3 * height, dpi(2, s));
          cr.fill();

          // Bottom left square
          cr.set_source_rgb(...gears.color.parse_color(regularColor));
          gears.shape.transform(gears.shape.rounded_rect)
            .translate(0.15 * width, 0.55 * height)(cr, 0.3 * width, 0.3 * height, dpi(2, s));
          cr.fill();

          // Bottom right square
          cr.set_source_rgb(...gears.color.parse_color(triggerState.keepAwake ? theme.controlcenter.trigger.keepAwake : regularColor));
          gears.shape.transform(gears.shape.rounded_rect)
            .translate(0.55 * width, 0.55 * height)(cr, 0.3 * width, 0.3 * height, dpi(2, s));
          cr.fill();
        },
      })}
    </wibox.layout.fixed.horizontal>
  );
}

export const trigger = createTrigger(screen.primary);

// Call onInit on all widgets (after we have rendered each widget once)
widgets.forEach((widget) => widget.onInit());

addKey([SUPER], "\\", () => {
  toggle();
});

client.connect_signal("focus", () => {
  if (popup.visible) {
    hide();
  }
});

// TODO: On primary change/dpi change