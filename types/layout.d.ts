/** @noSelf */
interface LayoutParam {
  readonly geometries: LuaTable<Client, Geometry>;
  readonly clients: Client[];
  geometry: Geometry;
  workarea: Geometry;
  useless_gap: number;
  screen: number;
  padding: {
    bottom: number;
    left: number;
    right: number;
    top: number;
  };
}

/** @noSelf */
interface Layout {
  name: string;
  arrange(params: LayoutParam): void;
  need_focus_update?: boolean;
  skip_gap?: (clientCount: number, t: unknown) => boolean;
}