interface Screen {
  geometry: Geometry;
  workarea: Geometry;
  index: number;
}

type ScreenProperties = "geometry" | "workarea" | "index";
type ScreenSignals = "list" | "primary_changed" | "added" | "removed" | "swapped" | `property::${ScreenProperties}`;

/** @noSelf */
interface ScreenGlobal {
  primary: Screen;
  connect_signal(signal: ScreenSignals, callback: (screen: Screen) => void): void;
}

declare const screen: ScreenGlobal;
