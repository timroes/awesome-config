declare module 'awful' {
  /** @noSelf */
  interface Spawn {
    with_shell(cmd: string): void;
    easy_async(cmd: string, callback: (stdout: string, stderr: string, exitreason: string, exitcode: number) => void): void;
    // @incompleteTyping
    spawn(cmd: string): void;
  }
  export const spawn: Spawn;

  /** @noSelf */
  interface KeyModule {
    (modifiers: string[], key: string, onPress: () => void, onRelease?: () => void): Key[];
  }
  export const key: KeyModule;
}