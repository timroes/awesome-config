type TagProperties = 'layout';
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

  emit_signal(signal: TagSignals): void;
}