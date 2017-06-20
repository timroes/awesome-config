#! /usr/bin/env python3

import subprocess, re, sys

def display_infos():
  xrandr = subprocess.check_output(['xrandr', '--verbose']).decode('utf-8')
  xrandr_displays = re.split(r'\n(?=[A-Za-z])', xrandr)

  screen_regex = re.compile(r'^(?P<id>\S+)\s(?P<state>(?:dis)?connected).*')
  resolution_regex = re.compile(r'^[^\n]*?(?P<x>\d+)x(?P<y>\d+)\+\d+\+\d+.*')
  preferred_regex = re.compile(r'^\s+(?P<x>\d+)x(?P<y>\d+).*preferred.*', re.MULTILINE)
  size_regex = re.compile(r'^[^\n]*?(?P<width>\d+)mm x (?P<height>\d+)mm')

  displays = []
  # Ignore first entry, since it is the screen line
  for display_str in xrandr_displays[1:]:

    match = screen_regex.match(display_str)

    display = {
      'id': match.group('id'),
      'state': match.group('state'),
      'primary': match.group(0).find('primary') > -1
    }

    preferred = preferred_regex.search(display_str)
    if preferred:
      display['preferred'] = {
        'x': int(preferred.group('x')),
        'y': int(preferred.group('y'))
      }

    resolution = resolution_regex.match(display_str)
    if resolution:
      display['resolution'] = {
        'x': int(resolution.group('x')),
        'y': int(resolution.group('y'))
      }

    size = size_regex.match(display_str)
    if size:
      display['size_mm'] = {
        'width': int(size.group('width')),
        'height': int(size.group('height'))
      }

    if resolution and size:
      display['dpi'] = {
        'x': round((display['resolution']['x'] * 25.4) / display['size_mm']['width']),
        'y': round((display['resolution']['y'] * 25.4) / display['size_mm']['height'])
      }

    displays.append(display)

  return displays

def connected_displays():
  infos = display_infos()
  return [x for x in infos if x['state'] == 'connected']

def layout_extend():
  '''
    Extends layout chains all displays right-of the previous display and give
    them their auto resolution.
  '''
  displays = connected_displays()

  if len(displays) > 1:
    args = ['xrandr', '--output', displays[0]['id'], '--auto']
    # Only setup layout if there is more than one display
    for i, display in enumerate(displays[1:], start=1):
      args.extend(['--output', display['id'], '--auto', '--right-of', displays[i-1]['id']])

    subprocess.call(args)

def layout_clone():
  '''
    Clone layout will make all outputs show the same picture.
  '''
  displays = connected_displays()

  # Find the display with the lowest preferred resolution
  min_res_display = min(displays, key=lambda d: d['preferred']['x'] * d['preferred']['y'])
  min_resolution = '{}x{}'.format(min_res_display['preferred']['x'], min_res_display['preferred']['y'])

  if len(displays) > 1:
    args = ['xrandr', '--output', min_res_display['id'], '--auto']

    for display in filter(lambda d: d['id'] != min_res_display['id'], displays):
      pref_res = '{}x{}'.format(display['preferred']['x'], display['preferred']['y'])
      args.extend(['--output', display['id'], '--same-as', min_res_display['id'],
        '--mode', pref_res, '--scale', pref_res, '--scale-from', min_resolution])

    # print(' '.join(args))
    subprocess.call(args)

def print_state():
  infos = connected_displays()
  print(', '.join([x['id'] for x in infos]), end='')
  if len(infos) > 1:
    sys.exit(0)
  else:
    # If there is only one display connected exit with exit code 26
    sys.exit(26)

if __name__ == '__main__':
  what = '' if len(sys.argv) < 2 else sys.argv[1]
  if what == 'auto':
    pass
  elif what == 'clone':
    layout_clone()
  elif what == 'extend':
    layout_extend()
  else:
    print_state()
