interface Screen {
  geometry: Geometry;
  workarea: Geometry;
  index: number;
  outputs: Record<string, { mm_height: number; mm_width: number }>;
}

type ScreenProperties = "geometry" | "workarea" | "index" | "outputs";
type ScreenSignals = "list" | "primary_changed" | "added" | "removed" | "swapped" | `property::${ScreenProperties}`;

/** @noSelf */
interface ScreenGlobal {
  primary: Screen;
  connect_signal(signal: ScreenSignals, callback: (screen: Screen) => void): void;
}

declare const screen: ScreenGlobal;
