import * as wibox from 'wibox';

function setupWidget<T extends WidgetBase>(widget: T, props: WidgetProps<T>, ...children: any[]) {
  if (children.length > 0) {
    (children as any).layout = widget;
  } else {
    (children as any).widget = widget;
  }
  if (!!props) {
    for (const [key, value] of Object.entries(props)) {
      (children as any)[key] = value;
    }
  }
  return wibox.widget(children);
}

globalThis.setupWidget = setupWidget;