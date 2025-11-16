import { CairoContext } from "gears";
import * as wibox from "wibox";

type FitFn = (widget: Widget, context: unknown, width: number, height: number) => LuaMultiReturn<[number, number]>;
type DrawFn = (widget: Widget, context: unknown, cr: CairoContext, width: number, height: number) => void;

export function createWidget(params: { fit: FitFn; draw: DrawFn }): WidgetDefinition {
  return <wibox.widget.base.make_widget fit={params.fit} draw={params.draw} />;
}
