interface Screen {
  
}

type ScreenProperties = "geometry";
type ScreenSignals = "list" | `property::${ScreenProperties}`;

/** @noSelf */
interface ScreenGlobal {
  connect_signal(signal: ScreenSignals, callback: (screen: Screen) => void): void;
}

declare const screen: ScreenGlobal;
