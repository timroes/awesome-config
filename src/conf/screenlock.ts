import { config } from '../lib/config';
import { SCRIPT_PATH, SUPER } from '../lib/constants';
import { addKey } from '../lib/keys';
import { spawn, spawnOnce } from '../lib/process';

const screensaverTimeout = config('screensaver.timeout', 10);
const lockCommand = `${SCRIPT_PATH}/lockscreen.sh`;

// Start xautolock which will lock the screen after the configured `screensaver.timeout`
// It locks the screen the same way than using the shortcut to lock it immediately.
spawnOnce(`xautolock -time ${screensaverTimeout} -locker ${lockCommand}`);

addKey([SUPER], 'l', () => spawn(lockCommand));