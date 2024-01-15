interface Client {
  name: string;
  class: string;
  floating: boolean;
  x: number;
  y: number;
  width: number;
  height: number;
  requests_no_titlebar: boolean;
  skip_taskbar: boolean;
  screen: Screen;
  set_xproperty(name: string, value: boolean | string | number): void;
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;
  raise(): void;
  kill(): void;
  geometry(): unknown;
}

type ClientProperties = 'floating' | 'screen' | 'requests_no_titlebar' | 'is_docked';
type ClientSignals = 'manage' | 'unmanage' | `property::${ClientProperties}` | "request::titlebars";

/** @noSelf */
interface ClientGlobal {
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;
}

declare const client: ClientGlobal;