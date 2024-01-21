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

  public callSync<T = any>(
    destination: string,
    objectPath: string,
    interfaceName: string,
    member: string,
    params?: Array<[variantType: string, variantValue: unknown]>
  ): T {
    const args = params?.map(([type, value]) => GLib.Variant(type, value));

    const resp = this.bus.call_sync(
      destination,
      objectPath,
      interfaceName,
      member,
      args ? GLib.Variant.new_tuple(args, args.length) : null,
      null, // Reply type (not using this)
      Gio.DBusCallFlags.NONE,
      -1, // Timeout
    );

    return resp;
  }

  public call<T = any>(destination: string, objectPath: string, interfaceName: string, member: string, params?: Array<[variantType: string, variantValue: unknown]>): Promise<T> {
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