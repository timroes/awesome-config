interface WidgetBase {
  (): WidgetBase;
  get_children_by_id(id: string): WidgetBase[];
  // Those properties don't really exist on the Lua class,
  // but are only used for TypeScript type differentiation.
  __type: "widget";
  __widget: string;
}

interface LayoutBase {
  (): LayoutBase;
  // Those properties don't really exist on the Lua class,
  // but are only used for TypeScript type differentiation.
  __type: "layout";
}

interface TextBoxProps {
  markup?: string;
  text?: string;
  ellipsize?: "start" | "middle" | "end";
  wrap?: "word" | "chart" | "word_char";
  valign?: "top" | "center" | "bottom";
  align?: "left" | "center" | "right";
  font?: string;
}

type WidgetProps<T> = T extends { __widget: "textbox" } ? TextBoxProps : {};

interface ContainerProps {
  bg?: string;
  fg?: string;
  opacity?: number;
}

type LayoutProps<T> = T extends { __layout: "container" } ? ContainerProps : {};

interface TextClock extends WidgetBase{
  format?: string;
  force_update(): void;
}

declare module 'wibox' {
  /** @noSelf */
  interface Widget {
    calendar: WidgetBase;
    checkbox: WidgetBase;
    graph: WidgetBase;
    imagebox: WidgetBase;
    piechart: WidgetBase;
    progressbar: WidgetBase;
    separator: WidgetBase;
    slider: WidgetBase;
    systray: WidgetBase;
    textbox: WidgetBase & { __widget: "textbox" };
    textclock: WidgetBase;
    
    (declarativeWidget: unknown): WidgetBase;
  }

  /** @noSelf */
  interface Container {
    background: LayoutBase & { __layout: "container" };
  }

  /** @noSelf */
  interface Layouts {
    align: {
      horizontal: LayoutBase;
      vertical: LayoutBase;
    },
    fixed: {
      horizontal: LayoutBase;
      vertical: LayoutBase;
    }
  }

  export const widget: Widget;
  export const container: Container;
  export const layout: Layouts;
}
