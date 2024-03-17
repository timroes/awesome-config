declare module 'lgi' {
  /** @noSelf */
  interface Async {
    call: (...args: unknown[]) => () => void;
  }

  interface DBusConnection {
    async_call(destination: string, objectPath: string, interfaceName: string, member: string, params: any, returnType: string | null, flags: number, timeout: number): LuaMultiReturn<[any, any]>;
    signal_subscribe(...args: any[]): number;
    call_sync(...args: any[]): any;
  }

  /** @noSelf */
  interface Gio {
    bus_get_sync(type: number): DBusConnection;
    BusType: {
      SESSION: number;
      SYSTEM: number;
    }
    DBusSignalFlags: {
      NONE: unknown;
    }
    DBusCallFlags: {
      NONE: 0;
      NO_AUTO_START: 1;
    },
    Async: Async,
  }

  /** @noSelf */
  interface GLib {
    Variant: {
      (type: string, value: unknown): unknown;
      new_tuple(value: unknown, length: number): unknown;
    };
  }

  export const Gio: Gio;
  export const GLib: GLib;
}