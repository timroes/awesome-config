declare global {
  var _dndActive: boolean;
}

globalThis._dndActive = false;

export const isDndActive = (): boolean => globalThis._dndActive;

export const toggleDnd = (): boolean => {
  globalThis._dndActive = !globalThis._dndActive;
  awesome.emit_signal("notifications::dnd");
  return globalThis._dndActive;
};

export const onDndChange = (callback: (active: boolean) => void): void => {
  awesome.connect_signal("notifications::dnd", () => callback(globalThis._dndActive));
};
