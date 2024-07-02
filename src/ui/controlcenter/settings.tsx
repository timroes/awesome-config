import * as wibox from "wibox";
import * as gears from "gears";
import * as awful from "awful";
import * as lunaconf from "lunaconf";

import { ControlWidget } from "./control-widget";
import { theme } from "../../theme/default";
import { ICON_PATH, SCRIPT_PATH } from "../../lib/constants";
import { dpi } from "../../lib/dpi";
import { isDndActive, onDndChange, toggleDnd } from "../../lib/notifications";
import { spawn, spawnOnce } from "../../lib/process";
import { dbus } from "../../lib/dbus";
import { LogLevel, log } from "../../lib/log";

const enum BatteryState {
  Unknown = 0,
  Charging = 1,
  Discharging = 2,
  Empty = 3,
  FullyCharged = 4,
  PendingCharge = 5,
  PendingDischarge = 6,
};

interface BatteryStatus {
  Percentage: number;
  State: BatteryState;
  TimeToFull?: number;
  TimeToEmpty?: number;
  EnergyRate?: number;
}

const BATTERY_WARNING_TIME = 15 * 60; // 15 min

const dndIcon = `${ICON_PATH}/bell.png`;
const dndActiveIcon = `${ICON_PATH}/bell-dnd.png`;
const sleepIcon = `${ICON_PATH}/sleep.png`;
const sleepDisabledIcon = `${ICON_PATH}/sleep-disabled.png`;

let batteryWarningShown = false;

const getBatteryIcon = (status: BatteryStatus) => {
  if (status.State === BatteryState.PendingCharge || status.State === BatteryState.Charging || status.State === BatteryState.FullyCharged) {
    return "battery-charging.png";
  }
  
  if (!status.Percentage) {
    return "battery.png";
  }

  if (status.Percentage >= 85) {
    return "battery-4.png";
  }

  if (status.Percentage >= 55) {
    return "battery-3.png";
  }
  
  if (status.Percentage >= 20) {
    return "battery-2.png"
  }

  return "battery-1.png";
};

const formatTime = (time: number) => {
  const hours = Math.floor(time / 3600);
  const minutes = Math.floor((time - hours * 3600) / 60);
  return hours > 0 ? `${hours}h ${minutes}m` : `${minutes} min`;
};

export class SettingsWidget extends ControlWidget {
  private sleepDisabled: boolean = false;
  private inhibitingApps = new Set<string>();

  private setSleep(sleepDisabled: boolean): void {
    this.sleepDisabled = sleepDisabled;
  	spawn(`${SCRIPT_PATH}/screensaver.sh ${this.sleepDisabled ? 'pause' : 'resume'}`);
    this.handler.setTriggerState({ keepAwake: this.sleepDisabled });

    (this.currentRender.get_children_by_id("sleep")[0] as BackgroundContainer).bg = this.sleepDisabled ? theme.controlcenter.settings.keepAwake : theme.controlcenter.settings.disabled;
    (this.currentRender.get_children_by_id("sleep-icon")[0] as Imagebox).image = this.sleepDisabled 
      ? gears.color.recolor_image(sleepDisabledIcon, theme.controlcenter.settings.icon.active)
      : gears.color.recolor_image(sleepIcon, theme.controlcenter.settings.icon.disabled);
  }

  private toggleSleep(): void {
    this.setSleep(!this.sleepDisabled);
  }

  private toggleDnd(): void {
    toggleDnd();
    this.onDndToggle();
  }

  private onDndToggle() {
    const dnd = isDndActive();
    this.handler.setTriggerState({ dnd });
    (this.currentRender.get_children_by_id("dnd")[0] as BackgroundContainer).bg = dnd ? theme.controlcenter.settings.dnd : theme.controlcenter.settings.disabled;
    (this.currentRender.get_children_by_id("dnd-icon")[0] as Imagebox).image = dnd 
      ? gears.color.recolor_image(dndActiveIcon, theme.controlcenter.settings.icon.active)
      : gears.color.recolor_image(dndIcon, theme.controlcenter.settings.icon.disabled);
  }

  private renderSetting(s: Screen, id: string, icon: string, onClick: () => void) {
    const image = gears.color.recolor_image(icon, theme.controlcenter.settings.icon.disabled);
    return (
      <wibox.container.background id={id} shape={gears.shape.circle} bg={theme.controlcenter.settings.disabled} buttons={awful.button([], 1, () => { onClick() })}>
        <wibox.container.margin margins={dpi(5, s)}>
          <wibox.widget.imagebox id={`${id}-icon`} image={image} forced_width={dpi(24, s)} forced_height={dpi(24, s)} />
        </wibox.container.margin>
      </wibox.container.background>
    )
  }

  private renderBattery(s: Screen) {
    return (
      <wibox.layout.fixed.horizontal spacing={dpi(2, s)}>
        <wibox.container.place valign="center">
          <wibox.widget.imagebox id="batteryIcon" forced_width={dpi(24, s)} forced_height={dpi(24, s)} />
        </wibox.container.place>
        <wibox.widget.textbox id="battery" markup="" />
      </wibox.layout.fixed.horizontal>
    );
  }

