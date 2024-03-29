import * as wibox from "wibox";
import * as gears from "gears";
import * as awful from "awful";

import { ControlWidget } from "./control-widget";
import { theme } from "../../theme/default";
import { ICON_PATH, SCRIPT_PATH } from "../../lib/constants";
import { dpi } from "../../lib/dpi";
import { isDndActive, onDndChange, toggleDnd } from "../../lib/notifications";
import { spawn } from "../../lib/process";

const dndIcon = `${ICON_PATH}/bell.png`;
const dndActiveIcon = `${ICON_PATH}/bell-dnd.png`;
const sleepIcon = `${ICON_PATH}/sleep.png`;
const sleepDisabledIcon = `${ICON_PATH}/sleep-disabled.png`;

export class SettingsWidget extends ControlWidget {
  private sleepDisabled: boolean = false;

  private toggleSleep(): void {
    this.sleepDisabled = !this.sleepDisabled;
  	spawn(`${SCRIPT_PATH}/screensaver.sh ${this.sleepDisabled ? 'pause' : 'resume'}`);
    this.handler.setTriggerColor("yellow", this.sleepDisabled);

    (this.currentRender.get_children_by_id("sleep")[0] as BackgroundContainer).bg = this.sleepDisabled ? theme.controlcenter.settings.keepAwake : theme.controlcenter.settings.disabled;
    (this.currentRender.get_children_by_id("sleep-icon")[0] as Imagebox).image = this.sleepDisabled 
      ? gears.color.recolor_image(sleepDisabledIcon, theme.controlcenter.settings.icon.active)
      : gears.color.recolor_image(sleepIcon, theme.controlcenter.settings.icon.disabled);
  }

  private toggleDnd(): void {
    toggleDnd();
    this.onDndToggle();
  }

  private onDndToggle() {
    const dnd = isDndActive();
    this.handler.setTriggerColor("pink", dnd);
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

  override onInit(): void {
    onDndChange(() => { this.onDndToggle(); });
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
        <wibox.container.place halign="right">
          <wibox.layout.fixed.horizontal spacing={dpi(8, s)}>
            {this.renderSetting(s, "sleep", sleepIcon, () => { this.toggleSleep(); })}
            {this.renderSetting(s, "dnd", dndIcon, () => { this.toggleDnd(); })}
          </wibox.layout.fixed.horizontal>
        </wibox.container.place>
      </wibox.container.margin>
    );
  }
}