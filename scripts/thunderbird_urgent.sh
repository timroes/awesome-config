#! /bin/sh
#
# Requires: wmctrl
#
# Set the urgent window manager hint for the Thunderbird window
# To use it, download the Mailbox Alert extension [https://addons.mozilla.org/en-US/thunderbird/addon/mailbox-alert/]
# and set this script as executing on new mail. So the thunderbird window will be highlighted
# when new mail arrives.
# After setting a rule to execute this script you will need to right click all your inboxes
# and activate the rule for them

/usr/bin/wmctrl -ir `/usr/bin/wmctrl -l | grep "Mozilla Thunderbird" | cut -f1 -d' '` -b add,demands_attention
