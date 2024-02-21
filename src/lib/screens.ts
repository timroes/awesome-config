export const outputName = (screen: Screen): string | null => {
  const outputs = screen.outputs;
  if (!outputs) {
    return null;
  }

  return Object.keys(outputs)[0];
};
