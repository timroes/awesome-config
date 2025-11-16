export function transparency(color: string, alpha: number) {
  return `${color.substring(0, 7)}${Math.round(alpha * 255)
    .toString(16)
    .padStart(2, "0")}`;
}
