export const maximized: Layout = {
  name: "Maximized",
  arrange(params) {
    for (const client of params.clients) {
      params.geometries.set(client, {
        x: params.workarea.x,
        y: params.workarea.y,
        height: params.workarea.height,
        width: params.workarea.width
      });
    }
  },
}