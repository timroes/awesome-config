declare module 'beautiful' {
  /** @noSelf */
  interface Xresources {
    set_dpi(dpi: number, screen?: Screen): void;
  }

  export const xresources: Xresources;
}