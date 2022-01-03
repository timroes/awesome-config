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
  
  export const utils: Utils;
  export const config: Config;
  export const dialogs: Dialogs;
}