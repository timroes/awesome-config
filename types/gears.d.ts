declare module 'gears' {
  /** @noSelf */
  interface Filesystem {
    get_configuration_dir(): string;
  }

  export const filesystem: Filesystem;
}