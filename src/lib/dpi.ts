import * as beautiful from 'beautiful';
import { config } from "./config";
import { dpis, outputName } from "./screens";

const DEFAULT_DPI = 96;

const scaleCache = new WeakMap<Screen, { x: number; y: number }>();

function calculateScreensDpi(screen: Screen): void {
  const configDpi = config("dpi", {});
  const output = outputName(screen);

  let dpi: { x: number; y: number } = { x: DEFAULT_DPI, y: DEFAULT_DPI };

  if (output && configDpi?.[output]) {
    // Use screen specific dpi from config.yml
    dpi = { x: Number(configDpi[output]!), y: Number(configDpi[output]!) };
  } else if (configDpi?.default) {
    // Use dpi.default setting from config.yml
    dpi = { x: Number(configDpi.default), y: Number(configDpi.default) };
  } else {
    // Calculate dpi from screen dimensions/resolutions
    const screenDpi = dpis(screen);
    if (screenDpi) {
      dpi = screenDpi;
    }
  }

  scaleCache.set(screen, { x: dpi.x / DEFAULT_DPI, y: dpi.y / DEFAULT_DPI });
  beautiful.xresources.set_dpi(Math.min(dpi.x, dpi.y), screen);
}

function calculateAllDpi(): void {
  for (const s of screen) {
    calculateScreensDpi(s);
  }
}

export function dpiX(value: number, screen: Screen): number {
  if (!scaleCache.has(screen)) {
    calculateScreensDpi(screen);
  }
  return Math.ceil(value * scaleCache.get(screen)!.x);
}

export function dpiY(value: number, screen: Screen): number {
  if (!scaleCache.has(screen)) {
    calculateScreensDpi(screen);
  }
  return Math.ceil(value * scaleCache.get(screen)!.y);
}

screen.connect_signal("list", calculateAllDpi);
screen.connect_signal("property::geometry", calculateScreensDpi);
screen.connect_signal("property::outputs", calculateScreensDpi);

calculateAllDpi();
