#! /bin/bash

# This script uses dbus-monitor to monitor for screensaver inhibit/uninhibit calls
# and emits dbus signals for them, which can later be subscribed to.

dbus-monitor --session --monitor --profile "interface='org.freedesktop.ScreenSaver'" | grep --line-buffered -o -E 'Inhibit|UnInhibit' | while read -r line; do
  dbus-send --session --type=signal /de/timroes/awesome/ScreenSaver de.timroes.awesome.ScreenSaver.$line
done