import * as lunaconf from 'lunaconf';
import { SCRIPT_PATH, SUPER } from '../lib/constants';
import { addKey } from '../lib/keys';
import { spawn, spawn_once } from '../lib/process';

const screensaver_timeout = lunaconf.config.get('screensaver.timeout', 10);

spawn_once(`xautolock -time ${screensaver_timeout} -locker ${SCRIPT_PATH}/lockscreen.sh`);

addKey([SUPER], 'l', () => spawn('xautolock -locknow'));