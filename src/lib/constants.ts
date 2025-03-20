import * as gears from 'gears';

export const SCRIPT_PATH = `${gears.filesystem.get_configuration_dir()}scripts`;
export const CONFIGS_PATH = `${gears.filesystem.get_configuration_dir()}configs`;
export const ICON_PATH = `${gears.filesystem.get_configuration_dir()}icons`;

/**
 * The primary modifier key to use for keyboard combinations.
 */
export const SUPER = 'Mod4';
