#! /usr/bin/env python3

import subprocess, re

xrandr = subprocess.check_output(['xrandr', '--verbose']).decode('utf-8')
displays = re.split(r'\n(?=[A-Za-z])', xrandr)

screen_regex = re.compile(r'^(?P<id>\S+)\s(?P<state>(?:dis)?connected).*')

# Ignore first entry, since it is the screen line
for display_str in displays[1:]:

    match = screen_regex.match(display_str)

    display = {
        'id': match.group('id'),
        'state': match.group('state')
    }
    resolution = re.match(r'^[^\n]*?(\d+x\d+)\+\d+\+\d+.*', display_str)
    if resolution:
        res = resolution.group(1).split('x')
        display['resolution'] = {
            'x': int(res[0]),
            'y': int(res[1])
        }

    size = re.match(r'^[^\n]*?(\d+)mm x (\d+)mm', display_str)
    if size:
        display['size_mm'] = {
            'width': int(size.group(1)),
            'height': int(size.group(2))
        }

    if resolution and size:
        display['dpi'] = {
            'x': round((display['resolution']['x'] * 25.4) / display['size_mm']['width']),
            'y': round((display['resolution']['y'] * 25.4) / display['size_mm']['height'])
        }

    print(display)
