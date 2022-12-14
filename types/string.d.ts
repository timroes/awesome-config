declare namespace string {
  export function find(haystack: string, needle: string): LuaMultiReturn<[number, number]>;
  export function match(haystack: string, needle: string): unknown;
}