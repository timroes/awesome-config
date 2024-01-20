import * as awful from 'awful';
import * as wibox from 'wibox';
import * as gears from 'gears';
import * as lunaconf from 'lunaconf';
import { dpiX, dpiY } from '../lib/dpi';
import { theme } from '../theme/default';

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
    ...awful.button<[Client]>([], 1, (c) => {
      if (c === client.focus) {
        c.minimized = true;
      } else {
        c.minimized = false;
        client.focus = c;
        c.raise();
      }
    }),
    ...awful.button<[Client]>([], 2, (c) => c.kill()),
    ...awful.button<[Client]>([], 3, (c) => {
      client.focus = c;
      c.minimized = !c.minimized;
    }),
  ];

  const onUpdate = (self: Widget, c: Client) => {
    (self.get_children_by_id('clientname')[0] as TextBox).text = c.name;
    const bg = self.get_children_by_id("background")[0] as wibox.BackgroundContainer;
    bg.bg = getColor(c, "bg");
    bg.fg = getColor(c, "fg");
  };
  
  const onCreate = (self: Widget, c: Client) => {
    (self.get_children_by_id('clienticon')[0] as any).client = c;
    onUpdate(self, c);
  };

  const widget = awful.widget.tasklist({
    screen,
    buttons,
    filter: awful.widget.tasklist.filter.currenttags,
    layout:
      <wibox.layout.flex.horizontal spacing={dpiX(3, screen)} max_widget_size={dpiX(300, screen)} />,
    widget_template: (
      <wibox.container.margin
        top={dpiY(4, screen)}
        bottom={dpiY(4, screen)}
        create_callback={onCreate}
        update_callback={onUpdate}
      >
        <wibox.container.background
          id="background"
          shape={gears.shape.rounded_rect}
          bg={theme.clientlist.bg.normal}
          fg={theme.clientlist.fg.normal}
        >
          <wibox.container.margin left={dpiX(3, screen)} right={dpiX(3, screen)} top={dpiY(1, screen)} bottom={dpiY(1, screen)}>
            <wibox.layout.fixed.horizontal spacing={dpiX(5, screen)}>
              <lunaconf.widgets.clienticon id="clienticon" />
              <wibox.widget.textbox id="clientname" />
            </wibox.layout.fixed.horizontal>
          </wibox.container.margin>
        </wibox.container.background>
      </wibox.container.margin>
    )
  });
  return widget;
};