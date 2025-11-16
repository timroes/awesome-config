interface XPropertiesObject {
  set_xproperty(name: string, value: boolean | string | number): void;
  get_xproperty<T extends boolean | string | number>(name: string): T;
}
