import * as lgi from 'lgi';

interface SignalParams<Params = undefined> {
  sender: string;
  objectPath: string;
  interfaceName: string;
  signalName: string;
  params: Params;
}

const { GLib, Gio } = lgi;

class DBusConnection {
  constructor(private bus: lgi.DBusConnection) {}

  public onSignal<T = undefined>(
    sender: string | null,
    interfaceName: string | null,
    signalName: string | null,
    objectPath: string | null,
    callback: (signal: SignalParams<T>) => void,
  ): number {
    return this.bus.signal_subscribe(sender, interfaceName, signalName, objectPath, null, Gio.DBusSignalFlags.NONE,
      (connection: unknown, sender: string, objectPath: string, interfaceName: string, signalName: string, args?: any) => {
        callback({ sender, objectPath, interfaceName, signalName, params: args.value });
      }
    );
  }

  public call<T = unknown>(destination: string, objectPath: string, interfaceName: string, member: string, params?: Array<[variantType: string, variantValue: unknown]>): Promise<{ value: T; type: string; get_child_value: (index: number) => any }> {
    const args = params?.map(([type, value]) => GLib.Variant(type, value));

    return new Promise((resolve, reject) => {
      lgi.Gio.Async.call(() => {
        const [result, error] = this.bus.async_call(
          destination,
          objectPath,
          interfaceName,
          member,
          args ? GLib.Variant.new_tuple(args, args.length) : null,
          null,
          Gio.DBusCallFlags.NONE,
          -1
        );
        if (error) {
          reject(error);
        } else {
          resolve(result);
        }
      })();
    });
  }

  public async getProperty<T = any>(destination: string, objectPath: string, interfaceName: string, property: string): Promise<T> {
    const result = await this.call<[{ type: string, value: T }]>(destination, objectPath, "org.freedesktop.DBus.Properties", "Get", [
      ["s", interfaceName],
      ["s", property],
    ]);
    return result.value[0].value;
  }

  // TODO: Untested implementation
  // public async emitSignal(
  //   destination: string | null,
  //   objectPath: string,
  //   interfaceName: string,
  //   signalName: string
  // ): Promise<void> {
  //   this.bus.emit_signal(
  //     destination,
  //     objectPath,
  //     interfaceName,
  //     signalName,
  //     null // parameters
  //   );
  // }
}

let system: DBusConnection;
let session: DBusConnection;

export const dbus = {
  system() {
    if (!system) {
      system = new DBusConnection(Gio.bus_get_sync(Gio.BusType.SYSTEM));
    }
    return system;
  },
  session() {
    if (!session) {
      session = new DBusConnection(Gio.bus_get_sync(Gio.BusType.SESSION));
    }
    return session;
  }
};