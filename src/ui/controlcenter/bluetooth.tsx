import * as wibox from 'wibox';
import * as awful from 'awful';
import * as gears from 'gears';
import { dbus } from '../../lib/dbus';
import { theme } from '../../theme/default';
import { dpi } from '../../lib/dpi';
import { ICON_PATH } from '../../lib/constants';
import { ControlWidget } from './control-widget';

const ICON_MAP: Record<string, string> = {
  "audio-headset": "audio-headset.png",
  "audio-card": "music.png",
};

const DEFAULT_ICON = "bluetooth.png";

export class BluetoothControl extends ControlWidget {
  private devices: Record<string, { connected: boolean; name: string; icon: string, pendingAction: boolean; }> = {};

  private onUpdate() {
    const deviceList = this.currentRender.get_children_by_id("devices")[0] as FixedLayout;
    deviceList.reset();
    for (const [path, info] of Object.entries(this.devices)) {
      const buttons = awful.button([], 1, () => {
        this.devices[path].pendingAction = true;
        this.onUpdate();
        dbus.system().call("org.bluez", path, "org.bluez.Device1", info.connected ? "Disconnect" : "Connect", []).catch(() => {
          this.devices[path].pendingAction = false;
          this.onUpdate();
        });
      });
      const icon = ICON_MAP[info.icon] || DEFAULT_ICON;
      const color = info.pendingAction ? theme.highlight.regular : info.connected ? theme.highlight.success : theme.highlight.disabled;
      deviceList.add(wibox.widget(
          <wibox.container.margin margins={dpi(12, this.screen)} buttons={buttons}>
            <wibox.layout.fixed.horizontal spacing={dpi(6, this.screen)}>
              <wibox.widget.imagebox image={gears.color.recolor_image(`${ICON_PATH}/${icon}`, color)} forced_height={dpi(14, this.screen)} />
              <wibox.widget.textbox text={info.name} />
            </wibox.layout.fixed.horizontal>
          </wibox.container.margin>
      ));
    }
  }

  override onInit() {
    dbus.system().call("org.bluez", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects", []).then((result) => {
      const r: { pairs: () => LuaIterable<LuaMultiReturn<[string, any]>> } = result.get_child_value(0);
      for (const [path, info] of r.pairs()) {
        if (info['org.bluez.Device1']) {
          this.devices[path] = {
            name: info['org.bluez.Device1']['Name'],
            icon: info['org.bluez.Device1']['Icon'],
            connected: info['org.bluez.Device1']['Connected'] === true,
            pendingAction: false,
          };
        }
        dbus.system().onSignal<[string, { Connected?: boolean }]>(null, "org.freedesktop.DBus.Properties", "PropertiesChanged", path, (event) => {
          if (event.params[1].Connected !== undefined) {
            this.devices[path].pendingAction = false;
            this.devices[path].connected = event.params[1].Connected;
            this.onUpdate();
          }
        });
      }
      this.onUpdate();
    });
  }

  override render(s: Screen) {
    return (
      <wibox.container.background bg={theme.controlcenter.panel} shape={gears.shape.rounded_rect}>
        <wibox.layout.fixed.vertical id="devices" spacing={dpi(2, s)} spacing_widget={<wibox.widget.separator span_ratio={0.95} color={theme.controlcenter.backround} />} />
      </wibox.container.background>
    );
  }
}
