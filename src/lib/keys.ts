import * as awful from "awful";

export function addKey(modifiers: Modifier[], key: string, onPress: () => void): void {
  root.keys([...root.keys(), ...awful.key(modifiers, key, onPress)]);
}
