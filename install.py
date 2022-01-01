#! /usr/bin/env python3

import os, shutil, subprocess, sys

# All pacman packages that are required for this ocnfiguration to run
PKG_DEPS = {
  'alsa-utils': 'provides utils for volume controls',
  'dex': 'launches all autostart desktop files',
  'libyaml': 'required for lua yaml lib to read config',
  'light-locker': 'required to lock screen properly',
  'luarocks': 'installs lua dependencies',
  'xautolock': 'lock screen automatically after timeout',
  'xdg-utils': 'starts files according to their extension',
  'xorg-setxkbmap': 'changes the keyboard layout',
  'xorg-xset': 'sets properties in xserver (e.g. power saving)',
  'yarn': 'required to build typescript files',
}

# All optional dependencies. These won't be installed automatically, but information
# will be printed out at the end of this script.
OPT_PKG_DEPS = {
  'cpupower': 'required to show CPU frequency information in sidebar',
  'imagemagick': 'required to make screenshots',
  'numlockx': 'install to enable numlock on start',
  'picom': 'required if you want compositing effects (e.g. shadow)',
  'playerctl': 'required if you want to control music via media hotkeys',
  'upower': 'required for battery widget',
  'xf86-input-libinput': 'required for better touchpad behavior',
  'xorg-xinput': 'required to configure mouse and trackpads',
  'xorg-xrandr': 'required for displayswitcher',
  'xorg-xrdb': 'required to set dpi for some applications in displayswitcher'
}

# List all packages that should be installed via luarocks
LUA_DEPS = {
  'inifile': 'required to parse ini files (used in icon themes)',
  'inspect': 'required for debugging tables',
  'luafilesystem': 'required to interact with the filesystem',
  'lyaml': 'YAML library to read out config',
}

# Colors
BLUE  = "\033[1;34m"
GREEN = "\033[1;32m"
RESET = "\033[0;0m"
BOLD  = "\033[;1m"

def install_pkg_deps():
  for dep, desc in PKG_DEPS.items():
    print('  {}{}{} - {}'.format(BOLD, dep, RESET, desc))

  print('')

  subprocess.call(['sudo', 'pacman', '-S', '--needed'] + list(PKG_DEPS.keys()))

def install_lua_deps():
  for dep, desc in LUA_DEPS.items():
    print('  {}{}{} - {}'.format(BOLD, dep, RESET, desc))

  print('')

  for dep, desc in LUA_DEPS.items():
    subprocess.call(['luarocks', '--local', 'install', dep])

def install_yarn_deps():
   subprocess.call(['yarn', 'install'])

def build_typescript():
  subprocess.call(['yarn', 'build'])

def print_opt_pkg_info():
  print('{}Optional packages{}\n'.format(BLUE, RESET))
  print('The following packages are optional and only required for specific features.')
  print('Install them manually if you want to use the features.\n')

  FNULL = open(os.devnull, 'w')

  for dep, desc in OPT_PKG_DEPS.items():
    installed = not subprocess.call(['pacman', '-Qq', dep], stdout=FNULL, stderr=FNULL)
    print('  {}{}{}{} - {}'.format(BOLD, dep, RESET, ' [already installed]' if installed else '', desc))

if __name__ == '__main__':
  if not shutil.which('pacman'):
    print('This install script requires pacman as package manager.')
    print('Please look into it and install all required dependencies manually.')
    sys.exit(1)

  print('{}Installing package dependencies:{}\n'.format(BLUE, RESET))
  install_pkg_deps()
  print('{}Finished installing package dependencies.{}\n'.format(GREEN, RESET))

  print('{}Installing lua dependencies:{}\n'.format(BLUE, RESET))
  install_lua_deps()
  print('{}Finished installing lua dependencies.{}\n'.format(GREEN, RESET))

  print('{}Installing npm dependencies:{}\n'.format(BLUE, RESET))
  install_yarn_deps()
  print('{}Finished installing npm dependencies.{}\n'.format(GREEN, RESET))

  print('{}Compiling TypeScript to Lua:{}\n'.format(BLUE, RESET))
  build_typescript()
  print('{}Finished compiling TypeScript.{}\n'.format(GREEN, RESET))

  print_opt_pkg_info()
  print('')
