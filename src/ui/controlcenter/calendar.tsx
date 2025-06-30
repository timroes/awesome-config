import * as wibox from "wibox";
import * as gears from "gears";

import { ControlWidget } from "./control-widget";
import { theme } from "../../theme/default";
import { dpi } from "../../lib/dpi";
import { log } from "../../lib/log";

export class CalendarWidget extends ControlWidget {
  private monthOffset: number = 0;

  private renderCalendar(s: Screen) {
    const grid = wibox.widget(
      <wibox.layout.grid
        forced_num_cols={7}
        forced_num_rows={8}
        spacing={dpi(2, s)}
        min_rows_size={dpi(24, s)}
        homogeneous={true}
        expand={true}
      />
    ) as GridLayout;
    const now = os.date("*t");
    // Render Month year header
    const monthStart = os.time({ year: now.year, month: now.month + this.monthOffset, day: 1 });
    const lastDay = os.time({ year: now.year, month: now.month + this.monthOffset + 1, day: 0 });
    grid.add_widget_at(
      wibox.widget(
        <wibox.widget.textbox
          align="center"
          markup={`<span weight="normal" color="${theme.controlcenter.calendar.month}">${os.date("%B %Y", monthStart)}</span>`}
        />
      ),
      1,
      1,
      1,
      7
    );
    // Weekdays
    const weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    for (let i = 0; i < weekdays.length; i++) {
      grid.add_widget_at(
        wibox.widget(
          <wibox.widget.textbox
            markup={`<span variant="small-caps" weight="ultrabold" color="${theme.controlcenter.calendar.weekdays}">${weekdays[i]}</span>`}
            align="center"
          />
        ),
        2,
        i + 1,
        1,
        1
      );
    }
    // Render day grid
    const firstWeekday = Number(os.date("%w", monthStart));
    const firstCell = (firstWeekday + 6) % 7;

    const { month, year } = os.date("*t", monthStart);

    for (let day = 0; day < Number(os.date("%d", lastDay)); day++) {
      const isToday = now.year === year && now.month === month && now.day === day + 1;
      const markup = isToday ? `<span weight="ultrabold" color="${theme.controlcenter.calendar.today}">${day + 1}</span>` : `${day + 1}`;
      grid.add_widget_at(
        wibox.widget(<wibox.widget.textbox markup={markup} align="center" />),
        Math.floor((day + firstCell) / 7) + 3,
        ((day + firstCell) % 7) + 1,
        1,
        1
      );
    }

    return grid;
  }

  private updateCalendar() {
    (this.currentRender.get_children_by_id("dates")[0] as BackgroundContainer).widget = this.renderCalendar(screen.primary);
  }

  onShow(): void {
    this.monthOffset = 0;
    this.updateCalendar();
  }

  override onKeyPress(modifiers: Modifier[], key: string): void {
    switch (key) {
      case "Down":
        this.monthOffset++;
        this.updateCalendar();
        break;
      case "Up":
        this.monthOffset--;
        this.updateCalendar();
        break;
      case "Home":
        this.monthOffset = 0;
        this.updateCalendar();
        break;
    }
  }

  private renderClock(s: Screen, tz: string, label: string) {
    const clockFormat = `<span font_size="xx-large" weight="light" color="${theme.text.light}"><span weight="semibold">%H</span>:%M</span>`;
    return (
      <wibox.container.background shape={gears.shape.rounded_rect} bg={theme.controlcenter.panel}>
        <wibox.container.margin left={dpi(8, s)} right={dpi(8, s)} top={dpi(16, s)} bottom={dpi(16, s)}>
          <wibox.layout.stack>
            <wibox.container.place halign="center">
              <wibox.widget.textclock timezone={tz} format={clockFormat} />
            </wibox.container.place>
            <wibox.container.place valign="bottom">
              <wibox.widget.textbox
                markup={`<span size="small" color="${theme.text.subdued}">${label}</span>`}
                align="center"
                color={theme.text.dark}
              />
            </wibox.container.place>
          </wibox.layout.stack>
        </wibox.container.margin>
      </wibox.container.background>
    );
  }

  override render(s: Screen): WidgetDefinition {
    return (
      <wibox.layout.align.horizontal spacing={dpi(8, s)}>
        {null}
        <wibox.container.background shape={gears.shape.rounded_rect} bg={theme.controlcenter.panel}>
          <wibox.container.margin margins={dpi(8, s)} id="dates">
            {this.renderCalendar(s)}
          </wibox.container.margin>
        </wibox.container.background>
        <wibox.container.margin left={dpi(8, s)} forced_width={dpi(110, s)}>
          <wibox.layout.flex.vertical spacing={dpi(8, s)}>
            {this.renderClock(s, "Europe/Berlin", "Home")}
            {this.renderClock(s, "America/Los_Angeles", "San Francisco")}
          </wibox.layout.flex.vertical>
        </wibox.container.margin>
      </wibox.layout.align.horizontal>
    );
  }
}
