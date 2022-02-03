#! /bin/bash

# This script uses dbus-monitor to monitor for screensaver inhibit/uninhibit calls
# and emits dbus signals for them, which can later be subscribed to.

dbus-monitor --session --monitor --profile "interface='org.freedesktop.ScreenSaver'" | grep --line-buffered -E 'Inhibit|UnInhibit' | while read -r line; do
  sender="$(echo $line | cut -d" " -f 4)"
  event="$(echo $line | cut -d" " -f 8)"
  dbus-send --session --type=signal /de/timroes/awesome/ScreenSaver de.timroes.awesome.ScreenSaver.$event string:"$sender"
done