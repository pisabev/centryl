part of chart;

class Circle {
  CLElement container;
  CLElement inner;
  SvgSvgElement svg;
  GElement graph;
  num width = 0;
  num height = 0;
  int innerOffset = 40;

  Map center = {};
  num radius = 0.0;
  num size = 0;

  int data;

  Circle(this.container) {
    reset();
  }

  void reset() {
    container.removeChilds();
    width = container.getWidthInner();
    height = container.getHeightInner();
    inner = new CLElement(new DivElement())
      ..setStyle({'width': '${width}px'})
      ..setStyle({'height': '${height}px'})
      ..addClass('ui-chart-circle')
      ..appendTo(container);
    svg = new SvgSvgElement()
      ..setAttribute('width', '$width')
      ..setAttribute('height', '$height');
    graph = new GElement()..setAttribute('transform', 'translate(0.5,0.5)');
    svg.append(graph);
    inner.append(svg);
    radius = (height - innerOffset) / 2;
    center = {
      'x': (width - innerOffset) / 2 + innerOffset / 2,
      'y': radius + innerOffset / 2
    };
  }

  void setData(int data) {
    this.data = data;
  }

  void redraw() {
    reset();
    draw();
  }

  void draw() {
    const startRadius = -pi / 2;
    final segmentAngle = (data - 0.01) / 100 * (pi * 2);
    final endRadius = startRadius + segmentAngle;
    final largeArc = ((endRadius - startRadius) % (pi * 2)) > pi ? 1 : 0;
    final startX = center['x'] + cos(startRadius) * radius;
    final startY = center['y'] + sin(startRadius) * radius;
    final endX = center['x'] + cos(endRadius) * radius;
    final endY = center['y'] + sin(endRadius) * radius;
    final pathBack = new CircleElement()
      ..setAttribute('cx', '${center['x']}')
      ..setAttribute('cy', '${center['y']}')
      ..setAttribute('r', '$radius');
    final text = new DivElement()..text = '$data';
    final tsp = new SpanElement()..text = '%';
    graph.append(pathBack);
    inner.append(text..append(tsp));
    if (data != 0) {
      final path = new PathElement();
      path
        ..setAttribute(
            'd',
            'M $startX $startY '
                'A $radius $radius 0 $largeArc 1 $endX $endY')
        ..setAttribute('stroke-dasharray', '${path.getTotalLength()}')
        ..setAttribute('stroke-dashoffset', '${path.getTotalLength()}');
      if (data > 100)
        path.classes.add('high');
      graph.append(path);
    }
  }
}
