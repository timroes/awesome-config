import * as awful from 'awful';

export function spawn(cmd: string): void {
  awful.spawn.with_shell(`${cmd} >> /tmp/awesome.spawn.log 2>&1`);
}

export function spawn_once(cmd: string, pidof: string = cmd.split(' ')[0]): void {
  awful.spawn.easy_async(`pidof ${pidof}`, (pid) => {
    if (!pid || pid.length === 0) {
      spawn(cmd);
    }
  })
}

export function isCommandAvailable(cmd: string): Promise<void> {
  return new Promise((resolve, reject) => {
    awful.spawn.easy_async(`/bin/bash -c 'command -v ${cmd}'`, (out, err, reason, status) => {
      if (status === 0) {
        resolve();
      } else {
        reject();
      }
    });
  });
}