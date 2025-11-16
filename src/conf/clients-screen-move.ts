import * as lunaconf from "lunaconf";
import { addKey } from "../lib/keys";
import { SUPER } from "../lib/constants";

const moveInDirection = (dir: "right" | "up" | "down" | "left"): void => {
  const c = client.focus;
  if (c && !c.unmoveable) {
    for (const tag of c.tags()) {
      if (tag.layout.moveClient?.(c, dir)) {
        // If a tag the client is on is handling the move, we don't need to do anything else
        return;
      }
    }

    // If no layout handled the move, just move the client to the next screen in direction
    const s = c.screen.get_next_in_direction(dir);
    if (s) {
      c.move_to_tag(lunaconf.tags.get_current_tag(s));
      client.focus = c;
    }
  }
};

addKey([SUPER], "Right", () => moveInDirection("right"));
addKey([SUPER], "Up", () => moveInDirection("up"));
addKey([SUPER], "Down", () => moveInDirection("down"));
addKey([SUPER], "Left", () => moveInDirection("left"));
