export const maximized: LayoutDescription = {
  name: "Maximized",
  arrange({ clients, workarea, geometries }) {
    for (const client of clients) {
      geometries.set(client, {
        x: workarea.x,
        y: workarea.y,
        height: workarea.height,
        width: workarea.width
      });
    }
  },
}