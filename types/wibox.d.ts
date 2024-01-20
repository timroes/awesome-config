interface WidgetDefinition {
  __isWidgetDefinition: true;
  layout?: WidgetBase;
  widget?: WidgetBase;

  // Widget declaration
  [key: string]: unknown;
}

interface WidgetBase {
  (): WidgetDefinition;
  // Those properties don't really exist on the Lua class,
  // but are only used for TypeScript type differentiation.
  __type: "widget";
}

interface LayoutBase {
  (): WidgetDefinition;
  // Those properties don't really exist on the Lua class,
  // but are only used for TypeScript type differentiation.
  __type: "layout";
}

interface Widget {
  get_children_by_id(id: string): Widget[];
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

interface TextBox extends Widget, TextBoxProps {}

type WidgetProps<T> = T extends { __widget: "textbox" } ? TextBoxProps : {};

interface ContainerProps {
  bg?: string;
  fg?: string;
  opacity?: number;
}

type LayoutProps<T> = T extends { __layout: "container" } ? ContainerProps : {};

interface TextClock extends Widget {
  format?: string;
  force_update(): void;
}

declare module 'wibox' {
  /** @noSelf */
  interface WidgetModule {
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
    
    (declarativeWidget: WidgetDefinition): Widget;
  }

  interface BackgroundContainer extends Widget {
    bg: string;
    fg: string;
  }

  /** @noSelf */
  interface Container {
    background: LayoutBase & { __layout: "container" };
    constraint: LayoutBase;
    margin: LayoutBase;
    place: LayoutBase;
  }

  interface AlignLayout extends Widget {
    first: Widget;
    second: Widget;
    third: Widget;
  }

  interface FixedLayout extends Widget {
    reset(): void;
    add(...widget: Widget[]): void;
  }

  /** @noSelf */
  interface Layouts {
    ratio: {
      horizontal: LayoutBase;
      vertical: LayoutBase;
    },
    align: {
      horizontal: LayoutBase;
      vertical: LayoutBase;
    },
    fixed: {
      horizontal: LayoutBase;
      vertical: LayoutBase;
    },
    flex: {
      horizontal: LayoutBase;
      vertical: LayoutBase;
    },
  }

  export const widget: WidgetModule;
  export const container: Container;
  export const layout: Layouts;
}
