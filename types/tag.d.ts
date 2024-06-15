type TagProperties = 'layout' | 'master_width_factor' | 'selected';
type TagSignals = `property::${TagProperties}`;

interface Tag {
  name: string;
  get layout(): Layout;
  set layout(layout: LayoutDescription | LayoutFactory);
  selected: boolean;
  activated: boolean;
  screen: Screen;
  index: number;
  volatile: boolean;
  clients(): Client[];
  gap: number;
  master_width_factor: number;

  connect_signal(signal: TagSignals, callback: (...args: any[]) => void): void;
  emit_signal(signal: TagSignals): void;

  /**
   * Properties set by us, not from awesome WM.
   */

  /**
   * Whether this tag is a "common tag", i.e. a regular tag with clients on it, not some form
   * of special tag, like the dock or hidden tags.
   */
  common_tag?: boolean;
}