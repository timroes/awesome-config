interface Client {
  class: string;
  floating: boolean;
  set_xproperty(name: string, value: boolean | string | number): void;
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;

  [key: string]: unknown;
}

type ClientProperties = 'floating';
type ClientSignals = 'manage' | 'unmanage' | `property::${ClientProperties}`;

/** @noSelf */
interface ClientGlobal {
  connect_signal(signal: ClientSignals, callback: (client: Client) => void): void;
}

declare const client: ClientGlobal;