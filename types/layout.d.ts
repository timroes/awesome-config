/** @noSelf */
interface LayoutParam {
  readonly geometries: LuaTable<Client, Geometry>;
  readonly clients: Client[];
  readonly geometry: Geometry;
  readonly workarea: Geometry;
  readonly useless_gap: number;
  readonly screen: number;
  readonly padding: {
    bottom: number;
    left: number;
    right: number;
    top: number;
  };
}

/** @noSelf */
interface LayoutDescription {
  name: string;
  arrange(params: LayoutParam): void;
  need_focus_update?: boolean;
  skip_gap?: (clientCount: number, t: Tag) => boolean;
  
  // -- The following properties are not used by awesome, but only internally in our configuration.

  tagAction?(tag: Tag): void;
  /**
   * Method that should be executed when a secondary mouse click happens on a client in the clientlist that is part of this layout.
   */
  clientlistAction?: (client: Client) => void;
  /**
   * Can be implemented if a layout wants to handle directional client moves.
   * Return `false` if the client move wasn't handled by the layout and the default
   * moving between screens should still be performed.
   */
  moveClient?(client: Client, direction: "up" | "down" | "left" | "right"): boolean;
  /**
   * Optional object that can be implemented on a layout in case the layout should count
   * as multiple screens (e.g. like a split layout). In this case the layout will get more SUPER + <number>
   * hotkeys assigned to it than just one. It needs to then handle focusing a client via the hotkey
   * by the `focus` method. This will get passed in the relative `index` on the layout, i.e. starting always with
   * 1 no matter which screen the layout is on.
   */
  countAsMultiple?: {
    count(): number;
    focus(index: number): void;
  }
}

type LayoutFactory = (tag: Tag) => (LayoutDescription & {
  /**
   * If `is_dynamic` is `true`, the layout instance will be kept in memory and reused even
   * when the tag switched between layouts. If it's `false` the layout factory function will be called
   * and a new layout generated every time the tag switches back to this layout.
   */
  is_dynamic?: boolean;
  /**
   * Callback that will be called whenever a tag switches to the layout, as long as the tag is selected at that time.
   */
  wake_up?: () => void;
});

type Layout = LayoutDescription | ReturnType<LayoutFactory>;