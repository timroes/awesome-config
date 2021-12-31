import * as awful from 'awful';

export type Modifier = 'Mod1' | 'Shift' | 'Control' | 'Mod4';

export function addKey(modifiers: Modifier[], key: string, onPress: () => void): void {
  root.keys([...root.keys(), ...awful.key(modifiers, key, onPress)]);
}