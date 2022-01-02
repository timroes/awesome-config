import * as lgi from 'lgi';

const { GLib, Gio } = lgi;

class DBusConnection {
  constructor(private bus: any) {}

  public onSignal(
    sender: string | null,
    interfaceName: string | null,
    member: string | null,
    objectPath: string | null,
    callback: (signal: unknown) => void,
  ): number {
    return this.bus.signal_subscribe(sender, interfaceName, member, objectPath, null, Gio.DBusSignalFlags.NONE, callback);
  }

  public call<T = unknown>(
    destination: string,
    objectPath: string,
    interfaceName: string,
    member: string,
    params?: Array<[variantType: string, variantValue: unknown]>
  ): Promise<T | undefined> {
    const args = params?.map(([type, value]) => GLib.Variant(type, value));

    this.bus.call_sync(
      destination,
      objectPath,
      interfaceName,
      member,
      args ? GLib.Variant.new_tuple(args, args.length) : null,
      null, // Reply type (not using this)
      Gio.DBusCallFlags.NONE,
      -1, // Timeout
    );
    // TODO: does not yet handle dbus calls with response
    return Promise.resolve(undefined);
  }
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