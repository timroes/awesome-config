/** @noSelf */
interface Root {
  keys(keys: Key[] | null): void;
  keys(): Key[];
}

declare const root: Root;