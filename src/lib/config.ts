import * as lunaconfig from 'lunaconf.config';

interface Config {
  'screensaver.timeout': number;
  'screensaver.suspend_delay': number;
  'brightness_device': string;
  'disable_compositor': boolean;
  'calendar.action': string;
  'dpi': { [key: string]: number | undefined };
}

export function config<K extends keyof Config>(key: K): Config[K] | undefined;
export function config<K extends keyof Config>(key: K, defaultValue: Config[K]): Config[K];
export function config<K extends keyof Config>(key: K, defaultValue?: Config[K]): Config[K] | undefined {
  return lunaconfig.get(key, defaultValue);
}