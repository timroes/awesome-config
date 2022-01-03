import * as lunaconf from 'lunaconf';
import { config } from "../lib/config";
import { execute } from "../lib/process";
import { SCRIPT_PATH } from "../lib/constants";
import { addKey } from "../lib/keys";

const backlightDevice = config('brightness_device');

if (backlightDevice) {
  const dialog = lunaconf.dialogs.bar('preferences-system-brightness-lock', 1);

  const controlBrightness = async (value: string) => {
    const { stdout } = await execute(`${SCRIPT_PATH}/brightness.sh ${backlightDevice} ${value}`);
    dialog.set_value(Number(stdout));
    dialog.show();
  }

  addKey([], 'XF86MonBrightnessUp', () => controlBrightness('up'));
  addKey(['Shift'], 'XF86MonBrightnessUp', () => controlBrightness('up small'));
  addKey([], 'XF86MonBrightnessDown', () => controlBrightness('down'));
  addKey(['Shift'], 'XF86MonBrightnessDown', () => controlBrightness('down small'));
}