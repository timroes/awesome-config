function setupWidget<T extends WidgetBase>(widget: T, props: WidgetProps<T>, ...children: WidgetDefinition[]): WidgetDefinition {
  const content = children as unknown as WidgetDefinition;
  // This isn't needed by awesome, just so we can have better TS typing
  content.__isWidgetDefinition = true;
  content[children.length > 0 ? "layout" : "widget"] = widget;
  if (!!props) {
    for (const [key, value] of Object.entries(props)) {
      content[key] = value;
    }
  }
  return content;
}

globalThis.setupWidget = setupWidget;
