/** @noSelf */
interface Awesome {
  composite_manager_running: boolean;

  restart(): void;
  quit(exitCode?: number): void;
  emit_signal(signal: string, ...args: unknown[]): void;
  connect_signal(signal: string, callback: (...args: unknown[]) => void): void;
  register_xproperty(name: string, type: "string" | "number" | "boolean"): void;
}

declare const awesome: Awesome;