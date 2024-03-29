import * as awful from 'awful';
import { LogLevel, log } from './log';

interface ExecuteOutput {
  stdout?: string;
  stderr?: string;
  exitReason: 'exit' | 'signal';
  exitCodeOrSignal: number;
}

export function execute(cmd: string, logging: boolean = true): Promise<ExecuteOutput> {
  return new Promise((resolve) => {
    if (logging) {
      log(`$ ${cmd}`, LogLevel.DEBUG);
    }
    awful.spawn.easy_async(cmd, (stdout, stderr, exitReason, exitCode) => {
      resolve({
        stdout,
        stderr,
        exitReason,
        exitCodeOrSignal: exitCode
      })
    });
  });
}

/**
 * Spawns of a program in a shell and write all its output to a /tmp/awesome.spawn.log.
 */
export function spawn(cmd: string): void {
  log(`$ ${cmd}`, LogLevel.DEBUG);
  awful.spawn.with_shell(`${cmd} >> /tmp/awesome.spawn.log 2>&1`);
}

export async function spawnOnce(cmd: string, pidof: string = cmd.split(' ')[0]): Promise<void> {
  const { stdout: pid } = await execute(`pidof ${pidof}`, false);
  if (!pid || pid.length === 0) {
    spawn(cmd);
  }
}

export async function isCommandAvailable(cmd: string): Promise<void> {
  const { exitCodeOrSignal } = await execute(`/bin/bash -c 'command -v ${cmd}'`, false);
  if (exitCodeOrSignal === 0) {
    return Promise.resolve();
  } else {
    return Promise.reject();
  }
}