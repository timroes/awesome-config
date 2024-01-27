import { dpiX } from "../lib/dpi";
import * as wibox from "wibox";
import * as awful from "awful";
import { maximized } from "./maximized";
import { MouseButton, MouseButtonIndex } from "../lib/mouse";
import { theme } from "../theme/default";

type Side = "left" | "right";

const opposite = (side: Side): Side => {
  return side === "left" ? "right" : "left";
}

export const split: LayoutFactory = (tag) => {
  let lastActiveSide: Side = "left";
  const sides = new WeakMap<Client, Side>();

  const gapWidth = dpiX(2, tag.screen);

  client.connect_signal("focus", (client) => {
    if (client.tags().includes(tag)) {
      lastActiveSide = sides.get(client) ?? lastActiveSide;
    }
  });

  const divider = wibox({
    x: tag.master_width_factor * tag.screen.workarea.width - gapWidth / 2,
    y: tag.screen.workarea.y,
    width: gapWidth,
    height: tag.screen.workarea.height,
    screen: tag.screen,
    visible: true,
    type: "utility",
    cursor: "sb_h_double_arrow",
    bg: theme.bg.base,
  });
  divider.connect_signal("mouse::enter", () => {
    divider.bg = theme.highlight.regular;
  });
  divider.connect_signal("mouse::leave", () => {
    divider.bg = theme.bg.base;
  });
  divider.set_xproperty("_PICOM_NO_SHADOW", true);
  divider.set_xproperty("_PICOM_NO_ROUNDED", true);
  divider.buttons([
    ...awful.button([], MouseButton.PRIMARY, () => {
      mousegrabber.run((mouse) => {
        // TODO: Handle minimum window sizes somehow
        const newWidth = mouse.x / tag.screen.workarea.width;
        tag.master_width_factor = newWidth;
        return mouse.buttons[MouseButtonIndex.PRIMARY];
      }, "sb_h_double_arrow");
    }),
    ...awful.button([], MouseButton.SECONDARY, () => {
      tag.master_width_factor = 0.5;
    }),
  ]);

  tag.connect_signal("property::layout", () => {
    divider.visible = tag.layout.name === "Split";
  });

  tag.connect_signal("property::master_width_factor", (tag) => {
    divider.x = tag.master_width_factor * tag.screen.workarea.width - gapWidth / 2;
  });

  return {
    name: "Split",
    is_dynamic: true,
    clientlistAction: (c: Client) => {
      sides.set(c, opposite(lastActiveSide));
      c.raise();
      if (c == client.focus) {
        lastActiveSide = opposite(lastActiveSide);
      }
      tag.emit_signal("property::layout");
    },
    tagAction(tag) {
      for (const client of tag.clients()) {
        sides.set(client, opposite(sides.get(client) ?? "left"));
      }
      tag.emit_signal("property::layout");
    },
    moveClient(client, direction) {
      if (direction === "right" && sides.get(client) === "left") {
        sides.set(client, "right");
        tag.emit_signal("property::layout");
        return true;
      } else if (direction === "left" && sides.get(client) === "right") {
        sides.set(client, "left");
        tag.emit_signal("property::layout");
        return true;
      }
      return false;
    },
    arrange(params) {
      const { clients, workarea, geometries } = params;

      // If there are less than 2 clients in the layout, treat it like a maximized layout
      if (clients.length < 2) {
        maximized.arrange(params);
        return;
      }

      for (const client of clients) {
        let side = sides.get(client);
        if (!side) {
          sides.set(client, lastActiveSide);
          side = lastActiveSide;
        }
        
        if (side === "left") {
          geometries.set(client, {
            x: workarea.x,
            y: workarea.y,
            height: workarea.height,
            width: workarea.width * tag.master_width_factor - gapWidth / 2,
          });
        } else {
          geometries.set(client, {
            x: workarea.x + workarea.width * tag.master_width_factor + gapWidth / 2,
            y: workarea.y,
            height: workarea.height,
            width: workarea.width * (1 - tag.master_width_factor) - gapWidth / 2,
          });
        }
      }
    },
  }
};