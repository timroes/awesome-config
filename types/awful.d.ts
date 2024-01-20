declare module 'awful' {
  /** @noSelf */
  interface Spawn {
    with_shell(cmd: string): void;
    easy_async(cmd: string, callback: (stdout: string, stderr: string, exitreason: 'exit' | 'signal', exitcode: number) => void): void;
    // @incompleteTyping
    spawn(cmd: string): void;
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
  }

  /** @noSelf */
  interface ScreenModule {
    connect_for_each_screen(callback: (screen: Screen) => void): void;
  }

  interface Wibar<T extends Widget> {
    position?: 'top' | 'bottom' | 'left' | 'right';
    screen: Screen;
    height?: number;
    width?: number;
    x?: number;
    y?: number;
    bg?: string;
    widget?: T;
  }

  type WibarArgs<T extends Widget> = Wibar<T>;

  type TasklistFilterFn = (client: Client, screen: Screen) => boolean;

  interface TasklistArgs {
    screen: Screen;
    filter: TasklistFilterFn;
    buttons?: Button[];
    layout: WidgetDefinition;
    widget_template: WidgetDefinition & { create_callback?: (self: Widget, client: Client, index: number, clients: Client[]) => void };
  }

  /** @noSelf */
  interface WidgetModule {
    tasklist: {
      (args: TasklistArgs): Widget;
      filter: {
        currenttags: TasklistFilterFn;
      }
    }
  }

  export const widget: WidgetModule;
  export const wibar: <T extends Widget>(args: WibarArgs<T>) => Wibar<T>;
  export const screen: ScreenModule;
  export const client: ClientModule;
  export function button<T extends any[] = []>(modifiers: Modifier[], button: 1 | 2 | 3, onPress: ((...args: T) => void) | null, onRelease?: (() => void) | null): Button[];
}