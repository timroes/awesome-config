import * as wibox from 'wibox';

export type TriggerColor = "pink" | "yellow";

interface Handler {
  setTriggerColor: (color: TriggerColor, enabled: boolean) => void;
  requestRelayout: () => void;
}

export abstract class ControlWidget {
  protected currentRender!: Widget;
  protected screen!: Screen;

  constructor(protected handler: Handler) {}

  onInit(): void {};
  onShow(): void {};
  onHide(): void {};
  onKeyPress(modifiers: Modifier[], key: string): void {}

  renderAndStore(s: Screen): Widget {
    this.screen = s;
    this.currentRender = wibox.widget(this.render(s));
    return this.currentRender;
  }

  abstract render(s: Screen):  WidgetDefinition;
}
