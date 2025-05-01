interface Mouse {
  x: number;
  y: number;
  buttons: boolean[];
}

/** @noSelf */
interface MouseGlobal {
  current_client: Client | null;
  current_wibox: Wibox | null;
}

declare const mouse: MouseGlobal;
