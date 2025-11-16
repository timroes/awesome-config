import * as awful from "awful";
import { getOrderedScreens } from "../lib/screens";
import { addKey } from "../lib/keys";
import { SUPER } from "../lib/constants";

function focusByIndex(index: number) {
  const focusables = getOrderedScreens().flatMap((s) => {
    const tag = s.selected_tags.find((t) => t.common_tag);
    if (tag?.layout.countAsMultiple) {
      // If the screen tag's layout counts as multiple screens create all entries for it
      const entries: Array<() => void> = [];
      for (const i of $range(1, tag.layout.countAsMultiple.count())) {
        entries.push(() => tag.layout.countAsMultiple?.focus(i));
      }
      return entries;
    }
    // If the tag's layout doesn't count as multiple just attach the regular
    // screen focus function.
    return [
      () => {
        if (client.focus?.screen === s) {
          client.focus = awful.client.next(1);
        } else {
          client.focus = s.clients[0];
        }
      },
    ];
  });

  focusables[index]?.();
}

// Attach SUPER + 1 .. 9 to hotkeys jumping to the specific screen/sub-tag
for (const i of $range(1, 9)) {
  addKey([SUPER], `#${i + 9}`, () => focusByIndex(i - 1));
}

addKey([SUPER], "Page_Up", () => {
  client.focus = awful.client.next(-1) ?? client.focus;
});
addKey([SUPER], "Page_Down", () => {
  client.focus = awful.client.next(1) ?? client.focus;
});
