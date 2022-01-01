import * as lunaconf from 'lunaconf';

interface Config {
  'screensaver.timeout': number;
}

export function config<K extends keyof Config>(key: K): Config[K] | undefined;
export function config<K extends keyof Config>(key: K, defaultValue: Config[K]): Config[K];
export function config<K extends keyof Config>(key: K, defaultValue?: Config[K]): Config[K] | undefined {
  return lunaconf.config.get(key, defaultValue);
}