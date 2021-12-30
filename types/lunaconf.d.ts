declare module 'lunaconf' {

  interface Utils {
    spawn(cmd: string): void;
  }

  export const utils: Utils;
}