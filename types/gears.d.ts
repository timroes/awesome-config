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
    delayed_call(fn: () => void): void;
  }

  type CairoContext = {
    rectangle(x: number, y: number, width: number, height: number): void;
    set_source_rgb(r: number, g: number, b: number): void;
    set_source_rgb(...params: number[]): void;
    fill(): void;
  };

  type ShapeFn = (cr: CairoContext, width: number, height: number) => void;

  interface Transformer {
    (cr: CairoContext, width: number, height: number, ...params: unknown[]): void;
    translate(x: number, y: number): Transformer;
  }

  /** @noSelf */
  interface ShapeModule {
    rounded_rect: (cr: CairoContext, width: number, height: number, radius?: number) => void;
    circle: (cr: CairoContext, width: number, height: number, radius?: number) => void;
    transform: (shapeFn: ShapeFn) => Transformer;
  }

  /** @noSelf */
  interface Color {
    parse_color(color: string): LuaMultiReturn<[number, number, number, number]>;
    recolor_image(image: string, color: string): string;
  }

  /** @noSelf */
  interface String {
    xml_escape(str: string): string;
  }

  export const color: Color;
  export const filesystem: Filesystem;
  export const timer: Timer;
  export const shape: ShapeModule;
  export const string: String;
}