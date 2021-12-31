/** @noSelf */
interface Awesome {
  restart(): void;
  quit(exitCode?: number): void;
}

declare const awesome: Awesome;