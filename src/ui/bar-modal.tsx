import * as awful from "awful";
import * as wibox from "wibox";
import * as gears from "gears";
import { theme } from "../theme/default";
import { ICON_PATH } from "../lib/constants";
import { dpi } from "../lib/dpi";
import { transparency } from "../lib/colors";

const MODAL_TIMEOUT = 1;

export class BarModal {
  private static openModal: BarModal | null = null;
  private popup?: awful.Popup;
  private timer?: gears.TimerInstance;
  private value: number = 100;

  constructor(private icon: string) {}

  setValue(value: number) {
    this.value = Math.max(Math.min(value, 100), 0);
    if (this.popup) {
      (this.popup.widget.get_children_by_id("bar")[0] as ProgressBar).value = this.value / 100;
    }
  }

  setIcon(icon: string) {
    this.icon = icon;
    if (this.popup) {
      (this.popup.widget.get_children_by_id("icon")[0] as Imagebox).image = gears.color.recolor_image(`${ICON_PATH}/${this.icon}`, theme.highlight.regular);
    }
  }

  hide() {
    if (this.popup) {
      this.popup.visible = false;
      this.popup = undefined;
      this.timer?.stop();
      this.timer = undefined;
      BarModal.openModal = null;
    }
  }

  show() {
    // If another modal is currently open, close it first
    if (BarModal.openModal !== null && BarModal.openModal !== this) {
      BarModal.openModal.hide();
    }

    // If the current modal is already open only reset its close timer
    if (this.popup) {
      this.timer?.again();
      return;
    }

    BarModal.openModal = this;
    this.popup = awful.popup({
      type: "dialog",
      visible: true,
      screen: screen.primary,
      bg: transparency(theme.bg.base, 0.65),
      ontop: true,
      placement: (c) => awful.placement.bottom(c, { margins: { bottom: dpi(60, screen.primary) } }),
      widget: wibox.widget(
        <wibox.container.margin top={dpi(25, screen.primary)} bottom={dpi(25, screen.primary)} left={dpi(20, screen.primary)} right={dpi(20, screen.primary)}>
          <wibox.layout.fixed.vertical spacing={dpi(25, screen.primary)}>
            <wibox.container.place halign="center">
              <wibox.widget.imagebox id="icon" image={gears.color.recolor_image(`${ICON_PATH}/${this.icon}`, theme.highlight.regular)} forced_height={dpi(52, screen.primary)} forced_width={dpi(52, screen.primary)} />
            </wibox.container.place>
            <wibox.widget.progressbar id="bar" value={this.value / 100} color={theme.highlight.regular} background_color={transparency(theme.bg.panel, 0.5)} shape={gears.shape.rounded_rect} forced_width={dpi(200, screen.primary)} forced_height={dpi(4, screen.primary)} />
          </wibox.layout.fixed.vertical>
        </wibox.container.margin>
      ),
    });

    this.timer = gears.timer.start_new(MODAL_TIMEOUT, () => {
      this.hide();
    });
  }
}