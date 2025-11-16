import * as awful from "awful";

export function addRule(rule: awful.Rule): void {
  awful.rules.rules = [...(awful.rules.rules || []), rule];
}
