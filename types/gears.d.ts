declare module 'gears' {
  /** @noSelf */
  interface Filesystem {
    get_configuration_dir(): string;
  }

  interface TimerInstance {
    start(): void;
    stop(): void;
    again(): void;
  }

  /** @noSelf */
  interface Timer {
    start_new(timeoutInSeconds: number, callback: () => boolean | void): TimerInstance;
  }

  export const filesystem: Filesystem;
  export const timer: Timer;
}