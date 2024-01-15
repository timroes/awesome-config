export {};

declare global {
  /** @noSelf */
  function setupWidget<T extends WidgetBase>(type: T, props: WidgetProps<T>, ...children: any[]): unknown;
}
