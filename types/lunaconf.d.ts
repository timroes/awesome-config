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

  interface SidebarInstance {
    set_screensleep(keepalive: boolean): void;
    trigger: WidgetBase;
  }

  /** @noSelf */
  interface Sidebar {
    get(): SidebarInstance;
    rerender(): SidebarInstance;
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

  /** @noSelf */
  interface Clients {
    smart_move(client: Client): void;
  }

  /** @noSelf */
  interface Tags {
    create_widget(screen: Screen): WidgetBase;
    get_current_tag(screen: Screen): Tag;
  }

  /** @noSelf */
  interface Widgets {
    tasklist(screen: Screen): WidgetBase;
    clienttitle(screen: Screen): WidgetBase;
    clienticon: WidgetBase;
  }

  /** @noSelf */
  interface Icons {
    lookup_icon(name: string): string;
  }

  export const icons: Icons;
  export const sidebar: Sidebar;
  export const utils: Utils;
  export const config: Config;
  export const notify: Notify;
  export const clients: Clients;
  export const tags: Tags;
  export const widgets: Widgets;
}

declare module 'lunaconf.config' {
  import { Config } from 'lunaconf';
  export const get: Config['get'];
}
