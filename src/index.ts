// Import the actual configuration files in the desired order.

import "./conf/debug";

import "./conf/clients-basic";
import "./conf/clients-focus";
import "./conf/clients-screen-move";
import "./conf/tags";

import "./conf/compositor";
import "./conf/screensaver";
import "./conf/brightness";
import "./conf/audio";
import "./conf/terminal";

// Global controls
import "./conf/misc-keys";

// Configurations of different input devices
import "./conf/pointing-devices";
import "./conf/numpad";

// Application specific handling
import "./conf/apps/rofimoji";
import "./conf/apps/zoom";

import "./ui/topbar";
import "./ui/displayswitcher";
import "./ui/controlcenter";

import "./conf/autostart";
