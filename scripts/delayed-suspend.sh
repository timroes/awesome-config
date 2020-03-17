#! /bin/bash

# This script is a rudimentary way to put the PC to sleep a specific amount of
# time after it has been locked (using lightdmi/light-locker).
# It isn't perfect, since it won't put it to sleep once the user has returned
# from suspend, but not locked into the PC again.

# This script needs to be put into /etc/lightdm/. If your home directory is encrypted
# don't symlink to this script. The following lines must be configured
# in /etc/lightdm/lightdm.conf for [Seat:*]
#
# greeter-setup-script=/etc/lightdm/delayed-suspend.sh suspend
# session-setup-script=/etc/lightdm/delayed-suspend.sh kill
# session-cleanup-script=/etc/lightdm/delayed-suspend.sh kill

# The delay in seconds after the login screen is shown before the PC is suspended.
suspend_delay=10m

pidfile=/run/lightdm.suspend.pid

case "$1" in
  suspend)
    sleep $suspend_delay && rm $pidfile && systemctl suspend-then-hibernate &
    echo $! > $pidfile
    ;;
  kill)
    pid="$(cat $pidfile)"
    if [ ! -z "$pid" ]; then
      rm $pidfile
      kill $pid
    fi
    ;;
esac
