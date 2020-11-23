part of chart;

class Pie {
  dynamic container;
  SvgSvgElement svg;
  num width = 0;
  num height = 0;
  GElement graph;
  int segment_count = 0;

  Map center = {};
  num radius = 0.0;
  num size = 0;
  num legend_o = 10;
  num legend_l = 0;

  List segments = [];
  List segmentAngles = [];
  List segmentAnims = [];
  List segmentLabels = [];

  List<DataSet> data;
  num total = 0.0;

  Pie(this.container) {
    reset();
  }

  void reset() {
    segments = [];
    segmentAngles = [];
    segmentAnims = [];
    segmentLabels = [];
    segment_count = 0;
    width = container.getWidthInner();
    height = container.getHeightInner();
    container.removeChilds();
    svg = new SvgSvgElement()
      ..setAttribute('width', '$width')
      ..setAttribute('height', '$height')
      ..setAttribute('class', 'ui-chart-pie');
    graph = new GElement()..setAttribute('transform', 'translate(0.5,0.5)');
    svg.append(graph);
    container.append(svg);
    final half = width / 2, size = min(height, half);
    legend_l = size + legend_o;
    radius = size / 2;
    center = {'x': radius, 'y': radius};
  }

  void redraw() {
    reset();
    draw();
  }

  void setData(List<DataSet> data) {
    this.data = data;
  }

  void draw() {
    total = 0.0;
    data.forEach((set) => total += set.value);
    var i = 0;
    data.forEach((set) {
      final path = new PathElement();
      final classname = 'slice${++segment_count}';
      path.setAttribute('class', classname);
      graph.append(path);
      (path, n) {
        path.onMouseOver.listen((e) => _animateSegment(n, '1', '0.2'));
        path.onMouseOut.listen((e) => _animateSegment(n, '0.2', '1'));
      }(path, i);
      final anim = new AnimateElement()
        ..setAttribute('attributeName', 'opacity')
        ..setAttribute('fill', 'freeze');
      path.append(anim);

      final percentage = set.value / total;
      final label_anim = _getLegend(
          '${set.key} - ${(percentage * 100).toStringAsFixed(2)} %',
          classname,
          legend_l,
          i);
      i++;

      segmentAnims.add(anim);
      segmentLabels.add(label_anim);
      segments.add(path);
      segmentAngles.add(percentage * (pi * 2));
    });
    if (segments.length == 1) segmentAngles[0] = 0.999 * (pi * 2);
    final start = new DateTime.now();
    void frame(num t) {
      final v = EasingEngine.easeOutExponential(
          new DateTime.now().difference(start).inMilliseconds, 500, 1, 0);
      _drawFrame(v);
      if (v >= 1)
        return;
      else
        window.requestAnimationFrame(frame);
    }

    frame(0);
  }

  void _drawFrame([rotateAnimation = 1]) {
    var startRadius = -pi / 2;
    var i = 0;
    segmentAngles.forEach((segment) {
      final segmentAngle = rotateAnimation * segment,
          endRadius = startRadius + segmentAngle,
          largeArc = ((endRadius - startRadius) % (pi * 2)) > pi ? 1 : 0,
          startX = center['x'] + cos(startRadius) * radius,
          startY = center['y'] + sin(startRadius) * radius,
          endX = center['x'] + cos(endRadius) * radius,
          endY = center['y'] + sin(endRadius) * radius;
      startRadius += segmentAngle;

      segments[i++].setAttribute(
          'd',
          'M $startX $startY '
          'A $radius $radius 0 $largeArc 1 $endX $endY '
          'L ${center['x']} ${center['y']} z');
    });
  }

  void _animateSegment(int num, String from, String to) {
    for (var i = 0; i < segments.length; i++) {
      if (i != num) {
        final label = segmentLabels[i], slice = segmentAnims[i];
        label
          ..setAttribute('from', from)
          ..setAttribute('to', to)
          ..setAttribute('dur', '0.4s')
          ..beginElement();
        slice
          ..setAttribute('from', from)
          ..setAttribute('to', to)
          ..setAttribute('dur', '0.4s')
          ..beginElement();
      }
    }
  }

  AnimateElement _getLegend(dynamic value, String classname, num x, num num) {
    final group = new GElement(),
        rect = new RectElement(),
        text = new TextElement(),
        anim = new AnimateElement();

    group
      ..append(rect)
      ..append(text)
      ..append(anim)
      ..setAttribute('transform', 'translate($x, ${num * 30})')
      ..onMouseOver.listen((e) => _animateSegment(num, '1', '0.2'))
      ..onMouseOut.listen((e) => _animateSegment(num, '0.2', '1'));

    rect
      ..setAttribute('class', classname)
      ..setAttribute('width', '20')
      ..setAttribute('height', '20');

    text
      ..setAttribute('x', '25')
      ..setAttribute('y', '14')
      ..text = value;

    anim
      ..setAttribute('attributeName', 'opacity')
      ..setAttribute('fill', 'freeze');

    graph.append(group);

    return anim;
  }
}
