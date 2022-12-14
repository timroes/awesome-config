declare module 'lunaconf' {
  /** @noSelf */
  interface Utils {
    spawn(cmd: string): void;
  }

  /** @noSelf */
  interface Config {
    get<T = unknown>(key: string, defaultValue?: T): T;
  }
  
  interface BarDialogInstance {
    set_value(value: number): void;
    set_disabled(disabled: boolean): void;
    set_icon(icon: string): void;
    show(): void;
  }

  /** @noSelf */
  interface Dialogs {
    bar(icon: string, timeout: number): BarDialogInstance;
  }

  interface SidebarInstance {
    set_screensleep(keepalive: boolean): void;
  }

  /** @noSelf */
  interface Sidebar {
    get(): SidebarInstance;
  }

  interface Notification {
    text: string;
    title?: string;
    icon?: string;
    timeout?: number;
    ignore_dnd?: boolean;
  }

  /** @noSelf */
  interface Notify {
    show(notification: Notification): void;
    show_or_update(key: string, notification: Notification): void;
  }
  
  export const sidebar: Sidebar;
  export const utils: Utils;
  export const config: Config;
  export const dialogs: Dialogs;
  export const notify: Notify;
}