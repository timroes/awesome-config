import { SUPER } from "../lib/constants";
import { addKey } from "../lib/keys";
import * as layouts from "../layouts";

const LAYOUTS = [layouts.maximized, layouts.split];

const getFocusedCommonTags = () => {
  const focus = client.focus;
  if (focus) {
    return focus.tags().filter((tag) => (tag as { common_tag?: boolean }).common_tag);
  } else {
    return [];
  }
};

addKey([SUPER], ",", () => {
  getFocusedCommonTags().forEach((tag) => {
    // Only switch layout of common_tag (i.e. the primary screen tag)
    const currentLayoutIndex = LAYOUTS.indexOf(tag.layout);
    tag.layout = LAYOUTS[(currentLayoutIndex + 1) % LAYOUTS.length];
  });
});

addKey([SUPER], ".", () => {
  getFocusedCommonTags().forEach((tag) => {
    tag.layout.tagAction?.(tag);
  });
});