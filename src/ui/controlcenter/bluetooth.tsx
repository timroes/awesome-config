import * as wibox from 'wibox';
import * as awful from 'awful';
import * as gears from 'gears';
import { dbus } from '../../lib/dbus';
import { theme } from '../../theme/default';
import { dpiX } from '../../lib/dpi';

export const bluetoothControl = (screen: Screen) => { 
  const widget = wibox.widget(
    <wibox.container.background bg={theme.bg.panel} shape={gears.shape.rounded_rect}>
      <wibox.layout.fixed.vertical id="devices" />
    </wibox.container.background>
  );

  const deviceList = widget.get_children_by_id("devices")[0] as wibox.FixedLayout;
  const devices: Record<string, { connected: boolean; name: string; icon: string, pendingAction: boolean; }> = {};
  
  const onUpdate = () => {
      deviceList.reset();
      for (const [path, info] of Object.entries(devices)) {
        const buttons = awful.button([], 1, () => {
          devices[path].pendingAction = true;
          onUpdate();
          dbus.system().call("org.bluez", path, "org.bluez.Device1", info.connected ? "Disconnect" : "Connect", []).then(() => {
            devices[path].pendingAction = false;
            onUpdate();
          });
        });
        const indicatorColor = info.pendingAction ? theme.highlight.regular : info.connected ? theme.highlight.success : theme.transparent;
        const borderColor = info.connected ? theme.highlight.success : theme.highlight.disabled;
        deviceList.add(wibox.widget(
            <wibox.container.margin margins={dpiX(12, screen)} buttons={buttons}>
              <wibox.layout.fixed.horizontal spacing={dpiX(5, screen)}>
                <wibox.container.background bg={indicatorColor} shape={gears.shape.circle} shape_border_width={dpiX(1, screen)} shape_border_color={borderColor} forced_width={dpiX(8, screen)} forced_height={dpiX(8, screen)}>
                  <wibox.widget.textbox text="" />
                </wibox.container.background>
                <wibox.widget.textbox text={info.name} />
              </wibox.layout.fixed.horizontal>
            </wibox.container.margin>
        ));
      }
  };

  dbus.system().call("org.bluez", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects", []).then((result) => {
    const r: { pairs: () => LuaIterable<LuaMultiReturn<[string, any]>> } = result.get_child_value(0);
    for (const [path, info] of r.pairs()) {
      if (info['org.bluez.Device1']) {
        devices[path] = {
          name: info['org.bluez.Device1']['Name'],
          icon: info['org.bluez.Device1']['Icon'],
          connected: info['org.bluez.Device1']['Connected'] === true,
          pendingAction: false,
        };
      }
      dbus.system().onSignal<[string, { Connected?: boolean }]>(null, "org.freedesktop.DBus.Properties", "PropertiesChanged", path, (event) => {
        if (event.params[1].Connected !== undefined) {
          devices[path].pendingAction = false;
          devices[path].connected = event.params[1].Connected;
          onUpdate();
        }
      });
    }
    onUpdate();
  });

  return widget;
};