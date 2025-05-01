import * as lunaconf from "lunaconf";
import { SUPER } from "../lib/constants";
import { addKey } from "../lib/keys";
import { MouseButtonIndex } from "../lib/mouse";

addKey([SUPER, "Shift"], "/", () => {
  mousegrabber.run((m) => {
    if (m.buttons[MouseButtonIndex.PRIMARY]) {
      const c = mouse.current_client;
      if (c) {
        lunaconf.notify.show({
          title: String(c.name),
          text:
            `<b>Window ID:</b> ${c.window}\n` +
            `<b>Type:</b> ${c.type}\n` +
            `<b>Role:</b> ${String(c.role)}\n` +
            `<b>Class:</b> ${c.class} / <b>Instance:</b> ${c.instance}\n` +
            `<b>Floating:</b> ${c.floating}\n` +
            `<b>Tags (${c.tags().length}):</b> ${c
              .tags()
              .map((tag) => tag.name)
              .join(", ")}\n` +
            `<b>Screen:</b> ${c.screen.index}\n` +
            `<b>Geometry:</b> ${c.width}x${c.height}+${c.x}+${c.y}\n` +
            `<b>Unmoveable:</b> ${c.unmoveable} / <b>Unresizeable:</b> ${c.unresizeable}\n` +
            `<b>Motif WM Hints:</b> ${c.motif_wm_hints ? inspect(c.motif_wm_hints) : String(null)}\n` +
            `<b>Size Hints:</b> ${c.size_hints ? inspect(c.size_hints) : String(null)}`,
          unlimited_content: true,
          timeout: -1,
        });
      } else if (mouse.current_wibox) {
        const w = mouse.current_wibox;
        lunaconf.notify.show({
          title: "Wibox",
          text: `<b>Window ID:</b> ${w.window}\n` + `<b>Type:</b> ${w.type}\n` + `<b>Geometry:</b> ${w.width}x${w.height}+${w.x}+${w.y}`,
          unlimited_content: true,
          timeout: -1,
        });
      }
      return false;
    }
    return true;
  }, "crosshair");
});
