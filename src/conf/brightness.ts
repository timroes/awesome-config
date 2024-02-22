import { config } from "../lib/config";
import { execute } from "../lib/process";
import { SCRIPT_PATH } from "../lib/constants";
import { addKey } from "../lib/keys";
import { BarModal } from '../ui/bar-modal';

const backlightDevice = config('brightness_device');

if (backlightDevice) {
  const modal = new BarModal('brightness.png');

  const controlBrightness = async (value: string) => {
    const { stdout } = await execute(`${SCRIPT_PATH}/brightness.sh ${backlightDevice} ${value}`);
    modal.setValue(Number(stdout));
    modal.show();
  }

  addKey([], 'XF86MonBrightnessUp', () => controlBrightness('up'));
  addKey(['Shift'], 'XF86MonBrightnessUp', () => controlBrightness('up small'));
  addKey([], 'XF86MonBrightnessDown', () => controlBrightness('down'));
  addKey(['Shift'], 'XF86MonBrightnessDown', () => controlBrightness('down small'));
}