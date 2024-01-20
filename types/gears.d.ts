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

  type Context = { 
    /**
     * This doesn't really exist in the Lua object, just here to distinguish types in TS.
     */
    __type: "cairo_context"
  };
  type ShapeFn = (cr: Context, width: number, height: number) => void;

  /** @noSelf */
  interface ShapeModule {
    rounded_rect: (cr: Context, width: number, height: number, radius: number) => void;
    circle: (cr: Context, width: number, height: number, radius: number) => void;
  }

  export const filesystem: Filesystem;
  export const timer: Timer;
  export const shape: ShapeModule;
}