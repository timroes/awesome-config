/** @noSelf */
interface Awesome {
  restart(): void;
  quit(exitCode?: number): void;

  emit_signal(signal: string, ...args: unknown[]): void;
}

declare const awesome: Awesome;