  private updateBatteryWidget() {
    dbus.system().call("org.freedesktop.UPower", "/org/freedesktop/UPower/devices/DisplayDevice", "org.freedesktop.DBus.Properties", "GetAll", [["s", "org.freedesktop.UPower.Device"]]).then((response) => {
      const status: BatteryStatus = response.get_child_value(0).value;
      const textbox = this.currentRender.get_children_by_id("battery")[0] as TextBox;
      textbox.markup = `${Math.round(status.Percentage)}%`;
      (this.currentRender.get_children_by_id("batteryIcon")[0] as Imagebox).image = gears.color.recolor_image(`${ICON_PATH}/${getBatteryIcon(status)}`, theme.controlcenter.settings.battery.icon);
      if (status.State === BatteryState.Charging && status.TimeToFull) {
        textbox.markup = `${textbox.markup} / ${formatTime(status.TimeToFull)}`;
      }

      if (status.State === BatteryState.PendingCharge || status.State === BatteryState.Charging || status.State === BatteryState.FullyCharged) {
        batteryWarningShown = false;
      }
      
      // Update trigger state according to the battery state
      if (status.TimeToEmpty && status.TimeToEmpty > 0) {
        textbox.markup = `${textbox.markup} / ${formatTime(status.TimeToEmpty)}`;
        if (status.TimeToEmpty < BATTERY_WARNING_TIME && !batteryWarningShown) {
          lunaconf.notify.show_or_update("low_battery_warning", {
            title: "Battery warning",
            text: `Only ${formatTime(status.TimeToEmpty)} of battery time remaining.`,
            icon: "battery-caution",
            timeout: 10,
            ignore_dnd: true,
          });
          batteryWarningShown = true;
        }
        // We have a remaining time so use it over percentage for coloring
        if (status.TimeToEmpty < 30 * 60) {
          this.handler.setTriggerState({ battery: "red" });
        } else if (status.TimeToEmpty < 120 * 60) {
          this.handler.setTriggerState({ battery: "orange" });
        } else {
          this.handler.setTriggerState({ battery: "green" });
        }
      } else if (status.Percentage && status.Percentage > 0) {
        // We don't have a remaining time (yet) so use percentage instead
        if (status.Percentage < 10) {
          this.handler.setTriggerState({ battery: "red" });
        } else if (status.Percentage < 30) {
          this.handler.setTriggerState({ battery: "orange" });
        } else {
          this.handler.setTriggerState({ battery: "green" });
        }
      } else {
        this.handler.setTriggerState({ battery: "unknown" });
      }
    });
  }

  override onInit(): void {
    onDndChange(() => { this.onDndToggle(); });
    // Start the script that will monitor the DBus for screensaver inhibit/uninhibit messages and turn them into signals
    spawnOnce(`${SCRIPT_PATH}/dbus-screensaver-monitor.sh`, '-x dbus-screensaver-monitor.sh');
    // Listen on the signals emitted by the dbus-screensaver-monitor.sh script and keep track of which senders inhibits
    // the screensaver. Prevent auto screen sleep as long as there is at least one sender still inhibiting
    dbus.session().onSignal<[sender: string]>(null, 'de.timroes.awesome.ScreenSaver', null, null, (signal) => {
      const [sender] = signal.params;
      log(`Screensaver ${signal.signalName} by ${sender}`, LogLevel.DEBUG);
      if (signal.signalName === 'Inhibit') {
        this.inhibitingApps.add(sender);
      } else {
        this.inhibitingApps.delete(sender);
      }
      this.setSleep(this.inhibitingApps.size > 0);
    });
    // Listen to changes with the battery state and update widget accordingly
    dbus.system().onSignal(null, "org.freedesktop.DBus.Properties", "PropertiesChanged", "/org/freedesktop/UPower/devices/DisplayDevice", (signal) => {
      this.updateBatteryWidget();
    });
    this.updateBatteryWidget();
  }

  override onKeyPress(modifiers: Modifier[], key: string): void {
    switch (key) {
      case "d":
        this.toggleDnd();
        break;
      case "s":
        this.toggleSleep();
        break;
    }
  }

  override render(s: Screen) {
    return (
      <wibox.container.margin right={dpi(4, s)} left={dpi(4, s)}>
        <wibox.layout.align.horizontal halign="right">
          {null}
          {this.renderBattery(s)}
          <wibox.layout.fixed.horizontal spacing={dpi(8, s)}>
            {this.renderSetting(s, "sleep", sleepIcon, () => { this.toggleSleep(); })}
            {this.renderSetting(s, "dnd", dndIcon, () => { this.toggleDnd(); })}
          </wibox.layout.fixed.horizontal>
        </wibox.layout.align.horizontal>
      </wibox.container.margin>
    );
  }
}