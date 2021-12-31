import * as lunaconf from 'lunaconf';
import { SCRIPT_PATH, SUPER } from '../lib/constants';
import { addKey } from '../lib/keys';
import { spawn, spawn_once } from '../lib/process';

const screensaverTimeout = lunaconf.config.get('screensaver.timeout', 10);
const lockCommand = `${SCRIPT_PATH}/lockscreen.sh`;

spawn_once(`xautolock -time ${screensaverTimeout} -locker ${lockCommand}`);

addKey([SUPER], 'l', () => spawn(lockCommand));