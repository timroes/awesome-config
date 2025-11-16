export const outputName = (screen: Screen): string | null => {
  const outputs = screen.outputs;
  if (!outputs) {
    return null;
  }

  return Object.keys(outputs)[0];
};

let orderedScreens: Screen[] = [];

const updateScreenPositions = () => {
  orderedScreens = [];
  for (const s of screen) {
    orderedScreens.push(s);
  }

  orderedScreens.sort((a, b) => {
    if (!a || !b) {
      return 0;
    }
    if (a.geometry.x == b.geometry.x) {
      return a.geometry.y - b.geometry.y;
    }
    return a.geometry.x - b.geometry.x;
  });
};

export const getOrderedScreens = (): Screen[] => {
  return orderedScreens;
};

export const getScreenPosition = (screen: Screen): number => {
  return orderedScreens.indexOf(screen);
};

screen.connect_signal("list", updateScreenPositions);
screen.connect_signal("property::geometry", updateScreenPositions);
updateScreenPositions();
