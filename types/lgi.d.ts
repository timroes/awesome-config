declare module 'lgi' {
  /** @noSelf */
  interface Gio {
    bus_get_sync(type: number): any;
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
    }
  }

  /** @noSelf */
  interface GLib {
    Variant: {
      (type: string, value: unknown): unknown;
      new_tuple(value: unknown, length: number): unknown;
    }
  }

  export const Gio: Gio;
  export const GLib: GLib;
}