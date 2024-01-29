interface MotifWmHints {
  decorations?: {
    all?: boolean;
    border?: boolean;
    maximize?: boolean;
    menu?: boolean;
    minimize?: boolean;
    resizeh?: boolean;
    title?: boolean;
  };
  functions?: {
    all?: boolean;
    close?: boolean;
    maximize?: boolean;
    minimize?: boolean;
    move?: boolean;
    resize?: boolean;
  };
  input_mode?: string;
  status?: {
    tearoff_window?: boolean;
  }
}

interface SizeHints {
  user_position?: {
    x?: number;
    y?: number;
  };
  program_position?: {
    x?: number;
    y?: number;
  };
  max_height?: number;
  max_width?: number;
  min_height?: number;
  min_width?: number;
  program_size?: {
    width?: number;
    height?: number;
  };
  user_size?: {
    width?: number;
    height?: number;
  };
  win_gravity?: string;
}

type WindowType = 
  | "desktop"
  | "dock"
  | "splash"
  | "dialog"
  | "menu"
  | "toolbar"
  | "utility"
  | "dropdown_menu"
  | "popup_menu"
  | "notification"
  | "combo"
  | "dnd"
  | "normal";

interface Client {
  /**
   * The X window id of the client.
   */
  readonly window: number;
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
  minimized: boolean;
  urgent: boolean;
  modal: boolean;
  transient_for: number | null;
  group_window: number | null;
  leader_window: number | null;
  ontop: boolean;
  size_hints?: SizeHints;
  readonly motif_wm_hints: MotifWmHints | null;
  readonly is_fixed: () => boolean;
  set_xproperty(name: string, value: boolean | string | number): void;
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;
  tags(tags?: Tag[]): Tag[];
  raise(): void;
  kill(): void;
  geometry(): unknown;
}

type ClientProperties = 'floating' | 'screen' | 'requests_no_titlebar' | 'is_docked';
type ClientSignals = 'manage' | 'unmanage' | 'focus' | `property::${ClientProperties}` | "request::titlebars";

/** @noSelf */
interface ClientGlobal {
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;
  focus?: Client;
  get(screenIndex?: number, stacked?: boolean): Client[];
}

declare const client: ClientGlobal;