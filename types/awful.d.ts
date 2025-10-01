declare module "awful" {
  /** @noSelf */
  interface SpawnArgs extends Partial<Pick<Client, ModifiableClientProperties>> {
    tag?: Tag;
    callback?: (client: Client) => void;
  }

  /** @noSelf */
  interface Spawn {
    with_shell(cmd: string): void;
    easy_async(
      cmd: string,
      callback: (stdout: string, stderr: string, exitreason: "exit" | "signal", exitcode: number) => void
    ): number;
    with_line_callback(
      cmd: string,
      callbacks: {
        stdout?: (line: string) => void;
        stderr?: (line: string) => void;
        output_done?: () => void;
        exit?: (exitreason: "exit" | "signal", exitcode: number) => void;
      }
    ): number;
    // @incompleteTyping
    spawn(cmd: string, args?: SpawnArgs, callback?: (client: Client) => void): void;
  }
  export const spawn: Spawn;

  /** @noSelf */
  interface KeyModule {
    (modifiers: string[], key: string, onPress: () => void, onRelease?: () => void): Key[];
  }
  export const key: KeyModule;

  /** @noSelf */
  interface ClientModule {
    object: any;
    next: (offset: number) => Client | null;
    focus: {
      history: {
        previous(): void;
      };
    };
  }

  /** @noSelf */
  interface ScreenModule {
    connect_for_each_screen(callback: (screen: Screen) => void): void;
  }

  interface Wibar<T extends Widget> {
    position?: "top" | "bottom" | "left" | "right";
    screen: Screen;
    height?: number;
    width?: number;
    x?: number;
    y?: number;
    bg?: string;
    widget?: T;
    remove(): void;
  }

  type WibarArgs<T extends Widget> = Omit<Wibar<T>, "remove">;

  type TasklistFilterFn = (client: Client, screen: Screen) => boolean;

  interface TasklistArgs {
    screen: Screen;
    filter: TasklistFilterFn;
    buttons?: Button[];
    layout: WidgetDefinition;
    widget_template: WidgetDefinition & {
      create_callback?: (self: Widget, client: Client, index: number, clients: Client[]) => void;
    };
  }

  /** @noSelf */
  interface WidgetModule {
    tasklist: {
      (args: TasklistArgs): Widget;
      filter: {
        currenttags: TasklistFilterFn;
      };
    };
  }

  type Position =
    | "top"
    | "bottom"
    | "left"
    | "right"
    | "centered"
    | "top_left"
    | "top_right"
    | "bottom_left"
    | "bottom_right";

  interface PlacementArgs {
    pretend?: boolean;
    honor_workarea?: boolean;
    honor_padding?: boolean;
    margins?: number | { top?: number; right?: number; bottom?: number; left?: number };
    offset?: number | { x?: number; y?: number };
  }

  type PlacementFn = (drawable: Drawable, options?: PlacementArgs) => void;

  type Drawable = Client | Wibox | Popup;

  /** @noSelf */
  interface PlacementModule {
    align(drawable: Drawable, args: PlacementArgs & { position: Position }): void;
    centered: PlacementFn;
    bottom: PlacementFn;
  }

  interface KeygrabberInstance {
    stop(): void;
  }

  interface KeygrabberArgs {
    /**
     * @default "press"
     */
    stop_event?: "press" | "release";
    stop_key?: string | Key;
    /**
     * The maximum inactivity delay.
     * @default -1
     */
    timeout?: number;
    start_callback?: () => void;
    stop_callback?: () => void;
    keypressed_callback?: (
      this: KeygrabberInstance,
      modifiers: Modifier[],
      key: string,
      event: "press" | "release"
    ) => void;
    keyreleased_callback?: (
      this: KeygrabberInstance,
      modifiers: Modifier[],
      key: string,
      event: "press" | "release"
    ) => void;
    allowed_keys?: string[];
    /**
     * Create root (global) keybindings.
     * @default false
     */
    export_keybindings?: boolean;
    /**
     * Do not call the callbacks on modifier keys (like Control or Mod4) events.
     * @default false
     */
    mask_modkeys?: boolean;
    root_keybindings?: Array<[modifiers: Modifier[], key: string, cb: () => void]>;
  }

  type KeygrabberFn = (modifiers: Modifier[], key: string, event: "press" | "release") => boolean | void;

  /** @noSelf */
  interface KeygrabberModule {
    (args: KeygrabberArgs): KeygrabberInstance;
    run(grabber: KeygrabberFn): KeygrabberFn;
    stop(grabber: KeygrabberFn): void;
  }

  interface PopupArgs {
    screen: Screen;
    widget: Widget;
    visible?: boolean;
    type?: WindowType;
    width?: number;
    height?: number;
    x?: number;
    y?: number;
    bg?: string;
    ontop?: boolean;
    placement?: PlacementFn;
    opacity?: number;
    offset?:
      | number
      | {
          x?: number;
          y?: number;
        };
  }

  interface Popup extends Required<PopupArgs> {}

  /** @noSelf */
  interface PopupModule {
    (args: PopupArgs): Popup;
  }

  interface Rule {
    rule: {
      class?: string;
      instance?: string;
      name?: string;
      role?: string;
      type?: string;
    };
    properties?: Partial<Pick<Client, "floating">> & {};
    callback?: (client: Client) => void;
  }

  /** @noSelf */
  interface RulesModule {
    rules: Rule[];
  }

  /** @noSelf */
  interface TagModule {
    add(name: string, args: Partial<Pick<Tag, "selected" | "index" | "screen">>): Tag;
  }

  export const popup: PopupModule;
  export const keygrabber: KeygrabberModule;
  export const placement: PlacementModule;
  export const widget: WidgetModule;
  export const wibar: <T extends Widget>(args: WibarArgs<T>) => Wibar<T>;
  export const screen: ScreenModule;
  export const client: ClientModule;
  export const rules: RulesModule;
  export const tag: TagModule;
  export function button<T extends any[] = []>(
    modifiers: Modifier[],
    button: 1 | 2 | 3,
    onPress: ((...args: T) => void) | null,
    onRelease?: (() => void) | null
  ): Button[];
}
