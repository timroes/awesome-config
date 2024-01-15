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

  interface Wibar {
    position?: 'top' | 'bottom' | 'left' | 'right';
    screen: Screen;
    height?: number;
    width?: number;
    x?: number;
    y?: number;
    bg?: string;
    widget?: WidgetBase;
  }

  type WibarArgs = Wibar;

  export const wibar: (args: WibarArgs) => Wibar;
  export const screen: ScreenModule;
  export const client: ClientModule;
  export function button(modifiers: string[], button: 1 | 2 | 3, onPress: (() => void) | null, onRelease?: (() => void) | null): unknown[];
}