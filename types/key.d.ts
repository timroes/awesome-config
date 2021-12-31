declare const UniqueKeySymbol: unique symbol;

declare interface Key {
  // This does technically not exist inside a Key instance,
  // but that way we make this interface "unique by name", so you
  // can only create it from methods (like awful.key), that are declaring it.
  [UniqueKeySymbol]: void;
}
