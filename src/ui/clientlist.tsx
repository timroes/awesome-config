import * as awful from 'awful';
import * as wibox from 'wibox';
import * as gears from 'gears';
import * as lunaconf from 'lunaconf';
import { dpi } from '../lib/dpi';
import { theme } from '../theme/default';
import { MouseButton } from '../lib/mouse';

const getColor = (c: Client, type: "fg" | "bg") => {
  if (c.urgent) {
    return theme.clientlist[type].urgent;
  }
  if (c.minimized) {
    return theme.clientlist[type].minimized;
  }
  if (c == client.focus) {
    return theme.clientlist[type].focused;
  }
  return theme.clientlist[type].normal;
};

export const createClientlist = (screen: Screen) => {
  const buttons = [
    ...awful.button<[Client]>([], MouseButton.PRIMARY, (c) => {
      if (c === client.focus) {
        c.minimized = true;
      } else {
        c.minimized = false;
        client.focus = c;
        c.raise();
      }
    }),
    ...awful.button<[Client]>([], MouseButton.MIDDLE, (c) => c.kill()),
    ...awful.button<[Client]>([], MouseButton.SECONDARY, (c) => {
      const tagsWithAction = c.tags().filter((t) => t.layout.clientlistAction);
      if (tagsWithAction.length > 0) {
        // If the current tags have clientlistActions, execute them instead of toggling minimization status
        tagsWithAction.forEach(t => t.layout.clientlistAction!(c));
      } else {
        c.minimized = !c.minimized;
      }
    }),
  ];

  const onUpdate = (self: Widget, c: Client) => {
    (self.get_children_by_id("clientname")[0] as TextBox).text = c.name || c.class || " ";
    (self.get_children_by_id("ontopIndicator")[0] as TextBox).visible = c.ontop;
    const bg = self.get_children_by_id("background")[0] as BackgroundContainer;
    bg.bg = getColor(c, "bg");
    bg.fg = getColor(c, "fg");
  };
  
  const onCreate = (self: Widget, c: Client) => {
    (self.get_children_by_id("clienticon")[0] as any).client = c;
    onUpdate(self, c);
  };

  const widget = awful.widget.tasklist({
    screen,
    buttons,
    filter: awful.widget.tasklist.filter.currenttags,
    layout:
      <wibox.layout.flex.horizontal spacing={dpi(3, screen)} max_widget_size={dpi(300, screen)} />,
    widget_template: (
      <wibox.container.margin
        top={dpi(4, screen)}
        bottom={dpi(4, screen)}
        create_callback={onCreate}
        update_callback={onUpdate}
      >
        <wibox.container.background
          id="background"
          shape={gears.shape.rounded_rect}
          bg={theme.clientlist.bg.normal}
          fg={theme.clientlist.fg.normal}
        >
          <wibox.container.margin left={dpi(3, screen)} right={dpi(3, screen)} top={dpi(1, screen)} bottom={dpi(1, screen)}>
            <wibox.layout.align.horizontal>
              <lunaconf.widgets.clienticon id="clienticon" />
              <wibox.container.margin left={dpi(5, screen)} right={dpi(5, screen)}>
                <wibox.widget.textbox id="clientname" />
              </wibox.container.margin>
              <wibox.container.background shape={gears.shape.circle} bg={theme.clientlist.indicators.ontop}>
                <wibox.container.margin margins={dpi(2, screen)} id="ontopIndicator" visible={false}>
                  <wibox.widget.textbox markup={`<span color="${theme.text.dark}" weight="500">⇧</span>`} />
                </wibox.container.margin>
              </wibox.container.background>
            </wibox.layout.align.horizontal>
          </wibox.container.margin>
        </wibox.container.background>
      </wibox.container.margin>
    )
  });
  return widget;
};