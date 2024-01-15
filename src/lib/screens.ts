export const outputName = (screen: Screen): string | null => {
  const outputs = screen.outputs;
  if (!outputs) {
    return null;
  }

  return Object.keys(outputs)[0];
};

export const dpis = (screen: Screen): { x: number; y: number } | null => {
  const outputs = screen.outputs;
  if (!outputs) {
    return null;
  }

  const firstOutput = Object.values(outputs)[0];
  return {
    x: (screen.geometry.width * 25.4) / firstOutput.mm_width,
    y: (screen.geometry.height * 25.4) / firstOutput.mm_height,
  };
};