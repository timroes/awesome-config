declare module 'lunaconf' {
  /** @noSelf */
  interface Utils {
    spawn(cmd: string): void;
  }

  export const utils: Utils;

  /** @noSelf */
  interface Config {
    get<T = unknown>(key: string, defaultValue?: T): T;
  }

  export const config: Config;
}