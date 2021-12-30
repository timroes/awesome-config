interface Client {
  class: string;

  [key: string]: unknown;
}

type ClientSignals = 'manage' | 'unmanage';

/** @noSelf */
interface ClientGlobal {
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;
}

declare const client: ClientGlobal;