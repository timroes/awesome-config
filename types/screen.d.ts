interface Screen {
  geometry: Geometry;
  workarea: Geometry;
  index: number;
  outputs: Record<string, { mm_height: number; mm_width: number }>;
  /**
   * Visible clients on this screen in stacking order (top to bottom).
   */
  clients: Client[];
  /**
   * All tags attached to this screen. This property is read only. Use tag.screen to alter this list.
   */
  tags: readonly Tag[];
  /**
   * A list of all selected tags on the screen.
   */
  selected_tags: readonly Tag[];
  /**
   * The first selected tag on the screen.
   */
  selected_tag: Tag;
  /**
   * Get the list of visible clients for the screen.
   * @param stacked Whether the clients should be returned in stacking order (top to bottom).
   */
  get_clients(stacked?: boolean): Client[];
  /**
   * Get all clients assigned to the screen.
   * @param stacked Whether the clients should be returned in stacking order (top to bottom).
   */
  get_all_clients(stacked?: boolean): Client[];
  /**
   * Get all tiled clients assigned to the screen.
   * @param stacked Whether the clients should be returned in stacking order (top to bottom).
   */
  get_tiled_clients(stacked?: boolean): Client[];
}

type ScreenProperties = "geometry" | "workarea" | "index" | "outputs";
type ScreenSignals = "list" | "primary_changed" | "added" | "removed" | "swapped" | `property::${ScreenProperties}` | "property::dpi";

/** @noSelf */
interface ScreenGlobal extends LuaIterable<Screen> {
  count(): number;
  primary: Screen;
  connect_signal(signal: ScreenSignals, callback: (screen: Screen) => void): void;
  emit_signal(signal: ScreenSignals, screen: Screen): void;
}

declare const screen: ScreenGlobal;
