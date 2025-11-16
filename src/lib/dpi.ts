import * as beautiful from "beautiful";
import { config } from "./config";
import { spawn } from "./process";
import { LogLevel, log } from "./log";

export const DEFAULT_DPI = 96;

const scaleCache = new WeakMap<Screen, number>();

const DPI_OVERWRITES = config("dpi") ?? {};

function updateDpis() {
  log("Updating DPIs for all screens", LogLevel.DEBUG);
  const allDpis: number[] = [];
  for (const s of screen) {
    const [output, outputSize] = Object.entries(s.outputs)[0] ?? [];
    let dpi = DEFAULT_DPI;

    if (output && DPI_OVERWRITES[output]) {
      // Use screen specific dpi from config.yml
      dpi = Number(DPI_OVERWRITES[output]);
    } else if (!!outputSize) {
      // Calculate dpi from screen dimensions/resolutions
      dpi = (s.geometry.width * 25.4) / outputSize.mm_width;
    }

    scaleCache.set(s, dpi / DEFAULT_DPI);
    beautiful.xresources.set_dpi(dpi, s);
    allDpis.push(dpi);
    screen.emit_signal("property::dpi", s);

    if (output?.length > 0) {
      spawn(`command -v xrandr > /dev/null && xrandr --dpi ${dpi}/${output}`);
    }
  }

  spawn(`command -v xrdb > /dev/null && (echo "Xft.dpi: ${Math.min(...allDpis)}" | xrdb -merge -)`);
}

export function dpi(value: number, screen: Screen): number {
  const factor = scaleCache.get(screen) ?? 1;
  return Math.ceil(value * factor);
}

screen.connect_signal("list", updateDpis);
screen.connect_signal("property::geometry", updateDpis);
screen.connect_signal("property::outputs", updateDpis);

updateDpis();
