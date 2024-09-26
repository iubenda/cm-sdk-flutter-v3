enum CmpPosition {
  fullScreen,
  halfScreenTop,
  halfScreenBottom,
  custom, // We'll pass a Rect for custom positions
}

enum CmpBackgroundStyle {
  dimmed, // We'll pass color and opacity for dimmed
  blur, // We'll pass blur style
  color, // We'll pass color for background color
  none,
}
