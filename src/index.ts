// Import the actual configuration files in the desired order.

import './conf/compositor';
import './conf/screensaver';
import './conf/brightness';
import './conf/audio';

import './conf/timezones';

// Global controls
import './conf/misc-keys';

// Configurations of different input devices
import './conf/pointing-devices';
import './conf/numpad';

// Application specific handling
import './conf/apps/rofimoji';

import './conf/autostart';