import * as gears from 'gears';

export const SCRIPT_PATH = `${gears.filesystem.get_configuration_dir()}scripts`;
export const CONFIGS_PATH = `${gears.filesystem.get_configuration_dir()}configs`;

/**
 * The primary modifier key to use for keyboard combinations.
 */
export const SUPER = 'Mod4';

export const Xproperties = {
  DISABLE_SHADOW: '_PICOM_NO_SHADOW',
  DISABLE_ROUNDED: '_PICOM_NO_ROUNDED',
} as const;