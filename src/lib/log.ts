import * as awful from 'awful';

const LOGGER_TAG = 'awesome';

export enum LogLevel {
  EMERG = 0,
  ALERT = 1,
  CRIT = 2, 
  ERR = 3,
  WARNING = 4,
  NOTICE = 5,
  INFO = 6,
  DEBUG = 7,
};

export function log(msg: string, level: LogLevel = LogLevel.INFO) {
  awful.spawn.spawn(`logger -t ${LOGGER_TAG} -p ${level} "${msg.replaceAll('"', '\\"')}"`);
}